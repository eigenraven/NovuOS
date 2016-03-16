module novuos.cpu.segments;

import novuos.cpu.descriptors;
import novuos.basictypes;
import novuos.gfx.fbcon;

__gshared GDTEntry[32] kernelGDT;
__gshared ulong[64] kernelTSS;

nothrow:
@nogc:

void initGDT(ulong rsp)
{
	memset(kernelGDT.ptr, kernelGDT.sizeof, 0);
	memset(kernelTSS.ptr, kernelTSS.sizeof, 0);
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
	tsse.limit = kernelTSS.length * ulong.sizeof;
	tsse.base = cast(ulong)(kernelTSS.ptr);
	tsse.typeAndFlags = SystemSegmentType.AvailableTSS;
	tsse.limitAndGranularity |= GDTFlags.PageGranularity | GDTFlags.Size64;
	tsse.baseHigh64 = 0;
	tsse.reserved = 0;
	TSS* tss = cast(TSS*)kernelTSS;
	tss.rsp0 = rsp;
	tss.rsp1 = rsp;
	tss.rsp2 = rsp;
	tss.iomapBase = kernelTSS.length * 8;
	char[70] buf;
	long* ggg = cast(long*)kernelGDT.ptr;
	ggg[0] = 0;
	for(int i=0;i<8;i++)
	{
		snprintf(buf.ptr, buf.length, "GDT[%d] := %016llx\n\0", cast(int)33, cast(long)47);
		fbcon.printCString(buf, buf.length);
	}
	//auto sz1 = ltox(buf.ptr, *cast(ulong*)(tsse));
	//lgdt(kernelGDT.ptr, cast(ushort)(kernelGDT.length * 64 - 64));
}
