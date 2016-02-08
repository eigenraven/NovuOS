module deficode;

import uefi;
import novuos.bootdata;

__gshared
{
	OSBootData BootData;
	EFI_SYSTEM_TABLE *ST;
	EFI_BOOT_SERVICES *BS;
	wchar[3] NewLine = ['\r','\n','\0'];
	wchar[64] StrBuffer;

	EFI_MEMORY_DESCRIPTOR *Memmap;
	UINTN MemmapSize=0, MemmapDescriptorSize, MemmapKey, LastMemmapPages;
	UINT32 MemmapDescriptorVersion;
}

extern(C) void* _Dmodule_ref;
extern(C) void* _tls_index = null;

@nogc:
nothrow:

void itoaBuffer(int v)
{
	int[10] POTS = [
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
	];
	wchar* ptr = StrBuffer.ptr;
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
		bool f = false;
		for(int i=9; i>=0; i--)
		{
			if(f || v>=POTS[i])
			{
				f = true;
				int dg = (v/POTS[i]);
				*(ptr++) = cast(wchar)(dg+'0');
				v -= dg * POTS[i];
			}
		}
	}
	*(ptr++) = '\0';
}

void ShowBootNumber(int v)
{
	itoaBuffer(v);
	ST.ConOut.OutputString(ST.ConOut, StrBuffer.ptr);
}

void ShowBootString(const(wchar)[] lstr)
{
	ST.ConOut.OutputString(ST.ConOut, cast(CHAR16*)(lstr.ptr));
}

void ShowBootStringLn(const(wchar)[] lstr)
{
	ST.ConOut.OutputString(ST.ConOut, cast(CHAR16*)(lstr.ptr));
	ST.ConOut.OutputString(ST.ConOut, NewLine.ptr);
}

void CheckEfiCode(EFI_STATUS st, const(wchar)[] msg)
{
	int sti = cast(int)st;
	if(sti<0)
	{
		ShowBootString("[ERR:"w);
		ShowBootNumber(sti);
		ShowBootString("] ");
		ShowBootStringLn(msg);
		while(1){}
	}
	else if(sti>0)
	{
		ShowBootString("[WARN:"w);
		ShowBootNumber(sti);
		ShowBootString("] ");
		ShowBootStringLn(msg);
	}
}

void LoadProtocols()
{
	GUID GOP_GUID = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
	CheckEfiCode(BS.LocateProtocol(&GOP_GUID, null, cast(void**)(&BootData.GOP)),"Acquiring Graphics Output Protocl"w);
}

void SetVideoMode(int maxx, int maxy)
{
	EFI_GRAPHICS_OUTPUT_PROTOCOL* GOP = BootData.GOP;
	EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE *cmode = GOP.Mode;
	int nmodes = cmode.MaxMode;
	EFI_GRAPHICS_OUTPUT_MODE_INFORMATION *qmode;
	EFI_GRAPHICS_OUTPUT_MODE_INFORMATION bestmode;
	int bestmodeid = -1;
	ShowBootStringLn("Found vmodes: "w);
	for(int i=0; i<nmodes; i++)
	{
		UINTN bsize = EFI_GRAPHICS_OUTPUT_MODE_INFORMATION.sizeof;
		CheckEfiCode(GOP.QueryMode(GOP, i, &bsize, &qmode),"Querying video mode"w);
		ShowBootNumber(cast(int)qmode.HorizontalResolution);
		ShowBootString(" * "w);
		ShowBootNumber(cast(int)qmode.VerticalResolution);
		ShowBootString(" ; "w);
		if(bestmodeid==-1)
		{
			bestmode = *qmode;
			bestmodeid = i;
		}
		else
		{
			if((qmode.HorizontalResolution >= bestmode.HorizontalResolution)
			        && (qmode.VerticalResolution >= bestmode.VerticalResolution)
			        && (qmode.HorizontalResolution <= maxx)
			        && (qmode.VerticalResolution <= maxy)
			        && (qmode.PixelFormat != PixelBltOnly))
			{
				bestmode = *qmode;
				bestmodeid = i;
			}
		}
	}
	CheckEfiCode( GOP.SetMode(GOP, bestmodeid), "Failed to set video mode!"w);
	ST.ConOut.ClearScreen(ST.ConOut);
	BootFramebufferFormat pfmt = void;
	if(bestmode.PixelFormat==PixelBlueGreenRedReserved8BitPerColor)
	{
		pfmt = BootFramebufferFormat.BGR;
	}
	else
	{
		pfmt = BootFramebufferFormat.RGB;
	}
	BootData.FB = BootFramebuffer(GOP.Mode.FrameBufferSize,
		bestmode.HorizontalResolution,
		bestmode.VerticalResolution,
		bestmode.PixelsPerScanLine,
		pfmt,
		cast(uint*)(GOP.Mode.FrameBufferBase)
	);
}

void FetchMemoryMap()
{
	EFI_STATUS Status;
	BS.GetMemoryMap(&MemmapSize,null,&MemmapKey,&MemmapDescriptorSize,&MemmapDescriptorVersion);
	do
	{
		if(LastMemmapPages>0)
		{
			BS.FreePages(cast(UINTN)Memmap, LastMemmapPages);
		}
		LastMemmapPages = (MemmapSize/4096)+1;
		MemmapSize = LastMemmapPages*4096;
		Status = BS.AllocatePages(AllocateAnyPages, EfiLoaderData, LastMemmapPages, cast(UINTN*)(&Memmap));
		CheckEfiCode(Status, "Failed to allocate memory for map"w);
		Status = BS.GetMemoryMap(&MemmapSize,Memmap,&MemmapKey,&MemmapDescriptorSize,&MemmapDescriptorVersion);
	}
	while(Status==EFI_BUFFER_TOO_SMALL);
	CheckEfiCode(Status, "Could not obtain memory map"w);
}

void FillTestPattern()
{
	foreach(int ix; 0..BootData.FB.w)
	{
		foreach(int iy; 0..BootData.FB.h)
		{
			uint pixel = (iy)/3;
			pixel = (pixel + (pixel<<4) + (pixel<<8))&0xFFFFFF;
			BootData.FB.pixels[iy*BootData.FB.stride + ix] = pixel;
		}
	}
}

extern(C) EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
	ST = SystemTable;
	BS = ST.BootServices;
	BootData.ST = ST;
	BS.SetWatchdogTimer(0, 0, 0, null);
	LoadProtocols();
	SetVideoMode(1024, 768);
	ShowBootStringLn("NovuOS UEFI bootloader"w);
	
	ShowBootString("Video mode: "w);
	ShowBootNumber(BootData.FB.w);
	ShowBootString("x"w);
	ShowBootNumber(BootData.FB.h);
	ShowBootString("\r\n"w);

	ShowBootStringLn("Getting memory map"w);
	FetchMemoryMap();
	ShowBootStringLn("Memory map obtained"w);

	//FillTestPattern();

	version(all)
	{
		ShowBootStringLn("Press key..."w);
		ST.ConIn.Reset(ST.ConIn, FALSE);
		EFI_INPUT_KEY Key = void;
		while(ST.ConIn.ReadKeyStroke(ST.ConIn, &Key)==EFI_NOT_READY)
		{}
	}

	ShowBootStringLn("Executing OS image"w);

	while(1){}
}

