module object;

mixin(makeTypeInfo!(char, wchar, dchar, int, uint, short, ushort, byte, ubyte,
	long, ulong, float, double, real, void, bool, string)());

private string makeTypeInfo(T...)()
{
	if (__ctfe)
	{
		string code;

		enum doit(t) = "class TypeInfo_" ~ t.mangleof ~ " : TypeInfo {
					override string toString() const { return \"" ~ t
				.stringof ~ "\"; }
				}";
		template doitm(string s, t, u...)
		{
			static if (u.length == 0)
			{
				enum doitm = s ~ doit!(t);
			}
			else
			{
				enum doitm = doitm!(s ~ doit!(t), u);
			}
		}

		return doitm!("", T);
	}

	assert(0);
}

nothrow:
@nogc:

/// Based on Adam D. Ruppe's minimal D runtime:
version = without_exceptions;
version = with_libc;

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

/**
 * All D class objects inherit from Object.
 */
class Object
{
	/**
     * Convert Object to a human readable string.
     */
	string toString()
	{
		return "<object>";
	}

	/**
     * Compute hash function for Object.
     */
	size_t toHash() @trusted nothrow
	{
		return cast(size_t) cast(void*) this;
	}

	/**
     * Compare with another Object obj.
     * Returns:
     *  $(TABLE
     *  $(TR $(TD this &lt; obj) $(TD &lt; 0))
     *  $(TR $(TD this == obj) $(TD 0))
     *  $(TR $(TD this &gt; obj) $(TD &gt; 0))
     *  )
     */
	int opCmp(Object o)
	{
		return cast(int) cast(void*) this - cast(int) cast(void*) o;
	}

	/**
     * Returns !=0 if this object does have the same contents as obj.
     */
	bool opEquals(Object o)
	{
		return this is o;
	}

	interface Monitor
	{
		void lock();
		void unlock();
	}

	static Object factory(string classname)
	{
		return null;
	}
}

struct Interface
{
	TypeInfo_Class classinfo = void; /// .classinfo for this interface (not for containing class)
	void*[] vtbl = void;
	size_t offset = void; /// offset to Interface 'this' from Object 'this'
}

struct OffsetTypeInfo
{
	size_t offset = void; /// Offset of member from start of object
	TypeInfo ti = void; /// TypeInfo for this member
}

class TypeInfo
{
	override string toString() const pure @safe nothrow
	{
		return "<typeinfo>";
	}

	/// Returns a hash of the instance of a type.
	size_t getHash(in void* p) @trusted nothrow const
	{
		return cast(size_t) p;
	}

	/// Compares two instances for equality.
	bool equals(in void* p1, in void* p2) const
	{
		return p1 == p2;
	}

	/// Compares two instances for &lt;, ==, or &gt;.
	int compare(in void* p1, in void* p2) const
	{
		return _xopCmp(p1, p2);
	}

	/// Returns size of the type.
	@property size_t tsize() nothrow pure const @safe @nogc
	{
		return 0;
	}

	/// Swaps two instances of the type.
	void swap(void* p1, void* p2) const
	{
		size_t n = tsize;
		for (size_t i = 0; i < n; i++)
		{
			byte t = (cast(byte*) p1)[i];
			(cast(byte*) p1)[i] = (cast(byte*) p2)[i];
			(cast(byte*) p2)[i] = t;
		}
	}

	/// Get TypeInfo for 'next' type, as defined by what kind of type this is,
	/// null if none.
	@property inout(TypeInfo) next() nothrow pure inout @nogc
	{
		return null;
	}

	/// Return default initializer.  If the type should be initialized to all zeros,
	/// an array with a null ptr and a length equal to the type size will be returned.

	// LDC uses TypeInfo's vtable for the typeof(null) type:
	//   %"typeid(typeof(null))" = type { %object.TypeInfo.__vtbl*, i8* }
	// Therefore this class cannot be abstract, and all methods need implementations.
	// Tested by test14754() in runnable/inline.d, and a unittest below.
	const(void)[] init() nothrow pure const @safe @nogc
	{
		return null;
	}

	/// Get flags for type: 1 means GC should scan for pointers,
	/// 2 means arg of this type is passed in XMM register
	@property uint flags() nothrow pure const @safe @nogc
	{
		return 0;
	}

