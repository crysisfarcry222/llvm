; RUN: llc < %s -O2 -mtriple=x86_64-linux-android -mattr=+mmx | FileCheck %s --check-prefix=X64
; RUN: llc < %s -O2 -mtriple=x86_64-linux-gnu -mattr=+mmx | FileCheck %s --check-prefix=X64
; RUN: llc < %s -O2 -mtriple=i686-linux-gnu -mattr=+mmx | FileCheck %s --check-prefix=X32

; Check soft floating point conversion function calls.

@vi32 = common global i32 0, align 4
@vi64 = common global i64 0, align 8
@vu32 = common global i32 0, align 4
@vu64 = common global i64 0, align 8
@vf32 = common global float 0.000000e+00, align 4
@vf64 = common global double 0.000000e+00, align 8
@vf128 = common global fp128 0xL00000000000000000000000000000000, align 16

define void @TestFPExtF32_F128() {
entry:
  %0 = load float, float* @vf32, align 4
  %conv = fpext float %0 to fp128
  store fp128 %conv, fp128* @vf128, align 16
  ret void
; X32-LABEL: TestFPExtF32_F128:
; X32:       flds       vf32
; X32:       fstps
; X32:       calll      __extendsftf2
; X32:       retl
;
; X64-LABEL: TestFPExtF32_F128:
; X64:       movss      vf32(%rip), %xmm0
; X64-NEXT:  callq      __extendsftf2
; X64-NEXT:  movaps     %xmm0, vf128(%rip)
; X64:       retq
}

define void @TestFPExtF64_F128() {
entry:
  %0 = load double, double* @vf64, align 8
  %conv = fpext double %0 to fp128
  store fp128 %conv, fp128* @vf128, align 16
  ret void
; X32-LABEL: TestFPExtF64_F128:
; X32:       fldl       vf64
; X32:       fstpl
; X32:       calll      __extenddftf2
; X32:       retl
;
; X64-LABEL: TestFPExtF64_F128:
; X64:       movsd      vf64(%rip), %xmm0
; X64-NEXT:  callq      __extenddftf2
; X64-NEXT:  movaps     %xmm0, vf128(%rip)
; X64:       ret
}

define void @TestFPToSIF128_I32() {
entry:
  %0 = load fp128, fp128* @vf128, align 16
  %conv = fptosi fp128 %0 to i32
  store i32 %conv, i32* @vi32, align 4
  ret void
; X32-LABEL: TestFPToSIF128_I32:
; X32:       calll      __fixtfsi
; X32:       retl
;
; X64-LABEL: TestFPToSIF128_I32:
; X64:       movaps     vf128(%rip), %xmm0
; X64-NEXT:  callq      __fixtfsi
; X64-NEXT:  movl       %eax, vi32(%rip)
; X64:       retq
}

define void @TestFPToUIF128_U32() {
entry:
  %0 = load fp128, fp128* @vf128, align 16
  %conv = fptoui fp128 %0 to i32
  store i32 %conv, i32* @vu32, align 4
  ret void
; X32-LABEL: TestFPToUIF128_U32:
; X32:       calll      __fixunstfsi
; X32:       retl
;
; X64-LABEL: TestFPToUIF128_U32:
; X64:       movaps     vf128(%rip), %xmm0
; X64-NEXT:  callq      __fixunstfsi
; X64-NEXT:  movl       %eax, vu32(%rip)
; X64:       retq
}

define void @TestFPToSIF128_I64() {
entry:
  %0 = load fp128, fp128* @vf128, align 16
  %conv = fptosi fp128 %0 to i32
  %conv1 = sext i32 %conv to i64
  store i64 %conv1, i64* @vi64, align 8
  ret void
; X32-LABEL: TestFPToSIF128_I64:
; X32:       calll      __fixtfsi
; X32:       retl
;
; X64-LABEL: TestFPToSIF128_I64:
; X64:       movaps      vf128(%rip), %xmm0
; X64-NEXT:  callq       __fixtfsi
; X64-NEXT:  cltq
; X64-NEXT:  movq        %rax, vi64(%rip)
; X64:       retq
}

