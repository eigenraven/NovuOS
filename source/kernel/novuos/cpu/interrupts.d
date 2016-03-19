module novuos.cpu.interrupts;

import novuos.basictypes;
import novuos.cpu.descriptors;

nothrow:
@nogc:

__gshared ulong savedStack, savedStackBase;
__gshared align(64) ubyte[1024] savedSSE;
__gshared align(64) ubyte[1024] interruptStack;
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

void interruptHandlerNoCode(alias fun)()
{
	asm nothrow @nogc
	{
		naked;
		// old stack
		fxsave [interruptStack.ptr];
		mov [savedStack], RSP;
		mov [savedStackBase], RBP;
		mov RSP, interruptStack.ptr;
		mov RBP, RSP;
		push RAX;
		push RBX;
		push RCX;
		push RDX;
		push RBP;
		push RSP;
		push RSI;
		push RDI;
		push R8;
		push R9;
		push R10;
		push R11;
		push R12;
		push R13;
		push R14;
		push R15;
		
		fxrstor [interruptStack.ptr];
		mov RSP, [savedStack];
		mov RBP, [savedStackBase];
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
