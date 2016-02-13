module novuos.basictypes;

template BitField(Valtype, alias sym, int numbits, int shift)
{
    enum ulong shmask = (1Lu<<numbits)-1Lu;
    enum ulong mask = shmask << shift;
    enum ulong rmask = ulong.max - mask;
    public Valtype value() nothrow @nogc @safe
    {
        return cast(Valtype)((sym&mask)>>shift);
    }
    public void value(Valtype nw)
    {
        sym = (sym&rmask) | ((nw&shmask)<<shift);
    }
}
