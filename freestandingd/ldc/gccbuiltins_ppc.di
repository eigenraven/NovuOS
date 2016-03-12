module ldc.gccbuiltins_ppc; 

import core.simd;

nothrow @nogc:

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vcipher")
    long2 __builtin_altivec_crypto_vcipher(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vcipherlast")
    long2 __builtin_altivec_crypto_vcipherlast(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vncipher")
    long2 __builtin_altivec_crypto_vncipher(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vncipherlast")
    long2 __builtin_altivec_crypto_vncipherlast(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vpermxor")
    byte16 __builtin_altivec_crypto_vpermxor(byte16, byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vpmsumb")
    byte16 __builtin_altivec_crypto_vpmsumb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vpmsumd")
    long2 __builtin_altivec_crypto_vpmsumd(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vpmsumh")
    short8 __builtin_altivec_crypto_vpmsumh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vpmsumw")
    int4 __builtin_altivec_crypto_vpmsumw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vsbox")
    long2 __builtin_altivec_crypto_vsbox(long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vshasigmad")
    long2 __builtin_altivec_crypto_vshasigmad(long2, int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.crypto.vshasigmaw")
    int4 __builtin_altivec_crypto_vshasigmaw(int4, int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.dss")
    void __builtin_altivec_dss(int);

pragma(LDC_intrinsic, "llvm.ppc.altivec.dssall")
    void __builtin_altivec_dssall();

pragma(LDC_intrinsic, "llvm.ppc.altivec.dst")
    void __builtin_altivec_dst(void*, int, int);

pragma(LDC_intrinsic, "llvm.ppc.altivec.dstst")
    void __builtin_altivec_dstst(void*, int, int);

pragma(LDC_intrinsic, "llvm.ppc.altivec.dststt")
    void __builtin_altivec_dststt(void*, int, int);

pragma(LDC_intrinsic, "llvm.ppc.altivec.dstt")
    void __builtin_altivec_dstt(void*, int, int);

pragma(LDC_intrinsic, "llvm.ppc.altivec.mfvscr")
    short8 __builtin_altivec_mfvscr();

pragma(LDC_intrinsic, "llvm.ppc.altivec.mtvscr")
    void __builtin_altivec_mtvscr(int4);

pragma(LDC_intrinsic, "llvm.ppc.altivec.vaddcuw")
    int4 __builtin_altivec_vaddcuw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vaddsbs")
    byte16 __builtin_altivec_vaddsbs(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vaddshs")
    short8 __builtin_altivec_vaddshs(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vaddsws")
    int4 __builtin_altivec_vaddsws(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vaddubs")
    byte16 __builtin_altivec_vaddubs(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vadduhs")
    short8 __builtin_altivec_vadduhs(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vadduws")
    int4 __builtin_altivec_vadduws(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vavgsb")
    byte16 __builtin_altivec_vavgsb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vavgsh")
    short8 __builtin_altivec_vavgsh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vavgsw")
    int4 __builtin_altivec_vavgsw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vavgub")
    byte16 __builtin_altivec_vavgub(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vavguh")
    short8 __builtin_altivec_vavguh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vavguw")
    int4 __builtin_altivec_vavguw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vbpermq")
    long2 __builtin_altivec_vbpermq(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcfsx")
    float4 __builtin_altivec_vcfsx(int4, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcfux")
    float4 __builtin_altivec_vcfux(int4, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpbfp")
    int4 __builtin_altivec_vcmpbfp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpbfp.p")
    int __builtin_altivec_vcmpbfp_p(int, float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpeqfp")
    int4 __builtin_altivec_vcmpeqfp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpeqfp.p")
    int __builtin_altivec_vcmpeqfp_p(int, float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequb")
    byte16 __builtin_altivec_vcmpequb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequb.p")
    int __builtin_altivec_vcmpequb_p(int, byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequd")
    long2 __builtin_altivec_vcmpequd(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequd.p")
    int __builtin_altivec_vcmpequd_p(int, long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequh")
    short8 __builtin_altivec_vcmpequh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequh.p")
    int __builtin_altivec_vcmpequh_p(int, short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequw")
    int4 __builtin_altivec_vcmpequw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpequw.p")
    int __builtin_altivec_vcmpequw_p(int, int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgefp")
    int4 __builtin_altivec_vcmpgefp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgefp.p")
    int __builtin_altivec_vcmpgefp_p(int, float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtfp")
    int4 __builtin_altivec_vcmpgtfp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtfp.p")
    int __builtin_altivec_vcmpgtfp_p(int, float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsb")
    byte16 __builtin_altivec_vcmpgtsb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsb.p")
    int __builtin_altivec_vcmpgtsb_p(int, byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsd")
    long2 __builtin_altivec_vcmpgtsd(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsd.p")
    int __builtin_altivec_vcmpgtsd_p(int, long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsh")
    short8 __builtin_altivec_vcmpgtsh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsh.p")
    int __builtin_altivec_vcmpgtsh_p(int, short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsw")
    int4 __builtin_altivec_vcmpgtsw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtsw.p")
    int __builtin_altivec_vcmpgtsw_p(int, int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtub")
    byte16 __builtin_altivec_vcmpgtub(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtub.p")
    int __builtin_altivec_vcmpgtub_p(int, byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtud")
    long2 __builtin_altivec_vcmpgtud(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtud.p")
    int __builtin_altivec_vcmpgtud_p(int, long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtuh")
    short8 __builtin_altivec_vcmpgtuh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtuh.p")
    int __builtin_altivec_vcmpgtuh_p(int, short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtuw")
    int4 __builtin_altivec_vcmpgtuw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vcmpgtuw.p")
    int __builtin_altivec_vcmpgtuw_p(int, int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vctsxs")
    int4 __builtin_altivec_vctsxs(float4, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vctuxs")
    int4 __builtin_altivec_vctuxs(float4, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vexptefp")
    float4 __builtin_altivec_vexptefp(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vgbbd")
    byte16 __builtin_altivec_vgbbd(byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vlogefp")
    float4 __builtin_altivec_vlogefp(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaddfp")
    float4 __builtin_altivec_vmaddfp(float4, float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxfp")
    float4 __builtin_altivec_vmaxfp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxsb")
    byte16 __builtin_altivec_vmaxsb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxsd")
    long2 __builtin_altivec_vmaxsd(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxsh")
    short8 __builtin_altivec_vmaxsh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxsw")
    int4 __builtin_altivec_vmaxsw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxub")
    byte16 __builtin_altivec_vmaxub(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxud")
    long2 __builtin_altivec_vmaxud(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxuh")
    short8 __builtin_altivec_vmaxuh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmaxuw")
    int4 __builtin_altivec_vmaxuw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmhaddshs")
    short8 __builtin_altivec_vmhaddshs(short8, short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmhraddshs")
    short8 __builtin_altivec_vmhraddshs(short8, short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminfp")
    float4 __builtin_altivec_vminfp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminsb")
    byte16 __builtin_altivec_vminsb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminsd")
    long2 __builtin_altivec_vminsd(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminsh")
    short8 __builtin_altivec_vminsh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminsw")
    int4 __builtin_altivec_vminsw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminub")
    byte16 __builtin_altivec_vminub(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminud")
    long2 __builtin_altivec_vminud(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminuh")
    short8 __builtin_altivec_vminuh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vminuw")
    int4 __builtin_altivec_vminuw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmladduhm")
    short8 __builtin_altivec_vmladduhm(short8, short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmsummbm")
    int4 __builtin_altivec_vmsummbm(byte16, byte16, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmsumshm")
    int4 __builtin_altivec_vmsumshm(short8, short8, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmsumshs")
    int4 __builtin_altivec_vmsumshs(short8, short8, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmsumubm")
    int4 __builtin_altivec_vmsumubm(byte16, byte16, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmsumuhm")
    int4 __builtin_altivec_vmsumuhm(short8, short8, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmsumuhs")
    int4 __builtin_altivec_vmsumuhs(short8, short8, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulesb")
    short8 __builtin_altivec_vmulesb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulesh")
    int4 __builtin_altivec_vmulesh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulesw")
    long2 __builtin_altivec_vmulesw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmuleub")
    short8 __builtin_altivec_vmuleub(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmuleuh")
    int4 __builtin_altivec_vmuleuh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmuleuw")
    long2 __builtin_altivec_vmuleuw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulosb")
    short8 __builtin_altivec_vmulosb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulosh")
    int4 __builtin_altivec_vmulosh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulosw")
    long2 __builtin_altivec_vmulosw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmuloub")
    short8 __builtin_altivec_vmuloub(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulouh")
    int4 __builtin_altivec_vmulouh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vmulouw")
    long2 __builtin_altivec_vmulouw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vnmsubfp")
    float4 __builtin_altivec_vnmsubfp(float4, float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vperm")
    int4 __builtin_altivec_vperm_4si(int4, int4, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkpx")
    short8 __builtin_altivec_vpkpx(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpksdss")
    int4 __builtin_altivec_vpksdss(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpksdus")
    int4 __builtin_altivec_vpksdus(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkshss")
    byte16 __builtin_altivec_vpkshss(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkshus")
    byte16 __builtin_altivec_vpkshus(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkswss")
    byte16 __builtin_altivec_vpkswss(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkswus")
    short8 __builtin_altivec_vpkswus(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkudus")
    int4 __builtin_altivec_vpkudus(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkuhus")
    byte16 __builtin_altivec_vpkuhus(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vpkuwus")
    short8 __builtin_altivec_vpkuwus(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrefp")
    float4 __builtin_altivec_vrefp(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrfim")
    float4 __builtin_altivec_vrfim(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrfin")
    float4 __builtin_altivec_vrfin(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrfip")
    float4 __builtin_altivec_vrfip(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrfiz")
    float4 __builtin_altivec_vrfiz(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrlb")
    byte16 __builtin_altivec_vrlb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrld")
    long2 __builtin_altivec_vrld(long2, long2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrlh")
    short8 __builtin_altivec_vrlh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrlw")
    int4 __builtin_altivec_vrlw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vrsqrtefp")
    float4 __builtin_altivec_vrsqrtefp(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsel")
    int4 __builtin_altivec_vsel_4si(int4, int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsl")
    int4 __builtin_altivec_vsl(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vslb")
    byte16 __builtin_altivec_vslb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vslh")
    short8 __builtin_altivec_vslh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vslo")
    int4 __builtin_altivec_vslo(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vslw")
    int4 __builtin_altivec_vslw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsr")
    int4 __builtin_altivec_vsr(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsrab")
    byte16 __builtin_altivec_vsrab(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsrah")
    short8 __builtin_altivec_vsrah(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsraw")
    int4 __builtin_altivec_vsraw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsrb")
    byte16 __builtin_altivec_vsrb(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsrh")
    short8 __builtin_altivec_vsrh(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsro")
    int4 __builtin_altivec_vsro(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsrw")
    int4 __builtin_altivec_vsrw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsubcuw")
    int4 __builtin_altivec_vsubcuw(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsubsbs")
    byte16 __builtin_altivec_vsubsbs(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsubshs")
    short8 __builtin_altivec_vsubshs(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsubsws")
    int4 __builtin_altivec_vsubsws(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsububs")
    byte16 __builtin_altivec_vsububs(byte16, byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsubuhs")
    short8 __builtin_altivec_vsubuhs(short8, short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsubuws")
    int4 __builtin_altivec_vsubuws(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsum2sws")
    int4 __builtin_altivec_vsum2sws(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsum4sbs")
    int4 __builtin_altivec_vsum4sbs(byte16, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsum4shs")
    int4 __builtin_altivec_vsum4shs(short8, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsum4ubs")
    int4 __builtin_altivec_vsum4ubs(byte16, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vsumsws")
    int4 __builtin_altivec_vsumsws(int4, int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupkhpx")
    int4 __builtin_altivec_vupkhpx(short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupkhsb")
    short8 __builtin_altivec_vupkhsb(byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupkhsh")
    int4 __builtin_altivec_vupkhsh(short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupkhsw")
    long2 __builtin_altivec_vupkhsw(int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupklpx")
    int4 __builtin_altivec_vupklpx(short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupklsb")
    short8 __builtin_altivec_vupklsb(byte16) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupklsh")
    int4 __builtin_altivec_vupklsh(short8) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.altivec.vupklsw")
    long2 __builtin_altivec_vupklsw(int4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.bpermd")
    long __builtin_bpermd(long, long) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.divde")
    long __builtin_divde(long, long) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.divdeu")
    long __builtin_divdeu(long, long) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.divwe")
    int __builtin_divwe(int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.divweu")
    int __builtin_divweu(int, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.get.texasr")
    long __builtin_get_texasr();

pragma(LDC_intrinsic, "llvm.ppc.get.texasru")
    long __builtin_get_texasru();

pragma(LDC_intrinsic, "llvm.ppc.get.tfhar")
    long __builtin_get_tfhar();

pragma(LDC_intrinsic, "llvm.ppc.get.tfiar")
    long __builtin_get_tfiar();

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfabs")
    double4 __builtin_qpx_qvfabs(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfadd")
    double4 __builtin_qpx_qvfadd(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfadds")
    double4 __builtin_qpx_qvfadds(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcfid")
    double4 __builtin_qpx_qvfcfid(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcfids")
    double4 __builtin_qpx_qvfcfids(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcfidu")
    double4 __builtin_qpx_qvfcfidu(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcfidus")
    double4 __builtin_qpx_qvfcfidus(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcmpeq")
    double4 __builtin_qpx_qvfcmpeq(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcmpgt")
    double4 __builtin_qpx_qvfcmpgt(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcmplt")
    double4 __builtin_qpx_qvfcmplt(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfcpsgn")
    double4 __builtin_qpx_qvfcpsgn(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctid")
    double4 __builtin_qpx_qvfctid(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctidu")
    double4 __builtin_qpx_qvfctidu(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctiduz")
    double4 __builtin_qpx_qvfctiduz(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctidz")
    double4 __builtin_qpx_qvfctidz(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctiw")
    double4 __builtin_qpx_qvfctiw(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctiwu")
    double4 __builtin_qpx_qvfctiwu(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctiwuz")
    double4 __builtin_qpx_qvfctiwuz(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfctiwz")
    double4 __builtin_qpx_qvfctiwz(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvflogical")
    double4 __builtin_qpx_qvflogical(double4, double4, int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfmadd")
    double4 __builtin_qpx_qvfmadd(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfmadds")
    double4 __builtin_qpx_qvfmadds(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfmsub")
    double4 __builtin_qpx_qvfmsub(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfmsubs")
    double4 __builtin_qpx_qvfmsubs(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfmul")
    double4 __builtin_qpx_qvfmul(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfmuls")
    double4 __builtin_qpx_qvfmuls(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfnabs")
    double4 __builtin_qpx_qvfnabs(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfneg")
    double4 __builtin_qpx_qvfneg(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfnmadd")
    double4 __builtin_qpx_qvfnmadd(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfnmadds")
    double4 __builtin_qpx_qvfnmadds(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfnmsub")
    double4 __builtin_qpx_qvfnmsub(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfnmsubs")
    double4 __builtin_qpx_qvfnmsubs(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfperm")
    double4 __builtin_qpx_qvfperm(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfre")
    double4 __builtin_qpx_qvfre(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfres")
    double4 __builtin_qpx_qvfres(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfrim")
    double4 __builtin_qpx_qvfrim(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfrin")
    double4 __builtin_qpx_qvfrin(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfrip")
    double4 __builtin_qpx_qvfrip(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfriz")
    double4 __builtin_qpx_qvfriz(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfrsp")
    double4 __builtin_qpx_qvfrsp(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfrsqrte")
    double4 __builtin_qpx_qvfrsqrte(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfrsqrtes")
    double4 __builtin_qpx_qvfrsqrtes(double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfsel")
    double4 __builtin_qpx_qvfsel(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfsub")
    double4 __builtin_qpx_qvfsub(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfsubs")
    double4 __builtin_qpx_qvfsubs(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvftstnan")
    double4 __builtin_qpx_qvftstnan(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxmadd")
    double4 __builtin_qpx_qvfxmadd(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxmadds")
    double4 __builtin_qpx_qvfxmadds(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxmul")
    double4 __builtin_qpx_qvfxmul(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxmuls")
    double4 __builtin_qpx_qvfxmuls(double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxxcpnmadd")
    double4 __builtin_qpx_qvfxxcpnmadd(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxxcpnmadds")
    double4 __builtin_qpx_qvfxxcpnmadds(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxxmadd")
    double4 __builtin_qpx_qvfxxmadd(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxxmadds")
    double4 __builtin_qpx_qvfxxmadds(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxxnpmadd")
    double4 __builtin_qpx_qvfxxnpmadd(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvfxxnpmadds")
    double4 __builtin_qpx_qvfxxnpmadds(double4, double4, double4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvgpci")
    double4 __builtin_qpx_qvgpci(int) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfcd")
    double4 __builtin_qpx_qvlfcd(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfcda")
    double4 __builtin_qpx_qvlfcda(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfcs")
    double4 __builtin_qpx_qvlfcs(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfcsa")
    double4 __builtin_qpx_qvlfcsa(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfd")
    double4 __builtin_qpx_qvlfd(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfda")
    double4 __builtin_qpx_qvlfda(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfiwa")
    double4 __builtin_qpx_qvlfiwa(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfiwaa")
    double4 __builtin_qpx_qvlfiwaa(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfiwz")
    double4 __builtin_qpx_qvlfiwz(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfiwza")
    double4 __builtin_qpx_qvlfiwza(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfs")
    double4 __builtin_qpx_qvlfs(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlfsa")
    double4 __builtin_qpx_qvlfsa(const void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlpcld")
    double4 __builtin_qpx_qvlpcld(void*) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlpcls")
    double4 __builtin_qpx_qvlpcls(void*) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlpcrd")
    double4 __builtin_qpx_qvlpcrd(void*) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvlpcrs")
    double4 __builtin_qpx_qvlpcrs(void*) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfcd")
    void __builtin_qpx_qvstfcd(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfcda")
    void __builtin_qpx_qvstfcda(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfcs")
    void __builtin_qpx_qvstfcs(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfcsa")
    void __builtin_qpx_qvstfcsa(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfd")
    void __builtin_qpx_qvstfd(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfda")
    void __builtin_qpx_qvstfda(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfiw")
    void __builtin_qpx_qvstfiw(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfiwa")
    void __builtin_qpx_qvstfiwa(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfs")
    void __builtin_qpx_qvstfs(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.qpx.qvstfsa")
    void __builtin_qpx_qvstfsa(double4, void*) pure;

pragma(LDC_intrinsic, "llvm.ppc.set.texasr")
    void __builtin_set_texasr(long);

pragma(LDC_intrinsic, "llvm.ppc.set.texasru")
    void __builtin_set_texasru(long);

pragma(LDC_intrinsic, "llvm.ppc.set.tfhar")
    void __builtin_set_tfhar(long);

pragma(LDC_intrinsic, "llvm.ppc.set.tfiar")
    void __builtin_set_tfiar(long);

pragma(LDC_intrinsic, "llvm.ppc.tabort")
    int __builtin_tabort(int);

pragma(LDC_intrinsic, "llvm.ppc.tabortdc")
    int __builtin_tabortdc(int, int, int);

pragma(LDC_intrinsic, "llvm.ppc.tabortdci")
    int __builtin_tabortdci(int, int, int);

pragma(LDC_intrinsic, "llvm.ppc.tabortwc")
    int __builtin_tabortwc(int, int, int);

pragma(LDC_intrinsic, "llvm.ppc.tabortwci")
    int __builtin_tabortwci(int, int, int);

pragma(LDC_intrinsic, "llvm.ppc.tbegin")
    int __builtin_tbegin(int);

pragma(LDC_intrinsic, "llvm.ppc.tcheck")
    int __builtin_tcheck();

pragma(LDC_intrinsic, "llvm.ppc.tend")
    int __builtin_tend(int);

pragma(LDC_intrinsic, "llvm.ppc.tendall")
    int __builtin_tendall();

pragma(LDC_intrinsic, "llvm.ppc.trechkpt")
    int __builtin_trechkpt();

pragma(LDC_intrinsic, "llvm.ppc.treclaim")
    int __builtin_treclaim(int);

pragma(LDC_intrinsic, "llvm.ppc.tresume")
    int __builtin_tresume();

pragma(LDC_intrinsic, "llvm.ppc.tsr")
    int __builtin_tsr(int);

pragma(LDC_intrinsic, "llvm.ppc.tsuspend")
    int __builtin_tsuspend();

pragma(LDC_intrinsic, "llvm.ppc.ttest")
    long __builtin_ttest();

pragma(LDC_intrinsic, "llvm.ppc.vsx.xsmaxdp")
    double __builtin_vsx_xsmaxdp(double, double) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xsmindp")
    double __builtin_vsx_xsmindp(double, double) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvcmpeqdp")
    long2 __builtin_vsx_xvcmpeqdp(double2, double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvcmpeqsp")
    int4 __builtin_vsx_xvcmpeqsp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvcmpgedp")
    long2 __builtin_vsx_xvcmpgedp(double2, double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvcmpgesp")
    int4 __builtin_vsx_xvcmpgesp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvcmpgtdp")
    long2 __builtin_vsx_xvcmpgtdp(double2, double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvcmpgtsp")
    int4 __builtin_vsx_xvcmpgtsp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvdivdp")
    double2 __builtin_vsx_xvdivdp(double2, double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvdivsp")
    float4 __builtin_vsx_xvdivsp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvmaxdp")
    double2 __builtin_vsx_xvmaxdp(double2, double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvmaxsp")
    float4 __builtin_vsx_xvmaxsp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvmindp")
    double2 __builtin_vsx_xvmindp(double2, double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvminsp")
    float4 __builtin_vsx_xvminsp(float4, float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvredp")
    double2 __builtin_vsx_xvredp(double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvresp")
    float4 __builtin_vsx_xvresp(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvrsqrtedp")
    double2 __builtin_vsx_xvrsqrtedp(double2) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xvrsqrtesp")
    float4 __builtin_vsx_xvrsqrtesp(float4) pure @safe;

pragma(LDC_intrinsic, "llvm.ppc.vsx.xxleqv")
    int4 __builtin_vsx_xxleqv(int4, int4) pure @safe;

