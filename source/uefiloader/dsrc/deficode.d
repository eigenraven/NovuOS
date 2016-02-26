module deficode;

import uefi;
import uefi.protocols.simplefilesystem;
import novuos.bootdata;
import novuos.formats.elf;
import novuos.memory.pager;
import ldc.intrinsics;

__gshared
{
	OSBootData BootData;
	EFI_SYSTEM_TABLE *ST;
	EFI_BOOT_SERVICES *BS;
    EFI_HANDLE ImageHandle;
    FILEPATH_DEVICE_PATH *KernelPath;
    EFI_LOADED_IMAGE_PROTOCOL *LIP;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *SFSP;
    EFI_FILE_PROTOCOL *RootDir;
	wchar[3] NewLine = ['\r','\n','\0'];
	wchar[64] StrBuffer;
    ubyte[] KernelImage;

	EFI_MEMORY_DESCRIPTOR *Memmap;
	UINTN MemmapSize=0, MemmapDescriptorSize, MemmapKey, LastMemmapPages;
	UINT32 MemmapDescriptorVersion;
}

extern(C) void* _Dmodule_ref;
extern(C) void* _tls_index = null;

@nogc:
nothrow:

extern(C) void* memcpy(void* dst, void* src, size_t n)
{
	ubyte* D = cast(ubyte*)dst;
	ubyte* S = cast(ubyte*)src;
	while(n)
	{
		*D++ = *S++;
		n--;
	}
	return dst;
}

extern(C) void* memset(void* dst, int vv, size_t n)
{
	ubyte* D = cast(ubyte*)dst;
	ubyte V = cast(ubyte)vv;
	while(n)
	{
		*D++ = V;
		n--;
	}
	return dst;
}

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
    GUID LIP_GUID = EFI_LOADED_IMAGE_PROTOCOL_GUID;
    CheckEfiCode(BS.HandleProtocol(ImageHandle, &LIP_GUID, cast(void**)&LIP),"Acquiring Loaded Image Protocol");
	GUID GOP_GUID = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
	CheckEfiCode(BS.LocateProtocol(&GOP_GUID, null, cast(void**)(&BootData.GOP)),"Acquiring Graphics Output Protocol"w);
    GUID SFSP_GUID = EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID;
    CheckEfiCode(BS.LocateProtocol(&SFSP_GUID, null, cast(void**)(&SFSP)),"Acquiring Simple FS Protocol"w);
    CheckEfiCode(SFSP.OpenVolume(SFSP, (&RootDir)), "Opening root dir of volume"w);
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

void EnableSSE()
{
	asm @nogc nothrow
	{
		mov RAX, CR0 ;
		and AX, 0xFFFB ;
		or AX, 0x2 ;
		mov CR0, RAX ;
		mov RAX, CR4 ;
		or AX, 3 << 9 ;
		mov CR4, RAX ;
		
		xorps XMM0, XMM0 ; // test if it works
	}
}

void LoadKernelImage()
{
    EFI_FILE_PROTOCOL* fp;
    EFI_STATUS Status = RootDir.Open(RootDir, &fp, cast(CHAR16*)("\\EFI\\BOOT\\novuos.elf"w.ptr),EFI_FILE_MODE_READ,0);
    if(Status==EFI_NOT_FOUND)
    {
        ShowBootStringLn("Could not find kernel image"w);
        while(1){}
    }
    CheckEfiCode(Status, "Could not open kernel image file"w);
    GUID Fiid = EFI_FILE_INFO_ID;
    align(16) ubyte[EFI_FILE_INFO.sizeof + 256] InfoBuffer = void;
    ulong fisz = InfoBuffer.length;
    CheckEfiCode(fp.GetInfo(fp, &Fiid, &fisz, cast(void*)(InfoBuffer.ptr)),"Getting file info"w);
    EFI_FILE_INFO* fi = cast(EFI_FILE_INFO*)(InfoBuffer.ptr);
    ShowBootString("File size: "w);
    int filesz = cast(int)fi.FileSize;
    ShowBootNumber(filesz);
    ShowBootStringLn(" bytes"w);
    
    // allocate memory
    ubyte* fdptr;
    int afsz = (filesz/4096)+1;
    Status = BS.AllocatePages(AllocateAnyPages, EfiLoaderData, afsz, cast(UINTN*)(&fdptr));
	CheckEfiCode(Status, "Failed to allocate memory for kimage"w);
    KernelImage = fdptr[0 .. afsz*4096];
    // load file
    fisz = KernelImage.length;
    CheckEfiCode(fp.Read(fp, &fisz, cast(void*)(KernelImage.ptr)),"Reading kimage"w);
    fp.Close(fp);
    RootDir.Close(RootDir);
}

