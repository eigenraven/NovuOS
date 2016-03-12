module novuos.cpu.descriptors;

import novuos.basictypes;

extern (C) struct GDTDescriptor
{
align(1):
	ushort size;
	ulong offset;
}

extern (C) struct IDTDescriptor
{
align(1):
	ushort size;
	ulong offset;
}

enum GDTAccess : ubyte
{
	Accessed = 0x1,
	ReadWrite = 0x2,
	Direction = 0x4,
	Executable = 0x8,
	MustBeOne = 0x10,
	Ring0 = 0x0,
	Ring1 = 0x20,
	Ring2 = 0x40,
	Ring3 = 0x60,
	Present = 0x80
}

enum GDTFlags : ubyte
{
	Size64 = 0x20,
	Size32 = 0x40,
	PageGranularity = 0x80
}

extern (C) struct GDTEntry
{
align(1):
	ushort limitLow;
	ushort baseLow;
	ubyte baseMed;
	ubyte access;
	ubyte limitHighFlags;
	ubyte baseHigh;

	void limit(uint lim)
	{
		limitLow = lim & 0xFFFF;
		limitHighFlags = (limitHighFlags & 0xF0) | ((lim >> 16) & 0xF);
	}

	void base(uint bas)
	{
		baseLow = bas & 0xFFFF;
		baseMed = (bas >> 16) & 0xFF;
		baseHigh = (bas >> 24) & 0xFF;
	}
}

extern (C) struct IDTEntry
{
align(1):
	ushort offsetLow;
	ushort selector;
	ubyte zero;
	ubyte typeAndAttr;
	ushort offsetHigh;
	uint offsetHigh64;

	void offset(ulong off)
	{
		offsetLow = off & 0xFFFF;
		offsetHigh = (off >> 16) & 0xFFFF;
		offsetHigh64 = (off >> 32) & 0xFFFF_FFFF;
	}
	
	alias type = BitField!(ubyte, typeAndAttr, 4, 0);
	alias storage = BitField!(ubyte, typeAndAttr, 1, 4);
	alias dpl = BitField!(ubyte, typeAndAttr, 2, 5);
	alias present = BitField!(ubyte, typeAndAttr, 1, 7);
}

enum SystemSegmentType : ubyte
{
	LDT = 0x2,
	AvailableTSS = 0x9,
	BusyTSS = 0xB,
	CallGate = 0xC,
	InterruptGate = 0xE,
	TrapGate = 0xF
}

extern (C) struct SystemSegmentEntry
{
align(1):
	ushort limitLow;
	ushort baseLow;
	ubyte baseMed;
	ubyte typeAndFlags;
	ubyte limitAndGranularity;
	ubyte baseHigh;
	uint baseHigh64;
	uint reserved;
}

extern (C) struct GateEntry
{
align(1):
	ushort offsetLow;
	ushort selector;
	ubyte interruptStackTable;
	ubyte typeAndFlags;
	ushort offsetHigh;
	uint offsetHigh64;
	uint reserved;
}

void lgdt(GDTEntry* ptr, ushort size)
{
	GDTDescriptor idt;
	idt.offset = cast(size_t) ptr;
	idt.size = size;
	asm nothrow @nogc
	{
		lgdt idt;
	}
}

void lidt(IDTEntry* ptr, ushort size)
{
	IDTDescriptor idt;
	idt.offset = cast(size_t) ptr;
	idt.size = size;
	asm nothrow @nogc
	{
		lidt idt;
	}
}
