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
    EFI_SYSTEM_TABLE* ST;
    EFI_BOOT_SERVICES* BS;
    EFI_HANDLE ImageHandle;
    FILEPATH_DEVICE_PATH* KernelPath;
    EFI_LOADED_IMAGE_PROTOCOL* LIP;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL* SFSP;
    EFI_FILE_PROTOCOL* RootDir;
    wchar[3] NewLine = ['\r', '\n', '\0'];
    wchar[64] StrBuffer;
    ubyte[] KernelImage;
    ulong KernelStackPhys;
    ulong KernelStackPtr;
    ulong KernelEntryPoint;
    enum KernelStackSize = 4; // in 4KiB units
    ubyte* PageTables;
    size_t PagesSize;
    size_t PageFree;

    EFI_MEMORY_DESCRIPTOR* Memmap;
    UINTN MemmapSize = 0, MemmapDescriptorSize, MemmapKey, LastMemmapPages;
    UINT32 MemmapDescriptorVersion;
}

extern (C) void* _Dmodule_ref;
extern (C) void* _tls_index = null;

@nogc:
nothrow:

extern (C) void _d_assert_msg(string msg, string file, uint line)
{
}

extern (C) void* memcpy(void* dst, void* src, size_t n)
{
    ubyte* D = cast(ubyte*) dst;
    ubyte* S = cast(ubyte*) src;
    while (n)
    {
        *D++ = *S++;
        n--;
    }
    return dst;
}

extern (C) void* memset(void* dst, int vv, size_t n)
{
    ubyte* D = cast(ubyte*) dst;
    ubyte V = cast(ubyte) vv;
    while (n)
    {
        *D++ = V;
        n--;
    }
    return dst;
}

void itoaBuffer(int v)
{
    int[10] POTS = [1, // 0
    10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 // 9
    ];
    wchar* ptr = StrBuffer.ptr;
    if (v == 0)
    {
        *(ptr++) = '0';
    }
    else
    {
        if (v < 0)
        {
            v = -v;
            *(ptr++) = '-';
        }
        bool f = false;
        for (int i = 9; i >= 0; i--)
        {
            if (f || v >= POTS[i])
            {
                f = true;
                int dg = (v / POTS[i]);
                *(ptr++) = cast(wchar)(dg + '0');
                v -= dg * POTS[i];
            }
        }
    }
    *(ptr++) = '\0';
}

