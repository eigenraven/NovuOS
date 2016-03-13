/// Inline assembly functions
module novuos.iasm;

import ldc.attributes;
import ldc.intrinsics;

nothrow:
@nogc:

pragma(inline, true) void outb(ushort port, ubyte value)
{
	pragma(LDC_allow_inline);
	asm nothrow @nogc
	{
		mov AL, value;
		mov DX, port;
		out DX, AL;
	}
}

pragma(inline, true) void outw(ushort port, ushort value)
{
	pragma(LDC_allow_inline);
	asm nothrow @nogc
	{
		mov AX, value;
		mov DX, port;
		out DX, AX;
	}
}

pragma(inline, true) void outl(ushort port, uint value)
{
	pragma(LDC_allow_inline);
	asm nothrow @nogc
	{
		mov EAX, value;
		mov DX, port;
		out DX, EAX;
	}
}

pragma(inline, true) ubyte inb(ushort port)
{
	typeof(return) val;
	pragma(LDC_allow_inline);
	asm nothrow @nogc
	{
		mov DX, port;
		 in AL, DX;
		mov AL, val;
	}
	return val;
}

pragma(inline, true) ushort inw(ushort port)
{
	typeof(return) val;
	pragma(LDC_allow_inline);
	asm nothrow @nogc
	{
		mov DX, port;
		 in AX, DX;
		mov AX, val;
	}
	return val;
}

pragma(inline, true) uint inl(ushort port)
{
	typeof(return) val;
	pragma(LDC_allow_inline);
	asm nothrow @nogc
	{
		mov DX, port;
		 in EAX, DX;
		mov EAX, val;
	}
	return val;
}
