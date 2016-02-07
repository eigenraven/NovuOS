module novuos.kmain;

import novuos.bootdata;

extern(C) void _d_dso_registry(void* data) {}

extern(C) void kmain(OSBootData* bootdata) @nogc nothrow
{
    bootdata.screenPtr[0] = 0x00FF00FF;
    while(true){}
}
