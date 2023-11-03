; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mtriple=arm-eabi -mattr=v7,neon | FileCheck %s --check-prefixes=CHECK,CHECK-LE
; RUN: llc -verify-machineinstrs < %s -mtriple=armeb-eabi -mattr=v7,neon | FileCheck %s --check-prefixes=CHECK,CHECK-BE

@var32 = global i32 0
@vardouble = global double 0.0

define void @arg_longint( i64 %val ) {
; CHECK-LE-LABEL: arg_longint:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    movw r1, :lower16:var32
; CHECK-LE-NEXT:    movt r1, :upper16:var32
; CHECK-LE-NEXT:    str r0, [r1]
; CHECK-LE-NEXT:    bx lr
;
; CHECK-BE-LABEL: arg_longint:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    movw r0, :lower16:var32
; CHECK-BE-NEXT:    movt r0, :upper16:var32
; CHECK-BE-NEXT:    str r1, [r0]
; CHECK-BE-NEXT:    bx lr
   %tmp = trunc i64 %val to i32
   store i32 %tmp, i32* @var32
   ret void
}

define void @arg_double( double %val ) {
; CHECK-LABEL: arg_double:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movw r2, :lower16:vardouble
; CHECK-NEXT:    movt r2, :upper16:vardouble
; CHECK-NEXT:    strd r0, r1, [r2]
; CHECK-NEXT:    bx lr
    store double  %val, double* @vardouble
    ret void
}

define void @arg_v4i32(<4 x i32> %vec ) {
; CHECK-LE-LABEL: arg_v4i32:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    vmov d16, r0, r1
; CHECK-LE-NEXT:    movw r0, :lower16:var32
; CHECK-LE-NEXT:    movt r0, :upper16:var32
; CHECK-LE-NEXT:    vst1.32 {d16[0]}, [r0:32]
; CHECK-LE-NEXT:    bx lr
;
; CHECK-BE-LABEL: arg_v4i32:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    vmov d16, r1, r0
; CHECK-BE-NEXT:    movw r0, :lower16:var32
; CHECK-BE-NEXT:    movt r0, :upper16:var32
; CHECK-BE-NEXT:    vrev64.32 q8, q8
; CHECK-BE-NEXT:    vst1.32 {d16[0]}, [r0:32]
; CHECK-BE-NEXT:    bx lr
    %tmp = extractelement <4 x i32> %vec, i32 0
    store i32 %tmp, i32* @var32
    ret void
}

define void @arg_v2f64(<2 x double> %vec ) {
; CHECK-LABEL: arg_v2f64:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movw r2, :lower16:vardouble
; CHECK-NEXT:    movt r2, :upper16:vardouble
; CHECK-NEXT:    strd r0, r1, [r2]
; CHECK-NEXT:    bx lr
    %tmp = extractelement <2 x double> %vec, i32 0
    store double %tmp, double* @vardouble
    ret void
}

define i64 @return_longint() {
; CHECK-LE-LABEL: return_longint:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    mov r0, #42
; CHECK-LE-NEXT:    mov r1, #0
; CHECK-LE-NEXT:    bx lr
;
; CHECK-BE-LABEL: return_longint:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    mov r0, #0
; CHECK-BE-NEXT:    mov r1, #42
; CHECK-BE-NEXT:    bx lr
    ret i64 42
}

define double @return_double() {
; CHECK-LE-LABEL: return_double:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    vmov.f64 d16, #1.000000e+00
; CHECK-LE-NEXT:    vmov r0, r1, d16
; CHECK-LE-NEXT:    bx lr
;
; CHECK-BE-LABEL: return_double:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    vmov.f64 d16, #1.000000e+00
; CHECK-BE-NEXT:    vmov r1, r0, d16
; CHECK-BE-NEXT:    bx lr
    ret double 1.0
}

