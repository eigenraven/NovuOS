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

struct ModuleReference
{
	ModuleReference* next;
	immutable(ModuleInfo)* mod;
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

	// static ctors
	{
		ModuleReference* mref = cast(ModuleReference*) _Dmodule_ref;
		while (mref != null)
		{
			alias vfun = void function() @nogc nothrow;
			vfun fun;
			fun = cast(vfun) mref.mod.ictor;
			if (fun != null)
			{
				fun();
			}
			fun = cast(vfun) mref.mod.ctor;
			if (fun != null)
			{
				fun();
			}
			fun = cast(vfun) mref.mod.tlsctor;
			if (fun != null)
			{
				fun();
			}
			mref = mref.next;
		}
	}

	Framebuffer fb;
	fb.initFromBootdata(bootData);
	fb.clear();
	//initFbconCache();
	//FramebufferConsole fbcon = FramebufferConsole(&fb);
	//fbcon.putCharAbs('a', 32, 32, 0, 255, 0);
	//ConfontChar *chr = confont_0_chars;
	//fb.drawBitmap(confont_0_bits.ptr, chr.x, chr.y, chr.width, chr.height, confont_0_width/8, 32+chr.xoffset, 32+chr.yoffset, 255, 255, 255);
	fb.clearToColor(0, 255, 0);

	asm nothrow @nogc
	{
	xloop:
		cli;
		hlt;
		jmp xloop;
	}
}