	/// Get type information on the contents of the type; null if not available
	const(OffsetTypeInfo)[] offTi() const
	{
		return null;
	}
	/// Run the destructor on the object and all its sub-objects
	void destroy(void* p) const
	{
	}
	/// Run the postblit on the object and all its sub-objects
	void postblit(void* p) const
	{
	}

	/// Return alignment of type
	@property size_t talign() nothrow pure const @safe @nogc
	{
		return tsize;
	}

	/** Return internal info on arguments fitting into 8byte.
     * See X86-64 ABI 3.2.3
     */
	version (X86_64) int argTypes(out TypeInfo arg1, out TypeInfo arg2) @safe nothrow
	{
		arg1 = this;
		return 0;
	}

	/** Return info used by the garbage collector to do precise collection.
     */
	@property immutable(void)* rtInfo() nothrow pure const @safe @nogc
	{
		return null;
	}
}

class TypeInfo_Typedef : TypeInfo
{
	TypeInfo base;
	string name;
	void[] m_init;
}

class TypeInfo_Enum : TypeInfo_Typedef
{

}

class TypeInfo_Pointer : TypeInfo
{
	TypeInfo m_next;
}

class TypeInfo_Array : TypeInfo
{
	TypeInfo value;
}

class TypeInfo_StaticArray : TypeInfo
{
	TypeInfo value;
	size_t len;
}

class TypeInfo_AssociativeArray : TypeInfo
{
	TypeInfo value;
	TypeInfo key;
}

class TypeInfo_Vector : TypeInfo
{
	TypeInfo base;
}

class TypeInfo_Function : TypeInfo
{
	TypeInfo next;
	string deco;
}

class TypeInfo_Delegate : TypeInfo
{
	TypeInfo next;
	string deco;
}

class TypeInfo_Class : TypeInfo
{
	byte[] m_init; /** class static initializer
                                 * (init.length gives size in bytes of class)
                                 */
	string name; /// class name
	void*[] vtbl; /// virtual function pointer table
	Interface[] interfaces; /// interfaces this class implements
	TypeInfo_Class base; /// base class
	void* destructor;
	void function(Object) classInvariant;
	enum ClassFlags : uint
	{
		isCOMclass = 0x1,
		noPointers = 0x2,
		hasOffTi = 0x4,
		hasCtor = 0x8,
		hasGetMembers = 0x10,
		hasTypeInfo = 0x20,
		isAbstract = 0x40,
		isCPPclass = 0x80,
		hasDtor = 0x100,
	}

	ClassFlags m_flags;
	void* deallocator;
	OffsetTypeInfo [] m_offTi;
	void function(Object) defaultConstructor; // default Constructor

	immutable(void)* m_RTInfo; // data for precise GC
}

alias TypeInfo_Class ClassInfo;

class TypeInfo_Interface : TypeInfo
{
	TypeInfo_Class info;
}

class TypeInfo_Struct : TypeInfo
{
	string name;
	void[] m_init;
	@safe pure nothrow
	{
		size_t function(in void*) xtoHash;
		bool function(in void*, in void*) xopEquals;
		int function(in void*, in void*) xopCmp;
		string function(in void*) xtoString;

		enum StructFlags : uint
		{
			hasPointers = 0x1,
			isDynamicType = 0x2, // built at runtime, needs type info in xdtor
		}

		StructFlags m_flags;
	}
	union
	{
		void function(void*) xdtor;
		void function(void*, const TypeInfo_Struct ti) xdtorti;
	}

	void function(void*) xpostblit;

	uint m_align;

	version (X86_64)
	{
		TypeInfo m_arg1;
		TypeInfo m_arg2;
	}
	immutable(void)* m_RTInfo; // data for precise GC
}

class TypeInfo_Tuple : TypeInfo
{
	TypeInfo[] elements;
}

class TypeInfo_Const : TypeInfo
{
	TypeInfo base;
}

class TypeInfo_Invariant : TypeInfo_Const
{
}

class TypeInfo_Shared : TypeInfo_Const
{
}

class TypeInfo_Inout : TypeInfo_Const
{
}

