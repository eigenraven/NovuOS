/// ELF 64-bit File format structure
module novuos.formats.elf;

enum ElfArch : ubyte
{
	ELF32 = 1,
	ELF64 = 2
}

enum ElfEndianness : ubyte
{
	Big = 1,
	Little = 2
}

enum ElfType : ushort
{
	Relocatable = 1,
	Executable = 2,
	Shared = 3,
	Core = 4
}

enum ElfInstructionSet : ushort
{
	X86 = 0x3,
	X86_64 = 0x3E,
	ARM = 0x28
}

struct ElfHeader
{
	align(1):
	uint magicNumber = 0x7f_45_4c_46;
	
	ElfArch architecture = ElfArch.ELF64;
	ElfEndianness endianness = ElfEndianness.Little;
	ubyte elfVersion = 1;
	ubyte osABI = 0;

	ulong pad0 = void;

	ElfType type = ElfType.Relocatable;
	ElfInstructionSet iset = ElfInstructionSet.X86_64;
	uint elfVersion2 = 1;

	ulong entryPoint;
	ulong programHeaderPos;
	ulong sectionHeaderPos;
	uint flags;

	ushort headerSize;
	ushort programHeaderEntrySize;
	ushort programHeaderEntryCount;
	ushort sectionHeaderSizeEntrySize;
	ushort sectionHeaderSizeEntryCount;
	ushort sectionNamesPos;
}

enum ElfProgramSegmentType : uint
{
    Ignore = 0,
    ZeroAndLoad = 1,
    DynamicLink = 2,
    Interpreted = 3,
    Notes = 4
}

enum ElfSegmentFlags : uint
{
    None = 0,
    Execute = 1,
    Write = 2,
    Read = 4,
    RX = Read+Execute,
    RWX = Read+Write+Execute,
    RW = Read+Write,
    WX = Write+Execute
}

struct ElfProgramHeader
{
	align(1):
	ElfProgramSegmentType segmentType;
    ElfSegmentFlags flags;
    ulong dataOffset;
    ulong dataVaddr;
    ulong pad0;
    ulong fileSize;
    ulong memSize;
    ulong alignment;
}
