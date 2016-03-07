module novuos.kmain;

import novuos.basictypes;
import novuos.bootdata;
import novuos.memory.pager;
import novuos.formats.elf;

extern (C) void _d_dso_registry(void* data)
{
}

void FillStatus(OSBootData* bootData, uint color) @nogc nothrow
{
	foreach (int ix; 0 .. cast(int)bootData.FB.w)
	{
		foreach (int iy; 0 .. cast(int)bootData.FB.h)
		{
			bootData.FB.pixels[iy * bootData.FB.stride + ix] = color;
		}
	}
}

extern (C) void kmain() @nogc nothrow
{
	OSBootData* bootData;
	ulong ptPhptr;
	ulong ksPtr;
	asm nothrow @nogc
	{
		xorps XMM0, XMM0;
		xorps XMM1, XMM1;
		xorps XMM2, XMM2;
		mov bootData[RBP], R13;
		mov ptPhptr[RBP], R11;
		mov ksPtr[RBP], R12;
	}
	FillStatus(bootData, 0x00FF00FF);
	//EFI_TIME tm;
	//bootData.ST.RuntimeServices.GetTime(&tm, null);
	uint color = 0;
	while(true)
	{
		color+= 0x070301;
		color &= 0xFFFFFF;
		FillStatus(bootData, color);
	}
	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
