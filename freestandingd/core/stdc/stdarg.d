/**
 * D header file for C99.
 *
 * Copyright: Copyright Digital Mars 2000 - 2009.
 * License:   Distributed under the
 *    <a href="http://www.boost.org/LICENSE_1_0.txt">Boost Software License 1.0</a>.
 *    (See accompanying file LICENSE or copy at http://www.boost.org/LICENSE_1_0.txt)
 * Authors:   Walter Bright, Hauke Duden
 * Standards: ISO/IEC 9899:1999 (E)
 * Source: $(DRUNTIMESRC core/stdc/_stdarg.d)
 */

module core.stdc.stdarg;

@system:
//@nogc:    // Not yet, need to make TypeInfo's member functions @nogc first

version ( PPC ) version = AnyPPC;
version ( PPC64 ) version = AnyPPC;

version( ARM )
{
    // iOS, tvOS use older APCS variant instead of AAPCS
    version( iOS ) {}
    else version( TVOS ) {}
    else version = AAPCS;
}

version( X86_64 )
{
    // Determine if type is a vector type
    template isVectorType(T)
    {
        enum isVectorType = false;
    }

    template isVectorType(T : __vector(T[N]), size_t N)
    {
        enum isVectorType = true;
    }

    alias __va_list = __va_list_tag;

    void va_arg_x86_64(T)(__va_list *ap, ref T parmn)
    {
        static if (is(T U == __argTypes))
        {
            static if (U.length == 0 || T.sizeof > 16 || (U[0].sizeof > 8 && !isVectorType!(U[0])))
            {   // Always passed in memory
                // The arg may have more strict alignment than the stack
                auto p = (cast(size_t)ap.stack_args + T.alignof - 1) & ~(T.alignof - 1);
                ap.stack_args = cast(void*)(p + ((T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
                parmn = *cast(T*)p;
            }
            else static if (U.length == 1)
            {   // Arg is passed in one register
                alias U[0] T1;
                static if (is(T1 == double) || is(T1 == float) || isVectorType!(T1))
                {   // Passed in XMM register
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8))
                    {
                        parmn = *cast(T*)(ap.reg_args + ap.offset_fpregs);
                        ap.offset_fpregs += 16;
                    }
                    else
                    {
                        parmn = *cast(T*)ap.stack_args;
                        ap.stack_args += (T1.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                    }
                }
                else
                {   // Passed in regular register
                    if (ap.offset_regs < 6 * 8 && T.sizeof <= 8)
                    {
                        parmn = *cast(T*)(ap.reg_args + ap.offset_regs);
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        auto p = (cast(size_t)ap.stack_args + T.alignof - 1) & ~(T.alignof - 1);
                        ap.stack_args = cast(void*)(p + ((T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
                        parmn = *cast(T*)p;
                    }
                }
            }
            else static if (U.length == 2)
            {   // Arg is passed in two registers
                alias U[0] T1;
                alias U[1] T2;
                auto p = cast(void*)&parmn + 8;

                // Both must be in registers, or both on stack, hence 4 cases

                static if ((is(T1 == double) || is(T1 == float)) &&
                           (is(T2 == double) || is(T2 == float)))
                {
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8) - 16)
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_fpregs);
                        *cast(T2*)p = *cast(T2*)(ap.reg_args + ap.offset_fpregs + 16);
                        ap.offset_fpregs += 32;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += (T1.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                        *cast(T2*)p = *cast(T2*)ap.stack_args;
                        ap.stack_args += (T2.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                    }
                }
                else static if (is(T1 == double) || is(T1 == float))
                {
                    void* a = void;
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8) &&
                        ap.offset_regs < 6 * 8 && T2.sizeof <= 8)
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_fpregs);
                        ap.offset_fpregs += 16;
                        a = ap.reg_args + ap.offset_regs;
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += (T1.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                        a = ap.stack_args;
                        ap.stack_args += 8;
                    }
                    // Be careful not to go past the size of the actual argument
                    const sz2 = T.sizeof - 8;
                    p[0..sz2] = a[0..sz2];
                }
                else static if (is(T2 == double) || is(T2 == float))
                {
                    if (ap.offset_regs < 6 * 8 && T1.sizeof <= 8 &&
                        ap.offset_fpregs < (6 * 8 + 16 * 8))
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_regs);
                        ap.offset_regs += 8;
                        *cast(T2*)p = *cast(T2*)(ap.reg_args + ap.offset_fpregs);
                        ap.offset_fpregs += 16;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += 8;
                        *cast(T2*)p = *cast(T2*)ap.stack_args;
                        ap.stack_args += (T2.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                    }
                }
                else // both in regular registers
                {
                    void* a = void;
                    if (ap.offset_regs < 5 * 8 && T1.sizeof <= 8 && T2.sizeof <= 8)
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_regs);
                        ap.offset_regs += 8;
                        a = ap.reg_args + ap.offset_regs;
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += 8;
                        a = ap.stack_args;
                        ap.stack_args += 8;
                    }
                    // Be careful not to go past the size of the actual argument
                    const sz2 = T.sizeof - 8;
                    p[0..sz2] = a[0..sz2];
                }
            }
            else
            {
                static assert(false);
            }
        }
        else
        {
            static assert(false, "not a valid argument type for va_arg");
        }
    }

    void va_arg_x86_64()(__va_list *ap, TypeInfo ti, void* parmn)
    {
        TypeInfo arg1, arg2;
        if (!ti.argTypes(arg1, arg2))
        {
            bool inXMMregister(TypeInfo arg) pure nothrow @safe
            {
                return (arg.flags & 2) != 0;
            }

            TypeInfo_Vector v1 = arg1 ? cast(TypeInfo_Vector)arg1 : null;
            if (arg1 && (arg1.tsize <= 8 || v1))
            {   // Arg is passed in one register
                auto tsize = arg1.tsize;
                void* p;
                bool stack = false;
                auto offset_fpregs_save = ap.offset_fpregs;
                auto offset_regs_save = ap.offset_regs;
            L1:
                if (inXMMregister(arg1) || v1)
                {   // Passed in XMM register
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8) && !stack)
                    {
                        p = ap.reg_args + ap.offset_fpregs;
                        ap.offset_fpregs += 16;
                    }
                    else
                    {
                        p = ap.stack_args;
                        ap.stack_args += (tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                        stack = true;
                    }
                }
                else
                {   // Passed in regular register
                    if (ap.offset_regs < 6 * 8 && !stack)
                    {
                        p = ap.reg_args + ap.offset_regs;
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        p = ap.stack_args;
                        ap.stack_args += 8;
                        stack = true;
                    }
                }
                parmn[0..tsize] = p[0..tsize];

                if (arg2)
                {
                    if (inXMMregister(arg2))
                    {   // Passed in XMM register
                        if (ap.offset_fpregs < (6 * 8 + 16 * 8) && !stack)
                        {
                            p = ap.reg_args + ap.offset_fpregs;
                            ap.offset_fpregs += 16;
                        }
                        else
                        {
                            if (!stack)
                            {   // arg1 is really on the stack, so rewind and redo
                                ap.offset_fpregs = offset_fpregs_save;
                                ap.offset_regs = offset_regs_save;
                                stack = true;
                                goto L1;
                            }
                            p = ap.stack_args;
                            ap.stack_args += (arg2.tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                        }
                    }
                    else
                    {   // Passed in regular register
                        if (ap.offset_regs < 6 * 8 && !stack)
                        {
                            p = ap.reg_args + ap.offset_regs;
                            ap.offset_regs += 8;
                        }
                        else
                        {
                            if (!stack)
                            {   // arg1 is really on the stack, so rewind and redo
                                ap.offset_fpregs = offset_fpregs_save;
                                ap.offset_regs = offset_regs_save;
                                stack = true;
                                goto L1;
                            }
                            p = ap.stack_args;
                            ap.stack_args += 8;
                        }
                    }
                    auto sz = ti.tsize - 8;
                    (parmn + 8)[0..sz] = p[0..sz];
                }
            }
            else
            {   // Always passed in memory
                // The arg may have more strict alignment than the stack
                auto talign = ti.talign;
                auto tsize = ti.tsize;
                auto p = cast(void*)((cast(size_t)ap.stack_args + talign - 1) & ~(talign - 1));
                ap.stack_args = cast(void*)(cast(size_t)p + ((tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
                parmn[0..tsize] = p[0..tsize];
            }
        }
        else
        {
            assert(false, "not a valid argument type for va_arg");
        }
    }
}

version( LDC )
{
    version( X86_64 )
    {
        version( Win64 ) {}
        else version = SystemV_AMD64;
    }

    // Type va_list:
    // On most platforms, really struct va_list { void* ptr; },
    // but for compatibility with x86-style code that uses char*,
    // we just define it as the raw pointer.
    // For System V AMD64 ABI, really __va_list[1], i.e., a 24-bytes
    // struct passed by reference. We define va_list as a raw pointer
    // (to the actual struct) for the byref semantics and allocate
    // the struct in LDC's va_start and va_copy intrinsics.
    version (SystemV_AMD64)
    {
        alias va_list = __va_list_tag*;
    }
    else
    {
        alias va_list = char*;
    }

    pragma(LDC_va_start)
        void va_start(T)(va_list ap, ref T);

    private pragma(LDC_va_arg)
        T va_arg_intrinsic(T)(va_list ap);

    T va_arg(T)(ref va_list ap)
    {
        version( SystemV_AMD64 )
        {
            T arg;
            va_arg(ap, arg);
            return arg;
        }
        else version( Win64 )
        {
            // dynamic arrays are passed as 2 separate 64-bit values
            import std.traits: isDynamicArray;
            static if (isDynamicArray!T)
            {
                auto length = *cast(size_t*)ap;
                ap += size_t.sizeof;
                auto ptr = *cast(typeof(T.init.ptr)*)ap;
                ap += size_t.sizeof;
                return ptr[0..length];
            }
            else
            {
                // passed as byval reference if > 64 bits or of a size that is not a power of 2
                static if (T.sizeof > size_t.sizeof || (T.sizeof & (T.sizeof - 1)) != 0)
                    T arg = **cast(T**)ap;
                else
                    T arg = *cast(T*)ap;
                ap += size_t.sizeof;
                return arg;
            }
        }
        else version( X86 )
        {
            T arg = *cast(T*)ap;
            ap += (T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
            return arg;
        }
        else version( ARM )
        {
            // AAPCS sec 5.5 B.5: type with alignment >= 8 is 8-byte aligned
            // instead of normal 4-byte alignment (APCS doesn't do this).
            version( AAPCS )
            {
                if (T.alignof >= 8)
                    ap = cast(va_list)((cast(size_t)ap + 7) & ~7);
            }
            T arg = *cast(T*)ap;
            ap += (T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
            return arg;
        }
        else version( AnyPPC )
        {
            T arg = *cast(T*)ap;
            ap += (T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
            return arg;
        }
        else version( MIPS64 )
        {
            T arg = *cast(T*)ap;
            ap += (T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
            return arg;
        }
        else
            return va_arg_intrinsic!T(ap);
    }

    void va_arg(T)(ref va_list ap, ref T parmn)
    {
        version( SystemV_AMD64 )
        {
            va_arg_x86_64(cast(__va_list*)ap, parmn);
        }
        else version( Win64 )
        {
            import std.traits: isDynamicArray;
            static if (isDynamicArray!T)
            {
                parmn = *cast(T*)ap;
                ap += T.sizeof;
            }
            else
            {
                static if (T.sizeof > size_t.sizeof || (T.sizeof & (T.sizeof - 1)) != 0)
                    parmn = **cast(T**)ap;
                else
                    parmn = *cast(T*)ap;
                ap += size_t.sizeof;
            }
        }
        else version( X86 )
        {
            parmn = *cast(T*)ap;
            ap += (T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
        }
        else version( ARM )
        {
            // AAPCS sec 5.5 B.5: type with alignment >= 8 is 8-byte aligned
            // instead of normal 4-byte alignment (APCS doesn't do this).
            version( AAPCS )
            {
                if (T.alignof >= 8)
                    ap = cast(va_list)((cast(size_t)ap + 7) & ~7);
            }
            parmn = *cast(T*)ap;
            ap += (T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
        }
        else
            parmn = va_arg!T(ap);
    }

    void va_arg()(ref va_list ap, TypeInfo ti, void* parmn)
    {
      version( SystemV_AMD64 )
      {
        va_arg_x86_64(cast(__va_list*)ap, ti, parmn);
      }
      else
      {
        auto tsize = ti.tsize;

        version( X86 )
        {
            // Wait until everyone updates to get TypeInfo.talign
            //auto talign = ti.talign;
            //auto p = cast(va_list) ((cast(size_t)ap + talign - 1) & ~(talign - 1));
            auto p = ap;
            ap = p + ((tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1));
        }
        else version( Win64 )
        {
            char* p;
            auto ti_dynArray = cast(TypeInfo_Array) ti;
            if (ti_dynArray !is null)
            {
                p = ap;
                ap += tsize;
            }
            else
            {
                p = (tsize > size_t.sizeof || (tsize & (tsize - 1)) != 0) ? *cast(char**)ap : ap;
                ap += size_t.sizeof;
            }
        }
        else version( ARM )
        {
            // AAPCS sec 5.5 B.5: type with alignment >= 8 is 8-byte aligned
            // instead of normal 4-byte alignment (APCS doesn't do this).
            version( AAPCS )
            {
                if (ti.talign >= 8)
                    ap = cast(va_list)((cast(size_t)ap + 7) & ~7);
            }
            auto p = ap;
            ap = p + ((tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1));
        }
        else version( AnyPPC )
        {
            /*
             * The rules are described in the 64bit PowerPC ELF ABI Supplement 1.9,
             * available here:
             * http://refspecs.linuxfoundation.org/ELF/ppc64/PPC-elf64abi-1.9.html#PARAM-PASS
             */

            // This works for all types because only the rules for non-floating,
            // non-vector types are used.
            auto p = (tsize < size_t.sizeof ? ap + (size_t.sizeof - tsize) : ap);
            ap += (tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
        }
        else version( MIPS64 )
        {
            // This works for all types because only the rules for non-floating,
            // non-vector types are used.
            auto p = (tsize < size_t.sizeof ? ap + (size_t.sizeof - tsize) : ap);
            ap += (tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
        }
        else
        {
            static assert(false, "Unsupported platform");
        }

        parmn[0..tsize] = (cast(void*)p)[0..tsize];
      }
    }

    pragma(LDC_va_end)
        void va_end(va_list ap);

    pragma(LDC_va_copy)
        void va_copy(out va_list dest, va_list src);
}
else version( X86 )
{
    /*********************
     * The argument pointer type.
     */
    alias va_list = char*;

    /**********
     * Initialize ap.
     * For 32 bit code, parmn should be the last named parameter.
     * For 64 bit code, parmn should be __va_argsave.
     */
    void va_start(T)(out va_list ap, ref T parmn)
    {
        ap = cast(va_list)( cast(void*) &parmn + ( ( T.sizeof + int.sizeof - 1 ) & ~( int.sizeof - 1 ) ) );
    }

    /************
     * Retrieve and return the next value that is type T.
     * Should use the other va_arg instead, as this won't work for 64 bit code.
     */
    T va_arg(T)(ref va_list ap)
    {
        T arg = *cast(T*) ap;
        ap = cast(va_list)( cast(void*) ap + ( ( T.sizeof + int.sizeof - 1 ) & ~( int.sizeof - 1 ) ) );
        return arg;
    }

    /************
     * Retrieve and return the next value that is type T.
     * This is the preferred version.
     */
    void va_arg(T)(ref va_list ap, ref T parmn)
    {
        parmn = *cast(T*)ap;
        ap = cast(va_list)(cast(void*)ap + ((T.sizeof + int.sizeof - 1) & ~(int.sizeof - 1)));
    }

    /*************
     * Retrieve and store through parmn the next value that is of TypeInfo ti.
     * Used when the static type is not known.
     */
    void va_arg()(ref va_list ap, TypeInfo ti, void* parmn)
    {
        // Wait until everyone updates to get TypeInfo.talign
        //auto talign = ti.talign;
        //auto p = cast(void*)(cast(size_t)ap + talign - 1) & ~(talign - 1);
        auto p = ap;
        auto tsize = ti.tsize;
        ap = cast(void*)(cast(size_t)p + ((tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
        parmn[0..tsize] = p[0..tsize];
    }

    /***********************
     * End use of ap.
     */
    void va_end(va_list ap)
    {
    }

    void va_copy(out va_list dest, va_list src)
    {
        dest = src;
    }
}
else version (Windows) // Win64
{   /* Win64 is characterized by all arguments fitting into a register size.
     * Smaller ones are padded out to register size, and larger ones are passed by
     * reference.
     */

    /*********************
     * The argument pointer type.
     */
    alias void* va_list;

    /**********
     * Initialize ap.
     * parmn should be the last named parameter.
     */
    void va_start(T)(out va_list ap, ref T parmn)
    {
        ap = cast(va_list)(cast(void*)&parmn + ((size_t.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
    }

    /************
     * Retrieve and return the next value that is type T.
     */
    T va_arg(T)(ref va_list ap)
    {
        static if (T.sizeof > size_t.sizeof)
            T arg = **cast(T**)ap;
        else
            T arg = *cast(T*)ap;
        ap = cast(va_list)(cast(void*)ap + ((size_t.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
        return arg;
    }

    /************
     * Retrieve and return the next value that is type T.
     * This is the preferred version.
     */
    void va_arg(T)(ref va_list ap, ref T parmn)
    {
        static if (T.sizeof > size_t.sizeof)
            parmn = **cast(T**)ap;
        else
            parmn = *cast(T*)ap;
        ap = cast(va_list)(cast(void*)ap + ((size_t.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
    }

    /*************
     * Retrieve and store through parmn the next value that is of TypeInfo ti.
     * Used when the static type is not known.
     */
    void va_arg()(ref va_list ap, TypeInfo ti, void* parmn)
    {
        // Wait until everyone updates to get TypeInfo.talign
        //auto talign = ti.talign;
        //auto p = cast(void*)(cast(size_t)ap + talign - 1) & ~(talign - 1);
        auto p = ap;
        auto tsize = ti.tsize;
        ap = cast(void*)(cast(size_t)p + ((size_t.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
        void* q = (tsize > size_t.sizeof) ? *cast(void**)p : p;
        parmn[0..tsize] = q[0..tsize];
    }

    /***********************
     * End use of ap.
     */
    void va_end(va_list ap)
    {
    }

    void va_copy(out va_list dest, va_list src)
    {
        dest = src;
    }
}
else version ( X86_64 )
{
    align(16) struct __va_argsave_t
    {
        size_t[6] regs;   // RDI,RSI,RDX,RCX,R8,R9
        real[8] fpregs;   // XMM0..XMM7
        __va_list va;
    }

    /*
     * Making it an array of 1 causes va_list to be passed as a pointer in
     * function argument lists
     */
    alias void* va_list;

    void va_start(T)(out va_list ap, ref T parmn)
    {
        ap = &parmn.va;
    }

    T va_arg(T)(va_list ap)
    {   T a;
        va_arg(ap, a);
        return a;
    }

    void va_arg(T)(va_list apx, ref T parmn)
    {
        __va_list* ap = cast(__va_list*)apx;
        va_arg_x86_64(ap, parmn);
    }

    void va_arg()(va_list apx, TypeInfo ti, void* parmn)
    {
        __va_list* ap = cast(__va_list*)apx;
        va_arg_x86_64(ap, ti, parmn);
    }

    void va_end(va_list ap)
    {
    }

    void va_copy(out va_list dest, va_list src)
    {
        dest = src;
    }
}
else
{
    static assert(false, "Unsupported platform");
}
