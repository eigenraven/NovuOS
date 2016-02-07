#include <efi.h>
#include <efilib.h>

void ShowBootString(CHAR16* lstr);
void ShowBootStringLn(CHAR16* lstr);
UINT8 CheckedRun(EFI_STATUS status, CHAR16* info);

#define STR_(X) # X
#define STR(X) STR_(X)
#define WIDEN_(X) L ## X
#define WIDEN(X) WIDEN_(X)
#define LSTR(X) WIDEN(STR(X))

void ShowBootString(CHAR16* lstr)
{
	ST->ConOut->OutputString(ST->ConOut, lstr);
}

void ShowBootStringLn(CHAR16* lstr)
{
	ST->ConOut->OutputString(ST->ConOut, lstr);
	ST->ConOut->OutputString(ST->ConOut, L"\n\r");
}

UINT8 CheckedRun(EFI_STATUS status, CHAR16* info)
{
	if(EFI_ERROR(status))
	{
#define XHANDLE(x) case x: ShowBootString( L"[ERR:" LSTR(X) L"] " ); ShowBootStringLn(info); break
		switch(status)
		{
			XHANDLE(EFI_LOAD_ERROR          );
			XHANDLE(EFI_INVALID_PARAMETER   );
			XHANDLE(EFI_UNSUPPORTED         );
			XHANDLE(EFI_BAD_BUFFER_SIZE     );
			XHANDLE(EFI_BUFFER_TOO_SMALL    );
			XHANDLE(EFI_NOT_READY           );
			XHANDLE(EFI_DEVICE_ERROR        );
			XHANDLE(EFI_WRITE_PROTECTED     );
			XHANDLE(EFI_OUT_OF_RESOURCES    );
			XHANDLE(EFI_VOLUME_CORRUPTED    );
			XHANDLE(EFI_VOLUME_FULL         );
			XHANDLE(EFI_NO_MEDIA            );
			XHANDLE(EFI_MEDIA_CHANGED       );
			XHANDLE(EFI_NOT_FOUND           );
			XHANDLE(EFI_ACCESS_DENIED       );
			XHANDLE(EFI_NO_RESPONSE         );
			XHANDLE(EFI_NO_MAPPING          );
			XHANDLE(EFI_TIMEOUT             );
			XHANDLE(EFI_NOT_STARTED         );
			XHANDLE(EFI_ALREADY_STARTED     );
			XHANDLE(EFI_ABORTED             );
			XHANDLE(EFI_ICMP_ERROR          );
			XHANDLE(EFI_TFTP_ERROR          );
			XHANDLE(EFI_PROTOCOL_ERROR      );
			XHANDLE(EFI_INCOMPATIBLE_VERSION);
			XHANDLE(EFI_SECURITY_VIOLATION  );
			XHANDLE(EFI_CRC_ERROR           );
			XHANDLE(EFI_END_OF_MEDIA        );
			XHANDLE(EFI_END_OF_FILE         );
			XHANDLE(EFI_INVALID_LANGUAGE    );
			XHANDLE(EFI_COMPROMISED_DATA    );
		}
#undef XHANDLE
		while(1) {}
	}
	else if(EFIWARN(status))
	{
#define XHANDLE(x) case x: ShowBootString( L"[WARN:" LSTR(X) L"] " ); ShowBootStringLn(info); break
		switch(status)
		{
			XHANDLE(EFI_WARN_DELETE_FAILURE);
			XHANDLE(EFI_WARN_WRITE_FAILURE);
			XHANDLE(EFI_WARN_BUFFER_TOO_SMALL);
		}
#undef XHANDLE
	}
	return 0;
}

struct OSBootData
{
	UINT32 screenX;
	UINT32 screenY;
	UINT32 screenStride;
	UINT32 *screenPtr;
	UINT8 screenFormat;
};

EFI_MEMORY_DESCRIPTOR *Memmap;
UINTN MemmapSize=0, MemmapDescriptorSize, MemmapKey, LastMemmapPages;
UINT32 MemmapDescriptorVersion;

EFI_GRAPHICS_OUTPUT_PROTOCOL *GOP;
EFI_GUID GOP_GUID = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
UINT32 *Gpixels;
UINT32 Gstride;
UINT64 GpixelsN;
UINT8 GisBGR;
CHAR16 tmpstr[64];

int POTS[] =
{
	1, // 0
	10,
	100,
	1000,
	10000,
	100000,
	1000000,
	10000000,
	100000000,
	1000000000 // 9
};

void tmpItoa(int v)
{
	CHAR16* ptr = tmpstr;
	if(v==0)
	{
		*(ptr++) = '0';
	}
	else
	{
		if(v<0)
		{
			v=-v;
			*(ptr++) = '-';
		}
		UINT8 f = 0;
		for(int i=9; i>=0; i--)
		{
			if(f || v>=POTS[i])
			{
				f = 1;
				int dg = (v/POTS[i]);
				*(ptr++) = (CHAR16)(dg)+'0';
				v -= dg * POTS[i];
			}
		}
	}
	*(ptr++) = '\0';
}

char CPUVendor[13];
CHAR16 LCPUVendor[13];