enum 
{
	MIctorstart = 0x1, // we've started constructing it
	MIctordone = 0x2, // finished construction
	MIstandalone = 0x4, // module ctor does not depend on other module
	// ctors being done first
	MItlsctor = 8,
	MItlsdtor = 0x10,
	MIctor = 0x20,
	MIdtor = 0x40,
	MIxgetMembers = 0x80,
	MIictor = 0x100,
	MIunitTest = 0x200,
	MIimportedModules = 0x400,
	MIlocalClasses = 0x800,
	MIname = 0x1000,
}

struct ModuleInfo
{
	uint _flags;
	uint _index;
const:
@nogc:
nothrow:
	private void* addrOf(int flag) pure
	{
		void* p = cast(void*)&this + ModuleInfo.sizeof;

		if (flags & MItlsctor)
		{
			if (flag == MItlsctor)
				return p;
			p += typeof(tlsctor).sizeof;
		}
		if (flags & MItlsdtor)
		{
			if (flag == MItlsdtor)
				return p;
			p += typeof(tlsdtor).sizeof;
		}
		if (flags & MIctor)
		{
			if (flag == MIctor)
				return p;
			p += typeof(ctor).sizeof;
		}
		if (flags & MIdtor)
		{
			if (flag == MIdtor)
				return p;
			p += typeof(dtor).sizeof;
		}
		if (flags & MIxgetMembers)
		{
			if (flag == MIxgetMembers)
				return p;
			p += typeof(xgetMembers).sizeof;
		}
		if (flags & MIictor)
		{
			if (flag == MIictor)
				return p;
			p += typeof(ictor).sizeof;
		}
		if (flags & MIunitTest)
		{
			if (flag == MIunitTest)
				return p;
			p += typeof(unitTest).sizeof;
		}
		if (flags & MIimportedModules)
		{
			if (flag == MIimportedModules)
				return p;
			p += size_t.sizeof + *cast(size_t*) p * typeof(importedModules[0]).sizeof;
		}
		if (flags & MIlocalClasses)
		{
			if (flag == MIlocalClasses)
				return p;
			p += size_t.sizeof + *cast(size_t*) p * typeof(localClasses[0]).sizeof;
		}
		if (true || flags & MIname) // always available for now
		{
			if (flag == MIname)
				return p;
			p += strlen(cast(immutable char*) p);
		}
		assert(0);
	}

	@property uint index() nothrow pure
	{
		return _index;
	}

	@property uint flags() nothrow pure
	{
		return _flags;
	}

	@property void function() tlsctor() nothrow pure
	{
		return flags & MItlsctor ? *cast(typeof(return)*) addrOf(MItlsctor) : null;
	}

	@property void function() tlsdtor() nothrow pure
	{
		return flags & MItlsdtor ? *cast(typeof(return)*) addrOf(MItlsdtor) : null;
	}

	@property void* xgetMembers() nothrow pure
	{
		return flags & MIxgetMembers ? *cast(typeof(return)*) addrOf(MIxgetMembers) : null;
	}

	@property void function() ctor() nothrow pure
	{
		return flags & MIctor ? *cast(typeof(return)*) addrOf(MIctor) : null;
	}

	@property void function() dtor() nothrow pure
	{
		return flags & MIdtor ? *cast(typeof(return)*) addrOf(MIdtor) : null;
	}

	@property void function() ictor() nothrow pure
	{
		return flags & MIictor ? *cast(typeof(return)*) addrOf(MIictor) : null;
	}

	@property void function() unitTest() nothrow pure
	{
		return flags & MIunitTest ? *cast(typeof(return)*) addrOf(MIunitTest) : null;
	}

	@property immutable(ModuleInfo*)[] importedModules() nothrow pure
	{
		if (flags & MIimportedModules)
		{
			auto p = cast(size_t*) addrOf(MIimportedModules);
			return (cast(immutable(ModuleInfo*)*)(p + 1))[0 .. *p];
		}
		return null;
	}

	@property TypeInfo_Class[] localClasses() nothrow pure
	{
		if (flags & MIlocalClasses)
		{
			auto p = cast(size_t*) addrOf(MIlocalClasses);
			return (cast(TypeInfo_Class*)(p + 1))[0 .. *p];
		}
		return null;
	}
}