void AllocPages(size_t *sz, ubyte** ptr)
{
	*ptr = null;
	long psz = ((*sz)/4096)+1;
	*sz = psz*4096;
	auto Status = BS.AllocatePages(AllocateAnyPages, EfiLoaderData, psz, cast(UINTN*)(ptr));
	CheckEfiCode(Status, "Failed to allocate memory"w);
}

private void ZeroMem(ubyte[] mem)
{
	llvm_memset(mem.ptr, 0, mem.length, 8);
}

void AllocateKernelImage()
{
	int pagesrqred;
	ElfHeader* ehdr = cast(ElfHeader*)KernelImage.ptr;
	if(ehdr.magicNumber != ElfHeader.Magic)
	{
		ShowBootString("Kernel image is not in ELF format! Magic:"w);
		ShowBootNumber(ehdr.magicNumber);
		ShowBootString("\r\n"w);
		while(1){}
	}
	if(ehdr.architecture != ElfArch.ELF64)
	{
		ShowBootString("Kernel image is not in ELF64 architecture! Arch:"w);
		ShowBootNumber(cast(int)ehdr.architecture);
		ShowBootString("\r\n"w);
		while(1){}
	}
	if(ehdr.iset != ElfInstructionSet.X86_64)
	{
		ShowBootString("Kernel image is not in x64 instruction set! Iset:"w);
		ShowBootNumber(cast(int)ehdr.iset);
		ShowBootString("\r\n"w);
		while(1){}
	}
	ElfProgramHeader* eph = cast(ElfProgramHeader*)(KernelImage.ptr + ehdr.programHeaderPos);
	void* sections = cast(ElfSectionHeader*)(KernelImage.ptr + ehdr.sectionHeaderPos);
	size_t sect = ehdr.sectionHeaderSizeEntrySize;
	static struct KSect
	{
		ElfSectionHeader* S;
		UINTN sz;
		ubyte* pptr;
		ubyte* vptr;
	}
	KSect[32] kSects = void;
	int nSects = 0;
	for(size_t si = 0; si<ehdr.sectionHeaderSizeEntryCount; si++)
	{
		ElfSectionHeader* section = cast(ElfSectionHeader*)(&sections[si * ehdr.sectionHeaderSizeEntrySize]);
		if((section.flags & ElfSectionFlags.Alloc)==0)continue;
		kSects[nSects].S = section;
		kSects[nSects].sz = section.size;
		AllocPages(&kSects[nSects].sz,&kSects[nSects].pptr);
		pagesrqred += kSects[nSects].sz/4096;
		size_t len = kSects[nSects].sz;
		ZeroMem(kSects[nSects].pptr[0..len]);
		kSects[nSects].vptr = cast(ubyte*)(section.dataVaddr);
		ubyte* fptr = cast(ubyte*)(KernelImage.ptr + section.dataOffset);
		switch(section.type) with(ElfSectionType)
		{
			case ProgBits:
				llvm_memcpy(kSects[nSects].pptr, fptr, len, 4);
				break;
			case NoBits:
				break;
			default:
				break;
		}
	}
	ShowBootStringLn("Kernel image allocated OK");
	
}

extern(C) EFI_STATUS efi_main(EFI_HANDLE ImageHandle_, EFI_SYSTEM_TABLE *SystemTable)
{
    ImageHandle = ImageHandle_;
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
    
    ShowBootStringLn("Loading kernel image..."w);
    LoadKernelImage();
	AllocateKernelImage();
    
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
	ShowBootStringLn("Enabling SSE"w);
	EnableSSE();
	ShowBootStringLn("Executing OS image"w);

	while(1){}
}


