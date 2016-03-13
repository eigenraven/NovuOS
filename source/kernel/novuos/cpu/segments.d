module novuos.cpu.segments;

import novuos.cpu.descriptors;

__gshared GDTEntry[32] kernelGDT;
__gshared ulong[64] kernelTSS;

nothrow:
@nogc:

void initGDT()
{
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
	tsse.limit = 0;
	tsse.typeAndFlags = SystemSegmentType.AvailableTSS | GDTAccess.Present;
	tsse.base = cast(ulong)(kernelTSS.ptr);
	lgdt(kernelGDT.ptr, cast(ushort)(kernelGDT.length * 64 - 64));
}