class Throwable : Object
{
	interface TraceInfo
	{
		int opApply(scope int delegate(ref const(char[]))) const;
		int opApply(scope int delegate(ref size_t, ref const(char[]))) const;
		string toString() const;
	}

	string msg; /// A message describing the error.

	/**
     * The _file name and line number of the D source code corresponding with
     * where the error was thrown from.
     */
	string file;
	size_t line; /// ditto

	/**
     * The stack trace of where the error happened. This is an opaque object
     * that can either be converted to $(D string), or iterated over with $(D
     * foreach) to extract the items in the stack trace (as strings).
     */
	TraceInfo info;

	/**
     * A reference to the _next error in the list. This is used when a new
     * $(D Throwable) is thrown from inside a $(D catch) block. The originally
     * caught $(D Exception) will be chained to the new $(D Throwable) via this
     * field.
     */
	Throwable next;
	@nogc @safe pure nothrow this(string msg, Throwable next = null)
	{
		this.msg = msg;
		this.next = next;
		//this.info = _d_traceContext();
	}

	@nogc @safe pure nothrow this(string msg, string file, size_t line, Throwable next = null)
	{
		this(msg, next);
		this.file = file;
		this.line = line;
		//this.info = _d_traceContext();
	}

}

/**
 * The base class of all errors that are safe to catch and handle.
 *
 * In principle, only thrown objects derived from this class are safe to catch
 * inside a $(D catch) block. Thrown objects not derived from Exception
 * represent runtime errors that should not be caught, as certain runtime
 * guarantees may not hold, making it unsafe to continue program execution.
 */
class Exception : Throwable
{
	/**
     * Creates a new instance of Exception. The next parameter is used
     * internally and should always be $(D null) when passed by user code.
     * This constructor does not automatically throw the newly-created
     * Exception; the $(D throw) statement should be used for that purpose.
     */
	@nogc @safe pure nothrow this(string msg, string file = __FILE__,
		size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}

	@nogc @safe pure nothrow this(string msg, Throwable next,
		string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line, next);
	}
}

/**
 * The base class of all unrecoverable runtime errors.
 *
 * This represents the category of $(D Throwable) objects that are $(B not)
 * safe to catch and handle. In principle, one should not catch Error
 * objects, as they represent unrecoverable runtime errors.
 * Certain runtime guarantees may fail to hold when these errors are
 * thrown, making it unsafe to continue execution after catching them.
 */
class Error : Throwable
{
	/**
     * Creates a new instance of Error. The next parameter is used
     * internally and should always be $(D null) when passed by user code.
     * This constructor does not automatically throw the newly-created
     * Error; the $(D throw) statement should be used for that purpose.
     */
	@nogc @safe pure nothrow this(string msg, Throwable next = null)
	{
		super(msg, next);
		bypassedException = null;
	}

	@nogc @safe pure nothrow this(string msg, string file, size_t line, Throwable next = null)
	{
		super(msg, file, line, next);
		bypassedException = null;
	}

	/// The first $(D Exception) which was bypassed when this Error was thrown,
	/// or $(D null) if no $(D Exception)s were pending.
	Throwable bypassedException;
}

/***************************************
 * Helper function used to see if two containers of different
 * types have the same contents in the same sequence.
 */

bool _ArrayEq(T1, T2)(T1[] a1, T2[] a2)
{
	if (a1.length != a2.length)
		return false;
	foreach (i, a; a1)
	{
		if (a != a2[i])
			return false;
	}
	return true;
}

extern (C)
{
	// the compiler spits this out all the time

	Object _d_newclass(const ClassInfo ci) @nogc
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
	if (A.length != B.length)
		return false;
	for (int i = 0; i < A.length; i++)
	{
		if (A[i] != B[i])
			return false;
	}
	return true;
}

extern (C) ssize_t _d_switch_string(char[][] table, char[] it)
{
	foreach (i, item; table)
		if (streq(item, it))
			return i;
	return -1;
}

extern (C):

int _adEq2(byte[] a1, byte[] a2, TypeInfo ti)
{
	if (a1.length != a2.length)
		return 0;
	for (int a = 0; a < a1.length; a++)
		if (a1[a] != a2[a])
			return 0;
	return 1;
}

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

extern (C) void _d_throwc(Object* h)
{

}

extern (C) void _d_throw_exception(Object* h)
{

}
