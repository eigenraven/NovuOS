module novuos.bootdata;

import uefi;
import novuos.memory.pager;

enum BootFramebufferFormat
{
    RGB,
    BGR
}

struct BootFramebuffer
{
    long npixels;
    int w, h;
    int stride;
    BootFramebufferFormat pformat;
    uint* pixels;
}

struct OSBootData
{
    EFI_SYSTEM_TABLE* ST;
    EFI_GRAPHICS_OUTPUT_PROTOCOL* GOP;
    BootFramebuffer FB;
}
