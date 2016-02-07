module novuos.bootdata;

import uefi;

extern(C) struct OSBootData
{
    EFI_SYSTEM_TABLE *ST;
	EFI_GRAPHICS_OUTPUT_PROTOCOL *GOP;
}