void DoEarlyCPUID()
{
	CPUVendor[12] = '\0';
	LCPUVendor[12] = '\0';
	int v0,v1,v2;
	asm volatile (
	    "xorl %%eax, %%eax \n"
	    "cpuid \n"
	    "movl %%ebx, %0 \n"
	    "movl %%edx, %1 \n"
	    "movl %%ecx, %2 "
	    : "=r"(v0), "=r"(v1), "=r"(v2)
	    : /*no ins*/
	    : "eax","ebx","edx","ecx"
	);
	*(int*)(&CPUVendor[0]) = v0;
	*(int*)(&CPUVendor[4]) = v1;
	*(int*)(&CPUVendor[8]) = v2;
	for(int i=0; i<12; i++)LCPUVendor[i]=(CHAR16)CPUVendor[i];
}

void LoadProtocols()
{
	CheckedRun(ST->BootServices->LocateProtocol(&GOP_GUID, NULL, (void**)(&GOP)),L"Failed to acquire GOP");
}

void LoadMemoryMap()
{
	ST->BootServices->GetMemoryMap(&MemmapSize,NULL,&MemmapKey,&MemmapDescriptorSize,&MemmapDescriptorVersion);
	do
	{
		if(LastMemmapPages>0)
		{
			ST->BootServices->FreePages((UINTN)Memmap, LastMemmapPages);
		}
		LastMemmapPages = (MemmapSize/4096)+1;
		MemmapSize = LastMemmapPages*4096;
		Status = ST->BootServices->AllocatePages(AllocateAnyPages, EfiLoaderData, LastMemmapPages, (UINTN*)(&Memmap));
		CheckedRun(Status, L"Failed to allocate memory for map");
		Status = ST->BootServices->GetMemoryMap(&MemmapSize,Memmap,&MemmapKey,&MemmapDescriptorSize,&MemmapDescriptorVersion);
	}
	while(Status==EFI_BUFFER_TOO_SMALL);
	CheckedRun(Status, L"Could not obtain memory map");
}

void SetVideoMode(int maxx, int maxy)
{
	EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE *cmode = GOP->Mode;
	int nmodes = cmode->MaxMode;
	EFI_GRAPHICS_OUTPUT_MODE_INFORMATION *qmode;
	EFI_GRAPHICS_OUTPUT_MODE_INFORMATION bestmode;
	int bestmodeid = -1;
	for(int i=0; i<nmodes; i++)
	{
		UINTN bsize = sizeof(EFI_GRAPHICS_OUTPUT_MODE_INFORMATION);
		CheckedRun(GOP->QueryMode(GOP, i, &bsize, &qmode),L"Querying video mode");
		ShowBootString(L"Found vmode: ");
		tmpItoa((int)qmode->HorizontalResolution);
		ShowBootString(tmpstr);
		ShowBootString(L" * ");
		tmpItoa((int)qmode->VerticalResolution);
		ShowBootString(tmpstr);
		ShowBootString(L" | ");
		if(bestmodeid==-1)
		{
			bestmode = *qmode;
			bestmodeid = i;
		}
		else
		{
			if((qmode->HorizontalResolution >= bestmode.HorizontalResolution)
			        && (qmode->VerticalResolution >= bestmode.VerticalResolution)
			        && (qmode->HorizontalResolution <= maxx)
			        && (qmode->VerticalResolution <= maxy)
			        && (qmode->PixelFormat != PixelBltOnly))
			{
				bestmode = *qmode;
				bestmodeid = i;
			}
		}
	}
	CheckedRun( GOP->SetMode(GOP, bestmodeid), L"Failed to set video mode!");
	ST->ConOut->ClearScreen(ST->ConOut);
	Gstride = bestmode.PixelsPerScanLine;
	GisBGR = (bestmode.PixelFormat==PixelBlueGreenRedReserved8BitPerColor)?1:0;
	Gpixels = (int*)GOP->Mode->FrameBufferBase;
	GpixelsN = GOP->Mode->FrameBufferSize;
}

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
	EFI_STATUS Status;
	EFI_INPUT_KEY Key;
	ST = SystemTable;
	ST->BootServices->SetWatchdogTimer(0, 0, 0, NULL);
	LoadProtocols();

	ShowBootStringLn(L"Setting video mode");
	SetVideoMode(1600, 900);

	ShowBootStringLn(L"NovuOS UEFI Loader");
	DoEarlyCPUID();
	ShowBootString(L"CPU: ");
	ShowBootStringLn(LCPUVendor);
	ShowBootString(L"Set video mode: ");
	tmpItoa(bestmode.HorizontalResolution);
	ShowBootString(tmpstr);
	ShowBootString(L" * ");
	tmpItoa(bestmode.VerticalResolution);
	ShowBootString(tmpstr);
	ShowBootString(L"\r\n");

	ShowBootStringLn(L"Getting memory map");
	LoadMemoryMap();
	ShowBootStringLn(L"Memory map obtained");


#if 1
	ShowBootStringLn(L"Press key...");

	for(int iy=16; iy<512; iy++)
	{
		for(int ix=512; ix<1200; ix++)
		{
			int R = (ix*255)/1200;
			int G = (iy*255)/512;
			int B = (R+G)/2;
			Gpixels[ Gstride*iy + ix ] = R + G<<4 + B<<8;
		}
	}

	Status = ST->ConIn->Reset(ST->ConIn, FALSE);
	if (EFI_ERROR(Status))
		return Status;

	while ((Status = ST->ConIn->ReadKeyStroke(ST->ConIn, &Key)) == EFI_NOT_READY) ;
#endif

	ST->BootServices->ExitBootServices(ImageHandle, MemmapKey);

	return Status;
}
