module ldc.gccbuiltins_aarch64; 

import core.simd;

nothrow @nogc:

pragma(LDC_intrinsic, "llvm.aarch64.dmb")
    void __builtin_arm_dmb(int);

pragma(LDC_intrinsic, "llvm.aarch64.dsb")
    void __builtin_arm_dsb(int);

pragma(LDC_intrinsic, "llvm.aarch64.isb")
    void __builtin_arm_isb(int);

