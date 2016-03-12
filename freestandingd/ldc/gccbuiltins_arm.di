module ldc.gccbuiltins_arm; 

import core.simd;

nothrow @nogc:

pragma(LDC_intrinsic, "llvm.arm.cdp")
    void __builtin_arm_cdp(int, int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.cdp2")
    void __builtin_arm_cdp2(int, int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.dmb")
    void __builtin_arm_dmb(int);

pragma(LDC_intrinsic, "llvm.arm.dsb")
    void __builtin_arm_dsb(int);

pragma(LDC_intrinsic, "llvm.arm.get.fpscr")
    int __builtin_arm_get_fpscr() pure @safe;

pragma(LDC_intrinsic, "llvm.arm.isb")
    void __builtin_arm_isb(int);

pragma(LDC_intrinsic, "llvm.arm.mcr")
    void __builtin_arm_mcr(int, int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.mcr2")
    void __builtin_arm_mcr2(int, int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.mcrr")
    void __builtin_arm_mcrr(int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.mcrr2")
    void __builtin_arm_mcrr2(int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.mrc")
    int __builtin_arm_mrc(int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.mrc2")
    int __builtin_arm_mrc2(int, int, int, int, int);

pragma(LDC_intrinsic, "llvm.arm.qadd")
    int __builtin_arm_qadd(int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.arm.qsub")
    int __builtin_arm_qsub(int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.arm.set.fpscr")
    void __builtin_arm_set_fpscr(int);

pragma(LDC_intrinsic, "llvm.arm.ssat")
    int __builtin_arm_ssat(int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.arm.thread.pointer")
    void* __builtin_thread_pointer() pure @safe;

pragma(LDC_intrinsic, "llvm.arm.usat")
    int __builtin_arm_usat(int, int) pure @safe;

