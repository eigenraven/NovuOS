module novuos.kmain;

import novuos.basictypes;
import novuos.bootdata;
import novuos.memory.pager;
import novuos.formats.elf;
import novuos.gfx.framebuffer;
import novuos.gfx.fbcon;
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
	initFbconCache();
	FramebufferConsole fbcon = void;
	fbcon.fb = &fb;
	//fbcon.putCharAbs('a', 32, 32, 0, 255, 0);
	ConfontChar *chr = &confont_0_chars[0];
	//fb.drawBitmap(confont_0_bits.ptr, chr.x, chr.y, chr.width, chr.height, confont_0_width/8, 32+chr.xoffset, 32+chr.yoffset, 255, 255, 255);
	fb.clearToColor(0,255,0);
	
	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
