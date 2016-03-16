module novuos.basictypes;

public import core.stdc.string : memcpy, memmove, memset, memcmp;

template BitField(Valtype, alias sym, int numbits, int shift_)
{
	enum int shift = shift_;
	enum ulong shmask = (1Lu << numbits) - 1Lu;
	enum ulong mask = shmask << shift_;
	enum ulong rmask = ulong.max - mask;
	public Valtype value() nothrow @nogc @safe
	{
		return cast(Valtype)((sym & mask) >> shift_);
	}

	public void value(Valtype nw) nothrow @nogc @safe
	{
		sym = (sym & rmask) | ((nw & shmask) << shift_);
	}
}

nothrow:
@nogc:

size_t ltoa(dchar* buf, long v)
{
	long[19] POTS = [
		1, // 0
		10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, // 9
		10000000000, 100000000000, 1000000000000, 10000000000000, 100000000000000,
		1000000000000000, 10000000000000000, 100000000000000000, 1000000000000000000
	];
	dchar* ptr = buf;
	if (v == 0)
	{
		*(ptr++) = '0';
	}
	else
	{
		if (v < 0)
		{
			v = -v;
			*(ptr++) = '-';
		}
		bool f = false;
		for (int i = cast(int)(POTS.length-1); i >= 0; i--)
		{
			if (f || v >= POTS[i])
			{
				f = true;
				long dg = (v / POTS[i]);
				*(ptr++) = cast(dchar)(dg + '0');
				v -= dg * POTS[i];
			}
		}
	}
	*(ptr) = '\0';
	return (ptr - buf);
}

size_t ltox(dchar* buf, ulong v)
{
	dchar[36] chrs = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	dchar* ptr = buf;
	if (v == 0)
	{
		*(ptr++) = '0';
	}
	else
	{
		bool f = false;
		for (int i = 15; i >= 0; i--)
		{
			if (f || v >= (0xF << 4 * i))
			{
				f = true;
				ulong dg = (v & (0xF << 4 * i)) >> 4 * i;
				*(ptr++) = chrs[dg];
				v -= dg << 4 * i;
			}
		}
	}
	*(ptr) = '\0';
	return (ptr - buf);
}

extern(C) int snprintf(char* s, size_t n, const(char)* fmt, ...);
