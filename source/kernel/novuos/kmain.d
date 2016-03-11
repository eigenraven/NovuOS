module novuos.kmain;

import novuos.basictypes;
import novuos.bootdata;
import novuos.memory.pager;
import novuos.formats.elf;
import novuos.gfx.framebuffer;
import novuos.gfx.fbcon;

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
	FramebufferConsole fbcon = FramebufferConsole(&fb);
	fbcon.setColor(0x1199EE);
	fbcon.printString(`╔═════════════════════════════════╗
║ NovuOS kernel console v1.0      ║
╚═════════════════════════════════╝`d);
	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
