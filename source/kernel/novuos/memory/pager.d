/// Page-management code
/// Maps the last PML4E to itself => recursive paging
module novuos.memory.pager;

import novuos.basictypes;

enum PageSize : ubyte
{
	Size4k = 0,
	Size2m = 1
}

struct PagePML4E
{
	@disable this();
	ulong field; /// Raw field

	alias P = BitField!(ulong, field, 1, 0); /// Present
	alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
	alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
	alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
	alias PCD = BitField!(ulong, field, 1, 4); /// Page-level cache disable
	alias A = BitField!(ulong, field, 1, 5); /// Accessed
	alias MBZ = BitField!(ulong, field, 2, 7); /// Must be zero
	alias AVL = BitField!(ulong, field, 3, 9); /// To software
	alias Addr = BitField!(ulong, field, 40, 12); /// Address
	alias AvailLong = BitField!(ulong, field, 11, 52); /// Available bits
	alias NX = BitField!(ulong, field, 1, 63); /// No-execute
}

alias StaticPageTable = align(4096) PagePML4E[512];

struct PagePDPE
{
	@disable this();
	ulong field; /// Raw field

	alias P = BitField!(ulong, field, 1, 0); /// Present
	alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
	alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
	alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
	alias PCD = BitField!(ulong, field, 1, 4); /// Page-level cache disable
	alias A = BitField!(ulong, field, 1, 5); /// Accessed
	alias MBZ = BitField!(ulong, field, 2, 7); /// Must be zero
	alias AVL = BitField!(ulong, field, 3, 9); /// To software
	alias Addr = BitField!(ulong, field, 40, 12); /// Address
	alias AvailLong = BitField!(ulong, field, 11, 52); /// Available bits
	alias NX = BitField!(ulong, field, 1, 63); /// No-execute
}

struct PagePDE_4k
{
	@disable this();
	ulong field; /// Raw field

	alias P = BitField!(ulong, field, 1, 0); /// Present
	alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
	alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
	alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
	alias PCD = BitField!(ulong, field, 1, 4); /// Page-level cache disable
	alias A = BitField!(ulong, field, 1, 5); /// Accessed
	alias SizeBit = BitField!(ulong, field, 1, 7); /// PageSize bit, must be 0
	alias AVL = BitField!(ulong, field, 3, 9); /// To software
	alias Addr = BitField!(ulong, field, 40, 12); /// Address
	alias AvailLong = BitField!(ulong, field, 11, 52); /// Available bits
	alias NX = BitField!(ulong, field, 1, 63); /// No-execute
}

struct PagePDE_2m
{
	@disable this();
	ulong field; /// Raw field

	alias P = BitField!(ulong, field, 1, 0); /// Present
	alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
	alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
	alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
	alias PCD = BitField!(ulong, field, 1, 4); /// Page-level cache disable
	alias A = BitField!(ulong, field, 1, 5); /// Accessed
	alias D = BitField!(ulong, field, 1, 6); /// Dirty
	alias SizeBit = BitField!(ulong, field, 1, 7); /// PageSize bit, must be 1
	alias G = BitField!(ulong, field, 1, 8); /// Global page
	alias AVL = BitField!(ulong, field, 3, 9); /// To software
	alias PAT = BitField!(ulong, field, 1, 12); /// Page attribute table
	alias Addr = BitField!(ulong, field, 39, 13); /// Address
	alias AvailLong = BitField!(ulong, field, 11, 52); /// Available bits
	alias NX = BitField!(ulong, field, 1, 63); /// No-execute
}

struct PagePTE
{
	@disable this();
	ulong field; /// Raw field

	alias P = BitField!(ulong, field, 1, 0); /// Present
	alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
	alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
	alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
	alias PCD = BitField!(ulong, field, 1, 4); /// Page-level cache disable
	alias A = BitField!(ulong, field, 1, 5); /// Accessed
	alias D = BitField!(ulong, field, 1, 6); /// Dirty
	alias PAT = BitField!(ulong, field, 1, 7); /// Page attribute table
	alias G = BitField!(ulong, field, 1, 8); /// Global page
	alias AVL = BitField!(ulong, field, 3, 9); /// To software
	alias Addr = BitField!(ulong, field, 40, 12); /// Address
	alias AvailLong = BitField!(ulong, field, 11, 52); /// Available bits
	alias NX = BitField!(ulong, field, 1, 63); /// No-execute
}

enum PageLvl4Shift = 39;
enum PageLvl3Shift = 30;
enum PageLvl2Shift = 21;
enum PageLvl1Shift = 12;
private enum ulong UpperHalfMask = 0xFFFFL << 48;
/// The index of the recursive PML4E page
enum ulong PageRecursiveIdx = 510;
enum PageLvl4Addr = cast(PagePML4E*)(
		UpperHalfMask | (PageRecursiveIdx << PageLvl4Shift) | (PageRecursiveIdx << PageLvl3Shift) | (
		PageRecursiveIdx << PageLvl2Shift) | (PageRecursiveIdx << PageLvl1Shift));
enum PageLvl3Addr = cast(PagePDPE*)(
		UpperHalfMask | (PageRecursiveIdx << PageLvl4Shift) | (PageRecursiveIdx << PageLvl3Shift) | (
		PageRecursiveIdx << PageLvl2Shift));
enum PageLvl2Addr_4k = cast(PagePDE_4k*)(
		UpperHalfMask | (PageRecursiveIdx << PageLvl4Shift) | (PageRecursiveIdx << PageLvl3Shift));
enum PageLvl2Addr_2m = cast(PagePDE_2m*)(
		UpperHalfMask | (PageRecursiveIdx << PageLvl4Shift) | (PageRecursiveIdx << PageLvl3Shift));
enum PageLvl1Addr = cast(PagePTE*)(UpperHalfMask | (PageRecursiveIdx << PageLvl4Shift));

nothrow:
@nogc:

/// Initial paging structures setup (operates in 1:1 mapping mode)
void setupPageTableIdentity(PagePML4E[] pageTable)
{
	// zero all
	for (ushort i = 0; i < 512; i++)
	{
		pageTable[i].field = 0;
	}
	// recursive mapping
	pageTable[PageRecursiveIdx].Addr.value = cast(ulong)(pageTable.ptr) >> pageTable[
		PageRecursiveIdx].Addr.shift;
	pageTable[PageRecursiveIdx].P.value = 1;
	pageTable[PageRecursiveIdx].US.value = 0;
	pageTable[PageRecursiveIdx].RW.value = 1;

}

/// Or the upper half address mask if necessary
T* pageAddr(T)(const(T)* a)
{
	ulong A = cast(ulong) a;
	if (A & (1L << 47))
	{
		return a | UpperHalfMask;
	}
	else
	{
		return a;
	}
}

struct PageStructureIndices
{
	@disable this();
	ushort Level4 = void;
	ushort Level3 = void;
	ushort Level2 = void;
	ushort Level1 = void;
}

void getAddressPage(const(void)* VirtAddr, PageStructureIndices* psi)
{
	ulong RAddr = cast(ulong)(VirtAddr);
	psi.Level4 = (RAddr >> PageLvl4Shift) & 511;
	psi.Level3 = (RAddr >> PageLvl3Shift) & 511;
	psi.Level2 = (RAddr >> PageLvl2Shift) & 511;
	psi.Level1 = (RAddr >> PageLvl1Shift) & 511;
}