define <4 x i32> @return_v4i32() {
; CHECK-LE-LABEL: return_v4i32:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    adr r0, .LCPI6_0
; CHECK-LE-NEXT:    vld1.64 {d16, d17}, [r0:128]
; CHECK-LE-NEXT:    vmov r0, r1, d16
; CHECK-LE-NEXT:    vmov r2, r3, d17
; CHECK-LE-NEXT:    bx lr
; CHECK-LE-NEXT:    .p2align 4
; CHECK-LE-NEXT:  @ %bb.1:
; CHECK-LE-NEXT:  .LCPI6_0:
; CHECK-LE-NEXT:    .long 42 @ double 9.1245819032257467E-313
; CHECK-LE-NEXT:    .long 43
; CHECK-LE-NEXT:    .long 44 @ double 9.5489810615176143E-313
; CHECK-LE-NEXT:    .long 45
;
; CHECK-BE-LABEL: return_v4i32:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    adr r0, .LCPI6_0
; CHECK-BE-NEXT:    vld1.64 {d16, d17}, [r0:128]
; CHECK-BE-NEXT:    vmov r1, r0, d16
; CHECK-BE-NEXT:    vmov r3, r2, d17
; CHECK-BE-NEXT:    bx lr
; CHECK-BE-NEXT:    .p2align 4
; CHECK-BE-NEXT:  @ %bb.1:
; CHECK-BE-NEXT:  .LCPI6_0:
; CHECK-BE-NEXT:    .long 42 @ double 8.912382324178626E-313
; CHECK-BE-NEXT:    .long 43
; CHECK-BE-NEXT:    .long 44 @ double 9.3367814824704935E-313
; CHECK-BE-NEXT:    .long 45
   ret < 4 x i32> < i32 42, i32 43, i32 44, i32 45 >
}

define <2 x double> @return_v2f64() {
; CHECK-LE-LABEL: return_v2f64:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    vldr d16, .LCPI7_0
; CHECK-LE-NEXT:    vldr d17, .LCPI7_1
; CHECK-LE-NEXT:    vmov r0, r1, d16
; CHECK-LE-NEXT:    vmov r2, r3, d17
; CHECK-LE-NEXT:    bx lr
; CHECK-LE-NEXT:    .p2align 3
; CHECK-LE-NEXT:  @ %bb.1:
; CHECK-LE-NEXT:  .LCPI7_0:
; CHECK-LE-NEXT:    .long 1374389535 @ double 3.1400000000000001
; CHECK-LE-NEXT:    .long 1074339512
; CHECK-LE-NEXT:  .LCPI7_1:
; CHECK-LE-NEXT:    .long 1374389535 @ double 6.2800000000000002
; CHECK-LE-NEXT:    .long 1075388088
;
; CHECK-BE-LABEL: return_v2f64:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    vldr d16, .LCPI7_0
; CHECK-BE-NEXT:    vldr d17, .LCPI7_1
; CHECK-BE-NEXT:    vmov r1, r0, d16
; CHECK-BE-NEXT:    vmov r3, r2, d17
; CHECK-BE-NEXT:    bx lr
; CHECK-BE-NEXT:    .p2align 3
; CHECK-BE-NEXT:  @ %bb.1:
; CHECK-BE-NEXT:  .LCPI7_0:
; CHECK-BE-NEXT:    .long 1074339512 @ double 3.1400000000000001
; CHECK-BE-NEXT:    .long 1374389535
; CHECK-BE-NEXT:  .LCPI7_1:
; CHECK-BE-NEXT:    .long 1075388088 @ double 6.2800000000000002
; CHECK-BE-NEXT:    .long 1374389535
   ret <2 x double> < double 3.14, double 6.28 >
}

define void @caller_arg_longint() {
; CHECK-LE-LABEL: caller_arg_longint:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    .save {r11, lr}
; CHECK-LE-NEXT:    push {r11, lr}
; CHECK-LE-NEXT:    mov r0, #42
; CHECK-LE-NEXT:    mov r1, #0
; CHECK-LE-NEXT:    bl arg_longint
; CHECK-LE-NEXT:    pop {r11, pc}
;
; CHECK-BE-LABEL: caller_arg_longint:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    .save {r11, lr}
; CHECK-BE-NEXT:    push {r11, lr}
; CHECK-BE-NEXT:    mov r0, #0
; CHECK-BE-NEXT:    mov r1, #42
; CHECK-BE-NEXT:    bl arg_longint
; CHECK-BE-NEXT:    pop {r11, pc}
   call void @arg_longint( i64 42 )
   ret void
}

define void @caller_arg_double() {
; CHECK-LE-LABEL: caller_arg_double:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    .save {r11, lr}
; CHECK-LE-NEXT:    push {r11, lr}
; CHECK-LE-NEXT:    vmov.f64 d16, #1.000000e+00
; CHECK-LE-NEXT:    vmov r0, r1, d16
; CHECK-LE-NEXT:    bl arg_double
; CHECK-LE-NEXT:    pop {r11, pc}
;
; CHECK-BE-LABEL: caller_arg_double:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    .save {r11, lr}
; CHECK-BE-NEXT:    push {r11, lr}
; CHECK-BE-NEXT:    vmov.f64 d16, #1.000000e+00
; CHECK-BE-NEXT:    vmov r1, r0, d16
; CHECK-BE-NEXT:    bl arg_double
; CHECK-BE-NEXT:    pop {r11, pc}
   call void @arg_double( double 1.0 )
   ret void
}

