module novuos.kmain;

import novuos.basictypes;
import novuos.bootdata;
import novuos.memory.pager;
import novuos.formats.elf;
import novuos.gfx.framebuffer;
import novuos.gfx.fbcon;
import novuos.cpu.interrupts;
import novuos.cpu.segments;

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
	enum dstring WelcomeMsg = `NovuOS kernel console v1.0`d;
	enum ulong WML = WelcomeMsg.length/2;
	fbcon.drawBox(fbcon.w/2 - WML - 2, 1, WelcomeMsg.length+2, 3);
	fbcon.printString(WelcomeMsg);
	fbcon.moveTo(0, 4);
	fbcon.setColor(0xEEEEEE);
	fbcon.printString("[trace] kmain() executed\n"d);
	initGDT();
	fbcon.printString("[trace] GDT reloaded\n"d);
	initInterruptHandlers();
	fbcon.printString("[trace] installed interrupt handlers\n"d);
	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
