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
	foreach (int ix; 256 .. 300)
	{
		foreach (int iy; 32 .. 76)
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
		mov bootData, R13;
		mov ptPhptr, R11;
		mov ksPtr, R12;
	}
	FillStatus(bootData, 0x00FF00FF);
	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
