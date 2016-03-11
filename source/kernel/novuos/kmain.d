module novuos.kmain;

import novuos.basictypes;
import novuos.bootdata;
import novuos.memory.pager;
import novuos.formats.elf;
import novuos.gfx.framebuffer;
import novuos.gfx.fbcon;
import confont_0;

void main()
{
}

extern (C) void kmain() @nogc nothrow
{
	OSBootData* bootData;
	ulong ptPhptr;
	ulong ksPtr;
	asm nothrow @nogc
	{
		mov bootData[RBP], R13;
		mov ptPhptr[RBP], R11;
		mov ksPtr[RBP], R12;
	}

	Framebuffer fb;
	fb.initFromBootdata(bootData);
	fb.clear();
	confont_0_init();
	//initFbconCache();
	//FramebufferConsole fbcon = FramebufferConsole(&fb);
	//fbcon.putCharAbs('a', 32, 32, 0, 255, 0);
	//ConfontChar *chr = confont_0_chars;
	//ConfontChar chr = ConfontChar(69, 186, 13, 5, 12, 0, 0, 6);
	ConfontChar *chr = &confont_0_chars[43-5];
	fb.drawBitmap(confont_0_bits.ptr, chr.x, chr.y, chr.width, chr.height, confont_0_width/8, 32+chr.xoffset, 32+chr.yoffset, 255, 255, 255);
	//fb.drawBitmap(confont_0_bits.ptr, 0, 0, 256, 256, confont_0_width/8, 32, 32, 255, 255, 0);
	//fb.drawBitmap(confont_0_bits.ptr, 186, 13, 5, 12, confont_0_width/8, 32, 32, 255, 255, 0);
	//fb.clearToColor(0, 255, 0);

	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
