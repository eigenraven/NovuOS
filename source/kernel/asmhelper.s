[BITS 64]
section .text

global reload_gdt
global reloadCS

reload_gdt:
	mov RAX, 0x8
	push RAX ; Return CS
	mov RAX, QWORD reloadCS
	push RAX ; Return RIP
	o64 retf
reloadCS:
	mov AX, 0x10
	mov SS, AX
	mov DS, AX
	mov ES, AX
	mov FS, AX
	mov GS, AX
	ret;

