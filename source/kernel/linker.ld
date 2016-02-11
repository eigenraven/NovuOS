OUTPUT_FORMAT(elf64-x86-64)
ENTRY(kmain)

SECTIONS
{
	KERNEL_VMA = 0xfffffff800000000;
	. = KERNEL_VMA;
	
	.text : AT(ADDR(.text) - KERNEL_VMA) {
		KStext = .;
		*(.text*)
		*(.rodata*)
		
		. = ALIGN(4096);
	}

	.data : AT(ADDR(.data) - KERNEL_VMA) {
		KSdata = .;
		*(.data*)
		*(.ctors*)
		*(.dtors*)
		*(.minfo_beg)
		*(.minfo)
		*(.minfo_end)
		
		. = ALIGN(4096);
	}

	.eh_frame : AT(ADDR(.eh_frame) - KERNEL_VMA) {
		KSehframe = .;
		*(.eh_frame)
		
		. = ALIGN(4096);
	}

	.bss : AT(ADDR(.bss) - KERNEL_VMA) {
		KSbss = .;
		*(.bss*)
		*(COMMON)
		
		. = ALIGN(4096);
	}
	
	KSend = .;
	/DISCARD/ :
	{
		*(.comment)
	}
}
