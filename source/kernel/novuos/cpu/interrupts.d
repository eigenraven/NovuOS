module novuos.cpu.interrupts;

import novuos.basictypes;
import novuos.cpu.descriptors;

nothrow:
@nogc:

enum ushort interruptCount = 256;
__gshared IDTEntry[interruptCount] kernelIDT;

void initInterruptHandlers()
{
	for (int i = 0; i < interruptCount; i++)
	{
		kernelIDT[i].typeAndAttr = 0;
	}
	lidt(kernelIDT.ptr, interruptCount);
}

void dummyIntHandler()
{
	asm nothrow @nogc
	{
		naked;
		nop;
		iretq;
	}
}

void dummyIntWithArgumentHandler()
{
	asm nothrow @nogc
	{
		naked;
		iretq;
	}
}
