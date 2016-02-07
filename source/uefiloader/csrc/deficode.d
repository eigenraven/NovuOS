module deficode;

extern(C) alias EfiConOut = int function(void*, const(wchar)*) @nogc nothrow;

extern(C) int nvos_uefi_dmain(void* ConOut, EfiConOut ConFunc) @nogc nothrow
{
    ConFunc(ConOut, "Hello from D world!\r\n"w.ptr);
    return 13;
}

extern(C) void* _Dmodule_ref;
extern(C) void* _tls_index = null;
