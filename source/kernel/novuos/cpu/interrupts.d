module novuos.cpu.interrupts;

import novuos.basictypes;
import novuos.cpu.descriptors;

nothrow:
@nogc:

__gshared ulong savedStack, savedStackBase;
__gshared align(64) ubyte[512] savedSSE;
__gshared align(64) ulong[32] savedRegisters;
__gshared align(64) ubyte[4097] interruptStack;
enum ushort interruptCount = 256;
__gshared align(64) IDTEntry[interruptCount] kernelIDT;

void initInterruptHandlers()
{
	for (int i = 0; i < interruptCount; i++)
	{
		kernelIDT[i].offset = cast(ulong) cast(void*)&interruptHandler!(doNothing);
		kernelIDT[i].typeAndAttr = 0x80 | SystemSegmentType.InterruptGate;
		kernelIDT[i].selector = SegmentSelector.KernelCode;
		kernelIDT[i].ist = 1;
		kernelIDT[i].pad = 0;
	}
	/*kernelIDT[1].offset = cast(ulong) cast(void*)&interruptHandler!(doNothing);
	kernelIDT[0x80].offset = cast(ulong) cast(void*)&interruptHandler!(printInt);
	kernelIDT[0x80].type.value = SystemSegmentType.InterruptGate;
	kernelIDT[0x80].dpl.value = 0;
	kernelIDT[0x80].present.value = 1;*/
	lidt(kernelIDT.ptr, kernelIDT.sizeof);
}

void doNothing()
{

}

void printInt()
{
	import novuos.gfx.fbcon;

	fbcon.printString("Interrupt test!\n");
}

private void saveRegs()
{
	asm nothrow @nogc
	{
		naked;
		fxsave [savedSSE];
		mov [savedRegisters + 0], RAX;
		mov [savedRegisters + 1], RBX;
		mov [savedRegisters + 2], RCX;
		mov [savedRegisters + 3], RDX;
		mov [savedRegisters + 4], RBP;
		mov [savedRegisters + 5], RSP;
		mov [savedRegisters + 6], RSI;
		mov [savedRegisters + 7], RDI;
		mov [savedRegisters + 8], R8;
		mov [savedRegisters + 9], R9;
		mov [savedRegisters + 10], R10;
		mov [savedRegisters + 11], R11;
		mov [savedRegisters + 12], R12;
		mov [savedRegisters + 13], R13;
		mov [savedRegisters + 14], R14;
		mov [savedRegisters + 15], R15;
		ret;
	}
}

private void restoreRegs()
{
	asm nothrow @nogc
	{
		naked;
		mov RAX, [savedRegisters + 0];
		mov RBX, [savedRegisters + 1];
		mov RCX, [savedRegisters + 2];
		mov RDX, [savedRegisters + 3];
		mov RBP, [savedRegisters + 4];
		mov RSP, [savedRegisters + 5];
		mov RSI, [savedRegisters + 6];
		mov RDI, [savedRegisters + 7];
		mov R8, [savedRegisters + 8];
		mov R9, [savedRegisters + 9];
		mov R10, [savedRegisters + 10];
		mov R11, [savedRegisters + 11];
		mov R12, [savedRegisters + 12];
		mov R13, [savedRegisters + 13];
		mov R14, [savedRegisters + 14];
		mov R15, [savedRegisters + 15];
		fxrstor [savedSSE];
		ret;
	}
}

void interruptHandler2(alias fun)()
{
	asm nothrow @nogc
	{
		naked;
		mov [savedStack], RSP;
		mov [savedStackBase], RBP;
		mov RSP, interruptStack;
		mov RBP, RSP;
		call saveRegs;
		pushfq;
		mov AX, DS;
		push RAX;
		mov AX, SegmentSelector.KernelData;
		mov DS, AX;
		mov ES, AX;
		mov FS, AX;
		mov GS, AX;
		// code begin
		//call fun;
		// code end
		pop RAX;
		mov DS, AX;
		mov ES, AX;
		mov FS, AX;
		mov GS, AX;
		popfq;
		call restoreRegs;
		mov RSP, [savedStack];
		mov RBP, [savedStackBase];
		iretq;
	}
}

void interruptHandler(alias fun)()
{
	asm nothrow @nogc
	{
		naked;
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