define void @TestFPToUIF128_U64() {
entry:
  %0 = load fp128, fp128* @vf128, align 16
  %conv = fptoui fp128 %0 to i32
  %conv1 = zext i32 %conv to i64
  store i64 %conv1, i64* @vu64, align 8
  ret void
; X32-LABEL: TestFPToUIF128_U64:
; X32:       calll      __fixunstfsi
; X32:       retl
;
; X64-LABEL: TestFPToUIF128_U64:
; X64:       movaps      vf128(%rip), %xmm0
; X64-NEXT:  callq       __fixunstfsi
; X64-NEXT:  movl        %eax, %eax
; X64-NEXT:  movq        %rax, vu64(%rip)
; X64:       retq
}

define void @TestFPTruncF128_F32() {
entry:
  %0 = load fp128, fp128* @vf128, align 16
  %conv = fptrunc fp128 %0 to float
  store float %conv, float* @vf32, align 4
  ret void
; X32-LABEL: TestFPTruncF128_F32:
; X32:       calll      __trunctfsf2
; X32:       fstps      vf32
; X32:       retl
;
; X64-LABEL: TestFPTruncF128_F32:
; X64:       movaps      vf128(%rip), %xmm0
; X64-NEXT:  callq       __trunctfsf2
; X64-NEXT:  movss       %xmm0, vf32(%rip)
; X64:       retq
}

define void @TestFPTruncF128_F64() {
entry:
  %0 = load fp128, fp128* @vf128, align 16
  %conv = fptrunc fp128 %0 to double
  store double %conv, double* @vf64, align 8
  ret void
; X32-LABEL: TestFPTruncF128_F64:
; X32:       calll      __trunctfdf2
; X32:       fstpl      vf64
; X32:       retl
;
; X64-LABEL: TestFPTruncF128_F64:
; X64:       movaps      vf128(%rip), %xmm0
; X64-NEXT:  callq       __trunctfdf2
; X64-NEXT:  movsd       %xmm0, vf64(%rip)
; X64:       retq
}

define void @TestSIToFPI32_F128() {
entry:
  %0 = load i32, i32* @vi32, align 4
  %conv = sitofp i32 %0 to fp128
  store fp128 %conv, fp128* @vf128, align 16
  ret void
; X32-LABEL: TestSIToFPI32_F128:
; X32:       calll      __floatsitf
; X32:       retl
;
; X64-LABEL: TestSIToFPI32_F128:
; X64:       movl       vi32(%rip), %edi
; X64-NEXT:  callq      __floatsitf
; X64-NEXT:  movaps     %xmm0, vf128(%rip)
; X64:       retq
}

define void @TestUIToFPU32_F128() #2 {
entry:
  %0 = load i32, i32* @vu32, align 4
  %conv = uitofp i32 %0 to fp128
  store fp128 %conv, fp128* @vf128, align 16
  ret void
; X32-LABEL: TestUIToFPU32_F128:
; X32:       calll      __floatunsitf
; X32:       retl
;
; X64-LABEL: TestUIToFPU32_F128:
; X64:       movl       vu32(%rip), %edi
; X64-NEXT:  callq      __floatunsitf
; X64-NEXT:  movaps     %xmm0, vf128(%rip)
; X64:       retq
}

define void @TestSIToFPI64_F128(){
entry:
  %0 = load i64, i64* @vi64, align 8
  %conv = sitofp i64 %0 to fp128
  store fp128 %conv, fp128* @vf128, align 16
  ret void
; X32-LABEL: TestSIToFPI64_F128:
; X32:       calll      __floatditf
; X32:       retl
;
; X64-LABEL: TestSIToFPI64_F128:
; X64:       movq       vi64(%rip), %rdi
; X64-NEXT:  callq      __floatditf
; X64-NEXT:  movaps     %xmm0, vf128(%rip)
; X64:       retq
}

define void @TestUIToFPU64_F128() #2 {
entry:
  %0 = load i64, i64* @vu64, align 8
  %conv = uitofp i64 %0 to fp128
  store fp128 %conv, fp128* @vf128, align 16
  ret void
; X32-LABEL: TestUIToFPU64_F128:
; X32:       calll      __floatunditf
; X32:       retl
;
; X64-LABEL: TestUIToFPU64_F128:
; X64:       movq       vu64(%rip), %rdi
; X64-NEXT:  callq      __floatunditf
; X64-NEXT:  movaps     %xmm0, vf128(%rip)
; X64:       retq
}

define i32 @TestConst128(fp128 %v) {
entry:
  %cmp = fcmp ogt fp128 %v, 0xL00000000000000003FFF000000000000
  %conv = zext i1 %cmp to i32
  ret i32 %conv
; X32-LABEL: TestConst128:
; X32:       calll      __gttf2
; X32:       retl
;
; X64-LABEL: TestConst128:
; X64:       movaps {{.*}}, %xmm1
; X64-NEXT:  callq __gttf2
; X64-NEXT:  xorl
; X64-NEXT:  test
; X64:       retq
}

