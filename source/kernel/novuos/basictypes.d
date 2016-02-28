module novuos.basictypes;

template BitField(Valtype, alias sym, int numbits, int shift_)
{
	enum int shift = shift_;
    enum ulong shmask = (1Lu<<numbits)-1Lu;
    enum ulong mask = shmask << shift_;
    enum ulong rmask = ulong.max - mask;
    public Valtype value() nothrow @nogc @safe
    {
        return cast(Valtype)((sym&mask)>>shift_);
    }
    public void value(Valtype nw) nothrow @nogc @safe
    {
        sym = (sym&rmask) | ((nw&shmask)<<shift_);
    }
}
