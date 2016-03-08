module novuos.kmain;

import novuos.basictypes;
import novuos.bootdata;
import novuos.memory.pager;
import novuos.formats.elf;
import novuos.gfx.framebuffer;
import confont_0;

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

	Framebuffer fb;
	fb.initFromBootdata(bootData);
	fb.clear();
	
	ubyte c = 0;
	while(true)
	{
		c++;
		fb.clearToColor(c,c,c);
	}
	
	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