; C code:
;  struct TestBits_ieee_ext {
;    unsigned v1;
;    unsigned v2;
; };
; union TestBits_LDU {
;   FP128 ld;
;   struct TestBits_ieee_ext bits;
; };
; int TestBits128(FP128 ld) {
;   union TestBits_LDU u;
;   u.ld = ld * ld;
;   return ((u.bits.v1 | u.bits.v2)  == 0);
; }
define i32 @TestBits128(fp128 %ld) {
entry:
  %mul = fmul fp128 %ld, %ld
  %0 = bitcast fp128 %mul to i128
  %shift = lshr i128 %0, 32
  %or5 = or i128 %shift, %0
  %or = trunc i128 %or5 to i32
  %cmp = icmp eq i32 %or, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
; X32-LABEL: TestBits128:
; X32:       calll      __multf3
; X32:       retl
;
; X64-LABEL: TestBits128:
; X64:       movaps %xmm0, %xmm1
; X64-NEXT:  callq __multf3
; X64-NEXT:  movaps %xmm0, (%rsp)
; X64-NEXT:  movq (%rsp),
; X64-NEXT:  movq %
; X64-NEXT:  shrq $32,
; X64:       xorl %eax, %eax
; X64-NEXT:  orl
; X64-NEXT:  sete %al
; X64:       retq
;
; If TestBits128 fails due to any llvm or clang change,
; please make sure the original simplified C code will
; be compiled into correct IL and assembly code, not
; just this TestBits128 test case. Better yet, try to
; test the whole libm and its test cases.
}

; C code: (compiled with -target x86_64-linux-android)
; typedef long double __float128;
; __float128 TestPair128(unsigned long a, unsigned long b) {
;   unsigned __int128 n;
;   unsigned __int128 v1 = ((unsigned __int128)a << 64);
;   unsigned __int128 v2 = (unsigned __int128)b;
;   n = (v1 | v2) + 3;
;   return *(__float128*)&n;
; }
define fp128 @TestPair128(i64 %a, i64 %b) {
entry:
  %conv = zext i64 %a to i128
  %shl = shl nuw i128 %conv, 64
  %conv1 = zext i64 %b to i128
  %or = or i128 %shl, %conv1
  %add = add i128 %or, 3
  %0 = bitcast i128 %add to fp128
  ret fp128 %0
; X32-LABEL: TestPair128:
; X32:       addl
; X32-NEXT:  adcl
; X32-NEXT:  adcl
; X32-NEXT:  adcl
; X32:       retl
;
; X64-LABEL: TestPair128:
; X64:       addq $3, %rsi
; X64:       movq %rsi, -24(%rsp)
; X64:       movq %rdi, -16(%rsp)
; X64:       movaps -24(%rsp), %xmm0
; X64-NEXT:  retq
}

define fp128 @TestTruncCopysign(fp128 %x, i32 %n) {
entry:
  %cmp = icmp sgt i32 %n, 50000
  br i1 %cmp, label %if.then, label %cleanup

if.then:                                          ; preds = %entry
  %conv = fptrunc fp128 %x to double
  %call = tail call double @copysign(double 0x7FF0000000000000, double %conv) #2
  %conv1 = fpext double %call to fp128
  br label %cleanup

cleanup:                                          ; preds = %entry, %if.then
  %retval.0 = phi fp128 [ %conv1, %if.then ], [ %x, %entry ]
  ret fp128 %retval.0
; X32-LABEL: TestTruncCopysign:
; X32:       calll __trunctfdf2
; X32:       fstpl
; X32:       flds
; X32:       flds
; X32:       fstp
; X32:       fldz
; X32:       fstp
; X32:       fstpl
; X32:       calll __extenddftf2
; X32:       retl
;
; X64-LABEL: TestTruncCopysign:
; X64:       callq __trunctfdf2
; X64-NEXT:  movsd {{.*}}, %xmm1
; X64-NEXT:  movlhps %xmm1, %xmm1
; X64-NEXT:  andps {{.*}}, %xmm0
; X64-NEXT:  orps %xmm1, %xmm0
; X64-NEXT:  callq __extenddftf2
; X64:       retq
}

declare double @copysign(double, double) #1

attributes #2 = { nounwind readnone }