void itoxBuffer(int vs)
{
    uint[8] POTS = [1, // 0
    0x10, 0x100, 0x1000, 0x10000, 0x100000, 0x1000000, 0x10000000];
    uint v = cast(uint) vs;
    wchar* ptr = StrBuffer.ptr;
    *(ptr++) = '0';
    *(ptr++) = 'x';
    if (v == 0)
    {
        *(ptr++) = '0';
    }
    else
    {
        bool f = false;
        for (int i = 7; i >= 0; i--)
        {
            if (f || v >= POTS[i])
            {
                f = true;
                int dg = (v / POTS[i]);
                if (dg < 10)
                    *(ptr++) = cast(wchar)(dg + '0');
                else
                    *(ptr++) = cast(wchar)(dg - 10 + 'A');
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

void ShowBootNumberX(int v)
{
    itoxBuffer(v);
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
    int sti = cast(int) st;
    if (sti < 0)
    {
        ShowBootString("[ERR:"w);
        ShowBootNumber(sti);
        ShowBootString("] ");
        ShowBootStringLn(msg);
        while (1)
        {
        }
    }
    else if (sti > 0)
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
    CheckEfiCode(BS.HandleProtocol(ImageHandle, &LIP_GUID,
        cast(void**)&LIP), "Acquiring Loaded Image Protocol");
    GUID GOP_GUID = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
    CheckEfiCode(BS.LocateProtocol(&GOP_GUID, null,
        cast(void**)(&BootData.GOP)), "Acquiring Graphics Output Protocol"w);
    GUID SFSP_GUID = EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID;
    CheckEfiCode(BS.LocateProtocol(&SFSP_GUID, null, cast(void**)(&SFSP)),
        "Acquiring Simple FS Protocol"w);
    CheckEfiCode(SFSP.OpenVolume(SFSP, (&RootDir)), "Opening root dir of volume"w);
}

void SetVideoMode(int maxx, int maxy)
{
    EFI_GRAPHICS_OUTPUT_PROTOCOL* GOP = BootData.GOP;
    EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE* cmode = GOP.Mode;
    int nmodes = cmode.MaxMode;
    EFI_GRAPHICS_OUTPUT_MODE_INFORMATION* qmode;
    EFI_GRAPHICS_OUTPUT_MODE_INFORMATION bestmode;
    int bestmodeid = -1;
    ShowBootStringLn("Found vmodes: "w);
    for (int i = 0; i < nmodes; i++)
    {
        UINTN bsize = EFI_GRAPHICS_OUTPUT_MODE_INFORMATION.sizeof;
        CheckEfiCode(GOP.QueryMode(GOP, i, &bsize, &qmode), "Querying video mode"w);
        ShowBootNumber(cast(int) qmode.HorizontalResolution);
        ShowBootString(" * "w);
        ShowBootNumber(cast(int) qmode.VerticalResolution);
        ShowBootString(" ; "w);
        if (bestmodeid == -1)
        {
            bestmode = *qmode;
            bestmodeid = i;
        }
        else
        {
            if ((qmode.HorizontalResolution >= bestmode.HorizontalResolution)
                    && (qmode.VerticalResolution >= bestmode.VerticalResolution)
                    && (qmode.HorizontalResolution <= maxx)
                    && (qmode.VerticalResolution <= maxy) && (qmode.PixelFormat != PixelBltOnly))
            {
                bestmode = *qmode;
                bestmodeid = i;
            }
        }
    }
    CheckEfiCode(GOP.SetMode(GOP, bestmodeid), "Failed to set video mode!"w);
    ST.ConOut.ClearScreen(ST.ConOut);
    BootFramebufferFormat pfmt = void;
    if (bestmode.PixelFormat == PixelBlueGreenRedReserved8BitPerColor)
    {
        pfmt = BootFramebufferFormat.BGR;
    }
    else
    {
        pfmt = BootFramebufferFormat.RGB;
    }
    BootData.FB = BootFramebuffer(GOP.Mode.FrameBufferSize,
        bestmode.HorizontalResolution, bestmode.VerticalResolution,
        bestmode.PixelsPerScanLine, pfmt, cast(uint*)(GOP.Mode.FrameBufferBase));
}

void FetchMemoryMap()
{
    EFI_STATUS Status;
    BS.GetMemoryMap(&MemmapSize, null, &MemmapKey, &MemmapDescriptorSize,
        &MemmapDescriptorVersion);
    do
    {
        if (LastMemmapPages > 0)
        {
            BS.FreePages(cast(UINTN) Memmap, LastMemmapPages);
        }
        LastMemmapPages = (MemmapSize / 4096) + 1;
        MemmapSize = LastMemmapPages * 4096;
        Status = BS.AllocatePages(AllocateAnyPages, EfiLoaderData,
            LastMemmapPages, cast(UINTN*)(&Memmap));
        CheckEfiCode(Status, "Failed to allocate memory for map"w);
        Status = BS.GetMemoryMap(&MemmapSize, Memmap, &MemmapKey,
            &MemmapDescriptorSize, &MemmapDescriptorVersion);
    }
    while (Status == EFI_BUFFER_TOO_SMALL);
    CheckEfiCode(Status, "Could not obtain memory map"w);
}

void FillStatus(uint color)
{
    foreach (int ix; 256 .. 300)
    {
        foreach (int iy; 32 .. 76)
        {
            BootData.FB.pixels[iy * BootData.FB.stride + ix] = color;
        }
    }
}

void EnableSSE()
{
    asm @nogc nothrow
    {
        mov RAX, CR0;
        and AX, 0xFFFB;
        or AX, 0x2;
        mov CR0, RAX;
        mov RAX, CR4;
        or AX, 3 << 9;
        mov CR4, RAX;

        xorps XMM0, XMM0; // test if it works
    }
}

void LoadKernelImage()
{
    EFI_FILE_PROTOCOL* fp;
    EFI_STATUS Status = RootDir.Open(RootDir, &fp,
        cast(CHAR16*)("\\EFI\\BOOT\\novuos.elf"w.ptr), EFI_FILE_MODE_READ, 0);
    if (Status == EFI_NOT_FOUND)
    {
        ShowBootStringLn("Could not find kernel image"w);
        while (1)
        {
        }
    }
    CheckEfiCode(Status, "Could not open kernel image file"w);
    GUID Fiid = EFI_FILE_INFO_ID;
    align(16) ubyte[EFI_FILE_INFO.sizeof + 256] InfoBuffer = void;
    ulong fisz = InfoBuffer.length;
    CheckEfiCode(fp.GetInfo(fp, &Fiid, &fisz, cast(void*)(InfoBuffer.ptr)), "Getting file info"w);
    EFI_FILE_INFO* fi = cast(EFI_FILE_INFO*)(InfoBuffer.ptr);
    ShowBootString("File size: "w);
    int filesz = cast(int) fi.FileSize;
    ShowBootNumber(filesz);
    ShowBootStringLn(" bytes"w);

    // allocate memory
    ubyte* fdptr;
    int afsz = (filesz / 4096) + 1;
    Status = BS.AllocatePages(AllocateAnyPages, EfiLoaderData, afsz, cast(UINTN*)(&fdptr));
    CheckEfiCode(Status, "Failed to allocate memory for kimage"w);
    KernelImage = fdptr[0 .. afsz * 4096];
    // load file
    fisz = KernelImage.length;
    CheckEfiCode(fp.Read(fp, &fisz, cast(void*)(KernelImage.ptr)), "Reading kimage"w);
    fp.Close(fp);
    RootDir.Close(RootDir);
}

void AllocPages(size_t* sz, ubyte** ptr)
{
    *ptr = null;
    long psz = ((*sz) / 4096) + 1;
    *sz = psz * 4096;
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
    ElfHeader* ehdr = cast(ElfHeader*) KernelImage.ptr;
    if (ehdr.magicNumber != ElfHeader.Magic)
    {
        ShowBootString("Kernel image is not in ELF format! Magic:"w);
        ShowBootNumber(ehdr.magicNumber);
        ShowBootString("\r\n"w);
        while (1)
        {
        }
    }
    if (ehdr.architecture != ElfArch.ELF64)
    {
        ShowBootString("Kernel image is not in ELF64 architecture! Arch:"w);
        ShowBootNumber(cast(int) ehdr.architecture);
        ShowBootString("\r\n"w);
        while (1)
        {
        }
    }
    if (ehdr.iset != ElfInstructionSet.X86_64)
    {
        ShowBootString("Kernel image is not in x64 instruction set! Iset:"w);
        ShowBootNumber(cast(int) ehdr.iset);
        ShowBootString("\r\n"w);
        while (1)
        {
        }
    }
    KernelEntryPoint = ehdr.entryPoint;
    ElfProgramHeader* eph = cast(ElfProgramHeader*)(KernelImage.ptr + ehdr.programHeaderPos);
    ElfProgramHeader* sections = cast(ElfProgramHeader*)(KernelImage.ptr + ehdr.programHeaderPos);
    size_t sect = ehdr.programHeaderEntrySize;
    static struct KSect
    {
        ElfProgramHeader* S;
        UINTN sz;
        ubyte* pptr;
        ubyte* vptr;
    }

    KSect[8] kSects = void;
    int nSects = 0;
    for (size_t si = 0; si < ehdr.programHeaderEntryCount; si++)
    {
        ElfProgramHeader* header = sections + (si * sect);
        if (header.segmentType != ElfProgramSegmentType.ZeroAndLoad)
            continue;
        kSects [nSects].S = header;
        kSects [nSects].sz = header.memSize;
        kSects [nSects].vptr = cast(ubyte*)(header.dataVaddr);
        if (header.dataVaddr > KernelStackPtr)
        {
            KernelStackPtr = header.dataVaddr + header.memSize;
        }
        AllocPages(&kSects[nSects].sz, &kSects[nSects].pptr);
        pagesrqred += (kSects[nSects].sz / 4096) + 1;
        size_t len = kSects[nSects].sz;
        ZeroMem(kSects[nSects].pptr[0 .. len]);
        ubyte* fptr = cast(ubyte*)(KernelImage.ptr + header.dataOffset);
        if (header.fileSize > 0)
        {
            llvm_memcpy(kSects[nSects].pptr, fptr, header.fileSize, 8);
        }
        nSects++;
    }

    PagesSize = 4096 * (pagesrqred + 128);
    ulong _tmp = KernelStackSize * 4096;
    AllocPages(&_tmp, cast(ubyte**)(&KernelStackPhys));
    AllocPages(&PagesSize, &PageTables);
    PageFree = 4096;
    FetchMemoryMap();
    setupPageTableIdentity((cast(PagePML4E*) PageTables)[0 .. 512]);
    static PagePTE* getPage(const(void)* addr) nothrow @nogc
    {
        PageStructureIndices psi;
        getAddressPage(addr, &psi);
        // Check PML4E
        PagePML4E* p4 = cast(PagePML4E*) PageTables;
        p4 += psi.Level4;
        if (p4.P.value == 0)
        {
            p4.RW.value = 1;
            p4.Addr.value = cast(ulong)(PageTables + PageFree) >> p4.Addr.shift;
            *cast(ulong*)(PageTables + PageFree) = 0;
            PageFree += 4096;
            ShowBootString("New PML4E for ");
            ShowBootNumberX(cast(int) psi.Level4);
            ShowBootString("\r\n");
            p4.P.value = 1;
        }
        PagePDPE* p3 = cast(PagePDPE*)(p4.Addr.value << p4.Addr.shift);
        p3 += psi.Level3;
        if (p3.P.value == 0)
        {
            p3.RW.value = 1;
            p3.Addr.value = cast(ulong)(PageTables + PageFree) >> p3.Addr.shift;
            *cast(ulong*)(PageTables + PageFree) = 0;
            PageFree += 4096;
            ShowBootString("New PDPE for ");
            ShowBootNumberX(cast(int) psi.Level3);
            ShowBootString("\r\n");
            p3.P.value = 1;
        }
        PagePDE_4k* p2 = cast(PagePDE_4k*)(p3.Addr.value << p3.Addr.shift);
        p2 += psi.Level2;
        if (p2.P.value == 0)
        {
            p2.RW.value = 1;
            p2.Addr.value = cast(ulong)(PageTables + PageFree) >> p2.Addr.shift;
            *cast(ulong*)(PageTables + PageFree) = 0;
            PageFree += 4096;
            ShowBootString("New PDE for ");
            ShowBootNumberX(cast(int) psi.Level2);
            ShowBootString("\r\n");
            p2.P.value = 1;
        }
        PagePTE* p1 = cast(PagePTE*)(p2.Addr.value << p2.Addr.shift);
        p1 += psi.Level1;
        if (p1.P.value == 0)
        {
            p1.field = 0;
            p1.RW.value = 1;
            p1.P.value = 1;
            p1.Addr.value = ((cast(ulong) addr >> p1.Addr.shift) & p1.Addr.shmask); // default: identity
        }
        if (PageFree >= PagesSize)
        {
            ShowBootStringLn("[ERR] Out of pages");
            while (1)
            {
            }
        }
        return p1;
    }

    static void setEfiPages(EFI_MEMORY_DESCRIPTOR* md) nothrow @nogc
    {
        void* addr = cast(void*)(md.PhysicalStart);
        for (int pagei = 0; pagei < md.NumberOfPages; pagei++)
        {
            getPage(addr + pagei * 4096);
        }
    }

    ShowBootStringLn("Kernel image allocated OK");
    // first 4 megabytes: identity
    for (ulong addr = 0; addr < 0x40000; addr += 0x4000)
    {
        getPage(cast(void*) addr);
    }
    // memory map entries
    void* VMemmap = cast(void*)(Memmap);
    for (void* vme = VMemmap; vme < (VMemmap + MemmapSize); vme += MemmapDescriptorSize)
    {
        EFI_MEMORY_DESCRIPTOR* me = cast(EFI_MEMORY_DESCRIPTOR*) vme;
        switch (me.Type)
        {
        case EfiLoaderCode, EfiLoaderData, EfiBootServicesCode,
                EfiBootServicesData, EfiRuntimeServicesCode,
                EfiRuntimeServicesData, EfiACPIReclaimMemory, EfiACPIMemoryNVS,
        EfiPalCode:
                setEfiPages(me);
            break;
        default:
            break;
        }
        me.VirtualStart = me.PhysicalStart;
        for (size_t si = 0; si < nSects; si++)
        {
            if (me.PhysicalStart == cast(ulong)(kSects[si].pptr))
            {
                me.VirtualStart = cast(ulong)(kSects[si].vptr);
            }
        }
    }
    // kernel
    for (size_t si = 0; si < nSects; si++)
    {
        KSect* ks = &kSects[si];
        int npages = cast(int) ks.sz / 4096;
        for (int page = 0; page < npages; page++)
        {
            PagePTE* pte = getPage(ks.vptr + page * 4096);
            pte.Addr.value = cast(ulong)(ks.pptr + page * 4096) >> pte.Addr.shift;
            pte.NX.value = 0;
        }
    }
    // kernel stack (align+allocate)
    KernelStackPtr = ((KernelStackPtr >> 12) + 1) << 12;
    for (int page = 0; page < KernelStackSize; page++)
    {
        PagePTE* pte = getPage(cast(void*)(KernelStackPtr + page * 4096));
        pte.Addr.value = cast(ulong)(KernelStackPhys + page * 4096) >> pte.Addr.shift;
        pte.NX.value = 0;
    }
    ShowBootStringLn("Pages allocated OK");
}

void UpdateMemoryMap()
{
    FetchMemoryMap();
    void* VMemmap = cast(void*)(Memmap);
    for (void* vme = VMemmap; vme < (VMemmap + MemmapSize); vme += MemmapDescriptorSize)
    {
        EFI_MEMORY_DESCRIPTOR* me = cast(EFI_MEMORY_DESCRIPTOR*) vme;
        me.VirtualStart = me.PhysicalStart;
    }
}

void ExecuteKernel()
{
    // update bootdata
    // kernel signature: extern(C) void kmain(OSBootData* bootdata) @nogc nothrow
    ulong kmain = KernelEntryPoint;
    // paging & jump
    EFI_STATUS status = ST.RuntimeServices.SetVirtualAddressMap(MemmapSize,
        MemmapDescriptorSize, MemmapDescriptorVersion, Memmap);
    if (status != 0)
    {
        FillStatus(0x00770077 + cast(int) status);
        while (1)
        {
        }
    }
    ulong ptptr = cast(ulong)(PageTables);
    ulong bdptr = cast(ulong)(&BootData);
    ulong ksptr = cast(ulong)(KernelStackPtr);
    ksptr += KernelStackSize * 4096 - 1;
    FillStatus(0x000000FF);
    asm nothrow @nogc
    {
        cli;
        mov R11, ptptr;
        mov R12, ksptr;
        mov R13, bdptr;
        mov R14, CR4;
        and R14,  ~ 128L;
        mov CR4, R14;
        mov CR3, R11;

		mov R15, 0xDEADBEEF;
        xor RSI, RSI;
        xor RDX, RDX;
        xor RCX, RCX;
        xor R8, R8;
        mov RSP, ksptr;
        mov RAX, kmain;
		andps XMM0, XMM0;
        jmp RAX;
    xloop:
        cli;
        hlt;
        jmp xloop;
    }
}

//extern(C) ulong etext;

extern (C) EFI_STATUS efi_main(EFI_HANDLE ImageHandle_, EFI_SYSTEM_TABLE* SystemTable)
{
    ImageHandle = ImageHandle_;
    ST = SystemTable;
    BS = ST.BootServices;
    BootData.ST = ST;
    BS.SetWatchdogTimer(0, 0, 0, null);
    LoadProtocols();
    SetVideoMode(1024, 768);
	ShowBootString("Image base: ");
	ShowBootNumberX(cast(int)(LIP.ImageBase));
	//ShowBootString("End of text: ");
	//ShowBootNumberX(cast(int)(etext));
    ShowBootStringLn("\r\nNovuOS UEFI bootloader"w);

    ShowBootString("Video mode: "w);
    ShowBootNumber(BootData.FB.w);
    ShowBootString("x"w);
    ShowBootNumber(BootData.FB.h);
    ShowBootString("\r\n"w);

    ShowBootStringLn("Loading kernel image..."w);
    LoadKernelImage();
    AllocateKernelImage();

    version (all)
    {
        ShowBootStringLn("Press key..."w);
        ST.ConIn.Reset(ST.ConIn, FALSE);
        EFI_INPUT_KEY Key = void;
        while (ST.ConIn.ReadKeyStroke(ST.ConIn, &Key) == EFI_NOT_READY)
        {
        }
    }
    ShowBootStringLn("Enabling SSE"w);
    EnableSSE();
    ShowBootStringLn("Executing OS image"w);
    ShowBootString("Address: ");
    ShowBootNumberX(cast(int)(KernelEntryPoint >> 32));
    ShowBootNumberX(cast(int)(KernelEntryPoint & 0xFFFFFFFF));
    FillStatus(0x00FF0000);
    UpdateMemoryMap();
    CheckEfiCode(BS.ExitBootServices(ImageHandle_, MemmapKey), "Exitting boot services");
    FillStatus(0x0000FF00);
    ExecuteKernel();
    while (1)
    {
    }
}
