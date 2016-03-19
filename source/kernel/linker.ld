OUTPUT_FORMAT(elf64-x86-64)
ENTRY(kmain)

SECTIONS
{
	KERNEL_VMA = 0xfffffff800000000;
	. = KERNEL_VMA;
	
	.text : AT(ADDR(.text) - KERNEL_VMA) {
		KStext = .;
		KEEP( *(.text*) )
		KEEP( *(.rodata*) )
		
		. = ALIGN(4096);
	}

	.data : AT(ADDR(.data) - KERNEL_VMA) {
		KSdata = .;
		KEEP( *(.data*) )
		. = ALIGN(8);
		__ctors_array_start = . ;
		KEEP( *(.ctors) )
		__ctors_array_end = . ;
		__dtors_array_start = . ;
		KEEP( *(.dtors) )
		__dtors_array_end = . ;
		KEEP( *(.ctors*) )
		KEEP( *(.dtors*) )
		KEEP( *(.minfo_beg) )
		KEEP( *(.minfo) )
		KEEP( *(.minfo_end) )
		
		. = ALIGN(4096);
	}

	.eh_frame : AT(ADDR(.eh_frame) - KERNEL_VMA) {
		KSehframe = .;
		KEEP( *(.eh_frame) )
		
		. = ALIGN(4096);
	}

	.bss : AT(ADDR(.bss) - KERNEL_VMA) {
		KSbss = .;
		KEEP( *(.dynbss*) )
		KEEP( *(.bss*) )
		KEEP( *(COMMON) )
		
		. = ALIGN(4096);
	}
	
	KSend = .;
	/DISCARD/ :
	{
		*(.comment)
	}
}