define void @caller_return_longint() {
; CHECK-LE-LABEL: caller_return_longint:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    .save {r11, lr}
; CHECK-LE-NEXT:    push {r11, lr}
; CHECK-LE-NEXT:    bl return_longint
; CHECK-LE-NEXT:    movw r1, :lower16:var32
; CHECK-LE-NEXT:    movt r1, :upper16:var32
; CHECK-LE-NEXT:    str r0, [r1]
; CHECK-LE-NEXT:    pop {r11, pc}
;
; CHECK-BE-LABEL: caller_return_longint:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    .save {r11, lr}
; CHECK-BE-NEXT:    push {r11, lr}
; CHECK-BE-NEXT:    bl return_longint
; CHECK-BE-NEXT:    movw r0, :lower16:var32
; CHECK-BE-NEXT:    movt r0, :upper16:var32
; CHECK-BE-NEXT:    str r1, [r0]
; CHECK-BE-NEXT:    pop {r11, pc}
   %val = call i64 @return_longint()
   %tmp = trunc i64 %val to i32
   store i32 %tmp, i32* @var32
   ret void
}

define void @caller_return_double() {
; CHECK-LE-LABEL: caller_return_double:
; CHECK-LE:       @ %bb.0:
; CHECK-LE-NEXT:    .save {r11, lr}
; CHECK-LE-NEXT:    push {r11, lr}
; CHECK-LE-NEXT:    bl return_double
; CHECK-LE-NEXT:    vmov d17, r0, r1
; CHECK-LE-NEXT:    vldr d16, .LCPI11_0
; CHECK-LE-NEXT:    movw r0, :lower16:vardouble
; CHECK-LE-NEXT:    vadd.f64 d16, d17, d16
; CHECK-LE-NEXT:    movt r0, :upper16:vardouble
; CHECK-LE-NEXT:    vstr d16, [r0]
; CHECK-LE-NEXT:    pop {r11, pc}
; CHECK-LE-NEXT:    .p2align 3
; CHECK-LE-NEXT:  @ %bb.1:
; CHECK-LE-NEXT:  .LCPI11_0:
; CHECK-LE-NEXT:    .long 1374389535 @ double 3.1400000000000001
; CHECK-LE-NEXT:    .long 1074339512
;
; CHECK-BE-LABEL: caller_return_double:
; CHECK-BE:       @ %bb.0:
; CHECK-BE-NEXT:    .save {r11, lr}
; CHECK-BE-NEXT:    push {r11, lr}
; CHECK-BE-NEXT:    bl return_double
; CHECK-BE-NEXT:    vmov d17, r1, r0
; CHECK-BE-NEXT:    vldr d16, .LCPI11_0
; CHECK-BE-NEXT:    movw r0, :lower16:vardouble
; CHECK-BE-NEXT:    vadd.f64 d16, d17, d16
; CHECK-BE-NEXT:    movt r0, :upper16:vardouble
; CHECK-BE-NEXT:    vstr d16, [r0]
; CHECK-BE-NEXT:    pop {r11, pc}
; CHECK-BE-NEXT:    .p2align 3
; CHECK-BE-NEXT:  @ %bb.1:
; CHECK-BE-NEXT:  .LCPI11_0:
; CHECK-BE-NEXT:    .long 1074339512 @ double 3.1400000000000001
; CHECK-BE-NEXT:    .long 1374389535
  %val = call double @return_double( )
  %tmp = fadd double %val, 3.14
  store double  %tmp, double* @vardouble
  ret void
}

define void @caller_return_v2f64() {
; CHECK-LABEL: caller_return_v2f64:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    .save {r11, lr}
; CHECK-NEXT:    push {r11, lr}
; CHECK-NEXT:    bl return_v2f64
; CHECK-NEXT:    movw r2, :lower16:vardouble
; CHECK-NEXT:    movt r2, :upper16:vardouble
; CHECK-NEXT:    strd r0, r1, [r2]
; CHECK-NEXT:    pop {r11, pc}
   %val = call <2 x double> @return_v2f64( )
   %tmp = extractelement <2 x double> %val, i32 0
    store double %tmp, double* @vardouble
    ret void
}