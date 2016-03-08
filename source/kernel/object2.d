/// Based on Adam D. Ruppe's minimal D runtime
module object2;

nothrow:
@nogc:

version = without_exceptions;
version = without_moduleinfo;

/**
	What doesn't work:
		1) array concats.
		2) module constructors and destructors (silent failure)
		3) looping ModuleInfo without libc or bare metal (silent failure)
		4) TLS variables. always use __gshared (runtime crash)
		5) threads.
		6) unittests (silent failure)

	Warnings:
		1) don't store slices or built in arrays. if you need to store an array, see the module memory.d and try HeapArray
		2) don't store delegates. Indeed, don't use delegates unless they are marked scope.

		Instead use HeapArray and HeapClosure, which are refcounted.

		It is ok to pass slices or scope delegates, just don't store them because they might be freed unexpectedly.

		Maybe we shouldn't free immutable stuff, so they can be safe to store, idk.

		3) if you catch an exception, you should call manual_free() on the throwable object at the end of the catch scope (unless you intend to rethrow it, of course)
*/

/**
	versions:
		bare_metal: brings its own code instead of using Linux (use Makefile.bare)
		without_exceptions: no exception support, throw will be a linker error. note the compiler still generates the handler info tables anyway...
		without_moduleinfo: some assert and range errors won't show names, less reflection options. not sure if this actually matters tbh, i think the compiler outputs the data anyway

		with_libc: uses the system C library (default is totally standalone. use "make LIBC=yes")

		without_custom_runtime_reflection: runtime reflection will be bare minimum, don't use typeinfo except as like an opaque pointer. You also won't need the special linker script if you go without libc with this option.
*/

version (with_libc)
{
	extern (C)
	{
		private
		{
			// you should import core.stdc from real druntime or something instead
			void* malloc(size_t);
			void free(void*);
			void* realloc(void*, size_t);
			void* memcpy(void* dest, const void* src, size_t n);

			struct FILE;
			extern __gshared FILE* stdout;
			size_t fwrite(in void*, size_t, size_t, FILE*);
		}
	}
	version = use_malloc;
	version = compiler_dso;
}

void write_raw(ssize_t i, ssize_t fd = 1)
{
	char[16] buffer;
	write_raw(intToString(i, buffer), fd);
}

void write_raw(in void[] a, ssize_t fd = 1)
{
	//stub
}

void write(T...)(T t)
{
	foreach (a; t)
		write_raw(a);
}

void exit(int code = 0)
{
	asm nothrow @nogc
	{
	deadloop:
		cli;
		hlt;
		jmp deadloop;
	}
}

nothrow pure size_t strlen(const(char)* c)
{
	if (c is null)
		return 0;

	size_t l = 0;
	while (*c)
	{
		c++;
		l++;
	}
	return l;
}

extern (C)
{
	// the compiler spits this out all the time

	Object _d_newclass(const ClassInfo ci)
	{
		/*void* memory = manual_malloc(ci.init.length);
		if (memory is null)
		{
			write("\n\n_d_newclass malloc failure\n\n");
			exit();
		}

		(cast(byte*) memory)[0 .. ci.init.length] = ci.init[];
		return cast(Object) memory;*/
		return null;
	}

	//void* _d_newarrayT

	// and these came when I started using foreach
	void _d_unittestm(string file, uint line)
	{
		write("_d_unittest_");
		exit(1);
	}

	void _d_array_bounds(ModuleInfo* m, uint line)
	{
		_d_arraybounds("", line);
	}

	void _d_arraybounds(string m, uint line)
	{
		write("_d_array_bounds");
		exit(1);
	}

	void _d_unittest()
	{
	}

	void _d_assertm(ModuleInfo* m, uint line)
	{
		onAssert("Assertion failure", "", line);
	}

	void _d_assert(string file, uint line)
	{
		onAssert("Assertion failure", file, line);
	}

	void _d_assert_msg(string msg, string file, uint line)
	{
		onAssert(msg, file, line);
	}

	private void onAssert(string msg, string file, uint line)
	{
		version (without_exceptions)
		{
			write("\nAssertion failure\n");
			exit(1);
		}
		else
		{
			//throw new AssertError(msg, file, line);
		}
	}
}

char[] intToString(ssize_t i, char[] buffer)
{
	ssize_t pos = buffer.length - 1;

	if (i == 0)
	{
		buffer[pos] = '0';
		pos--;
	}

	while (pos > 0 && i)
	{
		buffer[pos] = (i % 10) + '0';
		pos--;
		i /= 10;
	}

	return buffer[pos + 1 .. $];
}

// extern(C) void printf(const char*, ...);

alias immutable(char)[] string;
// the next few are really only there for phobos... they don't actually work right
alias immutable(wchar)[] wstring;
alias immutable(dchar)[] dstring;
// FIXME: what's the proper 32 bit version?
version (D_InlineAsm_X86)
{
	alias uint size_t;
	alias uint sizediff_t;
	alias int ptrdiff_t;
	alias int ssize_t;
}
else version (D_InlineAsm_X86_64)
{
	alias ulong size_t;
	alias ulong sizediff_t;
	alias long ptrdiff_t;
	alias long ssize_t;
}

