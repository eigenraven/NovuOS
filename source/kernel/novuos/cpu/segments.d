module novuos.cpu.segments;

import novuos.cpu.descriptors;
import novuos.basictypes;
import novuos.gfx.fbcon;

__gshared align(64) GDTEntry[32] kernelGDT;
__gshared align(64) TSS kernelTSS;

nothrow:
@nogc:

void initGDT(ulong rsp)
{
	memset(kernelGDT.ptr, kernelGDT.sizeof, 0);
	memset(&kernelTSS, TSS.sizeof, 0);
	kernelGDT[SegmentSelector.Null] = GDTEntry(0xFFFF, 0, 0,
		GDTAccess.Present | GDTAccess.MustBeOne | GDTAccess.ReadWrite,
		0xF | GDTFlags.Size64 | GDTFlags.PageGranularity, 0);
	kernelGDT[SegmentSelector.KernelCode] = GDTEntry(0xFFFF, 0, 0,
		GDTAccess.Present | GDTAccess.MustBeOne | GDTAccess.Executable | GDTAccess.ReadWrite | GDTAccess.Ring0,
		0xF | GDTFlags.Size64 | GDTFlags.PageGranularity, 0);
	kernelGDT[SegmentSelector.KernelData] = GDTEntry(0xFFFF, 0, 0,
		GDTAccess.Present | GDTAccess.MustBeOne | GDTAccess.ReadWrite | GDTAccess.Ring0,
		0xF | GDTFlags.Size64 | GDTFlags.PageGranularity, 0);
	kernelGDT[SegmentSelector.UserCode] = GDTEntry(0xFFFF, 0, 0,
		GDTAccess.Present | GDTAccess.MustBeOne | GDTAccess.Executable | GDTAccess.ReadWrite | GDTAccess.Ring3,
		0xF | GDTFlags.Size64 | GDTFlags.PageGranularity, 0);
	kernelGDT[SegmentSelector.UserData] = GDTEntry(0xFFFF, 0, 0,
		GDTAccess.Present | GDTAccess.MustBeOne | GDTAccess.ReadWrite | GDTAccess.Ring3,
		0xF | GDTFlags.Size64 | GDTFlags.PageGranularity, 0);
	SystemSegmentEntry* tsse = cast(SystemSegmentEntry*)(&kernelGDT[SegmentSelector.KernelTSS]);
	tsse.limit = TSS.sizeof - 1;
	tsse.base = cast(ulong)(&kernelTSS);
	tsse.typeAndFlags = SystemSegmentType.AvailableTSS | GDTAccess.Present;
	tsse.reserved = 0;
	kernelTSS.rsp0 = rsp;
	kernelTSS.rsp1 = rsp;
	kernelTSS.rsp2 = rsp;
	import novuos.cpu.interrupts : interruptStack;
	kernelTSS.ist1 = cast(ulong)&interruptStack[$-1];
	kernelTSS.ist2 = kernelTSS.ist1;
	kernelTSS.ist3 = kernelTSS.ist1;
	kernelTSS.ist4 = kernelTSS.ist1;
	kernelTSS.ist5 = kernelTSS.ist1;
	kernelTSS.ist6 = kernelTSS.ist1;
	kernelTSS.ist7 = kernelTSS.ist1;
	kernelTSS.iomapBase = kernelTSS.iomap.offsetof;
	lgdt(kernelGDT.ptr, cast(ushort)(kernelGDT.length * 64 - 1));
}