/* ******************************** */
/*          Basic D classes         */
/* ******************************** */

bool opEquals(const Object lhs, const Object rhs)
{
	// A hack for the moment.
	return lhs is rhs;
}

struct AssociativeArray(K, V)
{
	typeof(this) dup()
	{
		return this;
	} // FIXME
}

extern (C) __gshared void* _Dmodule_ref;

extern (C) byte[] _d_arraycopy(size_t size, byte[] from, byte[] to)
{
	if (to.length != from.length)
	{
		version (without_exceptions)
			exit(2);
	}
	else if (to.ptr + to.length * size <= from.ptr || from.ptr + from.length * size <= to.ptr)
	{
		version (with_libc)
		{
			memcpy(to.ptr, from.ptr, to.length * size);
		}
		else
		{
			size_t s = to.length * size;
			byte* b1 = from.ptr;
			byte* b2 = to.ptr;
			while (s)
			{
				*b2 = *b1;
				++b2;
				++b1;
				--s;
			}
		}
	}
	else
	{
		version (without_exceptions)
			exit(2);
	}
	return to;
}

bool streq(char[] A, char[] B)
{
	if(A.length != B.length) return false;
	for(int i=0; i<A.length; i++)
	{
		if(A[i]!=B[i])return false;
	}
	return true;
}

extern (C) ssize_t _d_switch_string(char[][] table, char[] it)
{
	foreach (i, item; table)
		if (streq(item,it))
			return i;
	return -1;
}

extern (C): 
/**
 * Written in the D programming language.
 * Implementation of exception handling support routines for Posix and Win64.
 *
 * Copyright: Copyright Digital Mars 2000 - 2012.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Walter Bright, Sean Kelly
 * Source: $(DRUNTIMESRC src/rt/_deh2.d)
 */

extern (C) void _d_dso_registry(void* data)
{
}

/* **** */
// hash function

// the following is copy/pasted from druntime src/rt/util/hash.d
// is that available as an import somewhere in the stdlib?

template typehash(T)
{
	enum typehash = hashOf(T.mangleof.ptr, T.mangleof.length);
}

alias size_t hash_t;

version (X86) version = AnyX86;
version (X86_64) version = AnyX86;
version (AnyX86) version = HasUnalignedOps;

@trusted pure nothrow hash_t hashOf(const(void)* buf, size_t len, hash_t seed = 0)
{
	/*
     * This is Paul Hsieh's SuperFastHash algorithm, described here:
     *   http://www.azillionmonkeys.com/qed/hash.html
     * It is protected by the following open source license:
     *   http://www.azillionmonkeys.com/qed/weblicense.html
     */
	static uint get16bits(const(ubyte)* x) pure nothrow @nogc
	{
		// CTFE doesn't support casting ubyte* -> ushort*, so revert to
		// per-byte access when in CTFE.
		version (HasUnalignedOps)
		{
			if (!__ctfe)
				return *cast(ushort*) x;
		}

		return ((cast(uint) x[1]) << 8) + (cast(uint) x[0]);
	}

	// NOTE: SuperFastHash normally starts with a zero hash value.  The seed
	//       value was incorporated to allow chaining.
	auto data = cast(const(ubyte)*) buf;
	auto hash = seed;
	int rem;

	if (len <= 0 || data is null)
		return 0;

	rem = len & 3;
	len >>= 2;

	for (; len > 0; len--)
	{
		hash += get16bits(data);
		auto tmp = (get16bits(data + 2) << 11) ^ hash;
		hash = (hash << 16) ^ tmp;
		data += 2 * ushort.sizeof;
		hash += hash >> 11;
	}

	switch (rem)
	{
	case 3:
		hash += get16bits(data);
		hash ^= hash << 16;
		hash ^= data[ushort.sizeof] << 18;
		hash += hash >> 11;
		break;
	case 2:
		hash += get16bits(data);
		hash ^= hash << 11;
		hash += hash >> 17;
		break;
	case 1:
		hash += *data;
		hash ^= hash << 10;
		hash += hash >> 1;
		break;
	default:
		break;
	}

	/* Force "avalanching" of final 127 bits */
	hash ^= hash << 3;
	hash += hash >> 5;
	hash ^= hash << 4;
	hash += hash >> 17;
	hash ^= hash << 25;
	hash += hash >> 6;

	return hash;
}

bool _xopEquals(in void*, in void*)
{
	return false;
}

// 100% hax
extern(C) __gshared
{
	void* _D15TypeInfo_Struct6__vtblZ;
	void* _D10TypeInfo_m6__initZ;
	void* _D10TypeInfo_l6__initZ;
	void* _D10TypeInfo_k6__initZ;
}
