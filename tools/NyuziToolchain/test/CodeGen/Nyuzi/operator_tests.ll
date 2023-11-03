; RUN: llc -mtriple nyuzi-elf %s -o - | FileCheck %s
; This file is autogenerated by make_operator_tests.py. Do not edit.
;
; This test exhaustively validates arithmetic and compare instruction types,
; with all supported formats. The exception are scalar-only comparisons, which
; are in scalar_compare.ll because LLVM performs a lot of arbitrary transforms
; on them.

target triple = "nyuzi"
define i32 @test_orss(i32 %a, i32 %b) { ; CHECK-LABEL: test_orss:
  %1 = or i32 %a,%b
  ; CHECK: or s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_orvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_orvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = or <16 x i32> %a,%splat
  ; CHECK: or v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_orvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_orvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = or <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: or_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_orvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_orvv:
  %1 = or <16 x i32> %a,%b
  ; CHECK: or v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_orvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_orvvm:
  %1 = or <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: or_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_orsI(i32 %a) { ; CHECK-LABEL: test_orsI:
  %1 = or i32 %a, 27
  ; CHECK: or s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_orvI(<16 x i32> %a) { ; CHECK-LABEL: test_orvI:
  %1 = or <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: or v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_orvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_orvIm:
  %1 = or <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: or_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_andss(i32 %a, i32 %b) { ; CHECK-LABEL: test_andss:
  %1 = and i32 %a,%b
  ; CHECK: and s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_andvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_andvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = and <16 x i32> %a,%splat
  ; CHECK: and v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_andvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_andvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = and <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: and_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_andvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_andvv:
  %1 = and <16 x i32> %a,%b
  ; CHECK: and v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_andvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_andvvm:
  %1 = and <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: and_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_andsI(i32 %a) { ; CHECK-LABEL: test_andsI:
  %1 = and i32 %a, 27
  ; CHECK: and s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_andvI(<16 x i32> %a) { ; CHECK-LABEL: test_andvI:
  %1 = and <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: and v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_andvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_andvIm:
  %1 = and <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: and_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_xorss(i32 %a, i32 %b) { ; CHECK-LABEL: test_xorss:
  %1 = xor i32 %a,%b
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_xorvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_xorvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = xor <16 x i32> %a,%splat
  ; CHECK: xor v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_xorvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_xorvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = xor <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: xor_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_xorvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_xorvv:
  %1 = xor <16 x i32> %a,%b
  ; CHECK: xor v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_xorvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_xorvvm:
  %1 = xor <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: xor_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_xorsI(i32 %a) { ; CHECK-LABEL: test_xorsI:
  %1 = xor i32 %a, 27
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_xorvI(<16 x i32> %a) { ; CHECK-LABEL: test_xorvI:
  %1 = xor <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: xor v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_xorvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_xorvIm:
  %1 = xor <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: xor_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_addss(i32 %a, i32 %b) { ; CHECK-LABEL: test_addss:
  %1 = add i32 %a,%b
  ; CHECK: add_i s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_addvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_addvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = add <16 x i32> %a,%splat
  ; CHECK: add_i v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_addvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_addvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = add <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: add_i_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_addvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_addvv:
  %1 = add <16 x i32> %a,%b
  ; CHECK: add_i v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_addvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_addvvm:
  %1 = add <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: add_i_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_addsI(i32 %a) { ; CHECK-LABEL: test_addsI:
  %1 = add i32 %a, 27
  ; CHECK: add_i s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_addvI(<16 x i32> %a) { ; CHECK-LABEL: test_addvI:
  %1 = add <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: add_i v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_addvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_addvIm:
  %1 = add <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: add_i_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_subss(i32 %a, i32 %b) { ; CHECK-LABEL: test_subss:
  %1 = sub i32 %a,%b
  ; CHECK: sub_i s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_subvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_subvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = sub <16 x i32> %a,%splat
  ; CHECK: sub_i v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_subvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_subvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = sub <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: sub_i_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_subvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_subvv:
  %1 = sub <16 x i32> %a,%b
  ; CHECK: sub_i v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_subvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_subvvm:
  %1 = sub <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: sub_i_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_subvI(<16 x i32> %a) { ; CHECK-LABEL: test_subvI:
  %1 = sub <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: sub_i v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_subvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_subvIm:
  %1 = sub <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: sub_i_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_ashrss(i32 %a, i32 %b) { ; CHECK-LABEL: test_ashrss:
  %1 = ashr i32 %a,%b
  ; CHECK: ashr s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_ashrvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_ashrvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = ashr <16 x i32> %a,%splat
  ; CHECK: ashr v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_ashrvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_ashrvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = ashr <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: ashr_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_ashrvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_ashrvv:
  %1 = ashr <16 x i32> %a,%b
  ; CHECK: ashr v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_ashrvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_ashrvvm:
  %1 = ashr <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: ashr_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_ashrsI(i32 %a) { ; CHECK-LABEL: test_ashrsI:
  %1 = ashr i32 %a, 27
  ; CHECK: ashr s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_ashrvI(<16 x i32> %a) { ; CHECK-LABEL: test_ashrvI:
  %1 = ashr <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: ashr v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_ashrvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_ashrvIm:
  %1 = ashr <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: ashr_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_lshrss(i32 %a, i32 %b) { ; CHECK-LABEL: test_lshrss:
  %1 = lshr i32 %a,%b
  ; CHECK: shr s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_lshrvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_lshrvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = lshr <16 x i32> %a,%splat
  ; CHECK: shr v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_lshrvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_lshrvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = lshr <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: shr_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_lshrvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_lshrvv:
  %1 = lshr <16 x i32> %a,%b
  ; CHECK: shr v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_lshrvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_lshrvvm:
  %1 = lshr <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: shr_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_lshrsI(i32 %a) { ; CHECK-LABEL: test_lshrsI:
  %1 = lshr i32 %a, 27
  ; CHECK: shr s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_lshrvI(<16 x i32> %a) { ; CHECK-LABEL: test_lshrvI:
  %1 = lshr <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: shr v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_lshrvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_lshrvIm:
  %1 = lshr <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: shr_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define i32 @test_shlss(i32 %a, i32 %b) { ; CHECK-LABEL: test_shlss:
  %1 = shl i32 %a,%b
  ; CHECK: shl s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret i32 %1
}

define <16 x i32> @test_shlvs(<16 x i32> %a, i32 %b) { ; CHECK-LABEL: test_shlvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = shl <16 x i32> %a,%splat
  ; CHECK: shl v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_shlvsm(<16 x i32> %a, i32 %b, <16 x i1> %mask) { ; CHECK-LABEL: test_shlvsm:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %1 = shl <16 x i32> %a,%splat
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: shl_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i32> %2
}

define <16 x i32> @test_shlvv(<16 x i32> %a, <16 x i32> %b) { ; CHECK-LABEL: test_shlvv:
  %1 = shl <16 x i32> %a,%b
  ; CHECK: shl v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %1
}

define <16 x i32> @test_shlvvm(<16 x i32> %a, <16 x i32> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_shlvvm:
  %1 = shl <16 x i32> %a,%b
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: shl_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i32> %2
}

define i32 @test_shlsI(i32 %a) { ; CHECK-LABEL: test_shlsI:
  %1 = shl i32 %a, 27
  ; CHECK: shl s{{[0-9]+}}, s{{[0-9]+}}, 27
  ret i32 %1
}

define <16 x i32> @test_shlvI(<16 x i32> %a) { ; CHECK-LABEL: test_shlvI:
  %1 = shl <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: shl v{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %1
}

define <16 x i32> @test_shlvIm(<16 x i32> %a, <16 x i1> %mask) { ; CHECK-LABEL: test_shlvIm:
  %1 = shl <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  %2 = select <16 x i1> %mask, <16 x i32> %1, <16 x i32> %a
  ; CHECK: shl_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i32> %2
}

define float @test_faddss(float %a, float %b) { ; CHECK-LABEL: test_faddss:
  %1 = fadd float %a,%b
  ; CHECK: add_f s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret float %1
}

define <16 x float> @test_faddvs(<16 x float> %a, float %b) { ; CHECK-LABEL: test_faddvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %1 = fadd <16 x float> %a,%splat
  ; CHECK: add_f v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x float> %1
}

define <16 x float> @test_faddvsm(<16 x float> %a, float %b, <16 x i1> %mask) { ; CHECK-LABEL: test_faddvsm:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %1 = fadd <16 x float> %a,%splat
  %2 = select <16 x i1> %mask, <16 x float> %1, <16 x float> %a
  ; CHECK: add_f_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x float> %2
}

define <16 x float> @test_faddvv(<16 x float> %a, <16 x float> %b) { ; CHECK-LABEL: test_faddvv:
  %1 = fadd <16 x float> %a,%b
  ; CHECK: add_f v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x float> %1
}

define <16 x float> @test_faddvvm(<16 x float> %a, <16 x float> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_faddvvm:
  %1 = fadd <16 x float> %a,%b
  %2 = select <16 x i1> %mask, <16 x float> %1, <16 x float> %a
  ; CHECK: add_f_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x float> %2
}

define float @test_fsubss(float %a, float %b) { ; CHECK-LABEL: test_fsubss:
  %1 = fsub float %a,%b
  ; CHECK: sub_f s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret float %1
}

define <16 x float> @test_fsubvs(<16 x float> %a, float %b) { ; CHECK-LABEL: test_fsubvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %1 = fsub <16 x float> %a,%splat
  ; CHECK: sub_f v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x float> %1
}

define <16 x float> @test_fsubvsm(<16 x float> %a, float %b, <16 x i1> %mask) { ; CHECK-LABEL: test_fsubvsm:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %1 = fsub <16 x float> %a,%splat
  %2 = select <16 x i1> %mask, <16 x float> %1, <16 x float> %a
  ; CHECK: sub_f_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x float> %2
}

define <16 x float> @test_fsubvv(<16 x float> %a, <16 x float> %b) { ; CHECK-LABEL: test_fsubvv:
  %1 = fsub <16 x float> %a,%b
  ; CHECK: sub_f v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x float> %1
}

define <16 x float> @test_fsubvvm(<16 x float> %a, <16 x float> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_fsubvvm:
  %1 = fsub <16 x float> %a,%b
  %2 = select <16 x i1> %mask, <16 x float> %1, <16 x float> %a
  ; CHECK: sub_f_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x float> %2
}

define float @test_fmulss(float %a, float %b) { ; CHECK-LABEL: test_fmulss:
  %1 = fmul float %a,%b
  ; CHECK: mul_f s{{[0-9]+}}, s{{[0-9]+}}, s{{[0-9]+}}
  ret float %1
}

define <16 x float> @test_fmulvs(<16 x float> %a, float %b) { ; CHECK-LABEL: test_fmulvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %1 = fmul <16 x float> %a,%splat
  ; CHECK: mul_f v{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x float> %1
}

define <16 x float> @test_fmulvsm(<16 x float> %a, float %b, <16 x i1> %mask) { ; CHECK-LABEL: test_fmulvsm:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %1 = fmul <16 x float> %a,%splat
  %2 = select <16 x i1> %mask, <16 x float> %1, <16 x float> %a
  ; CHECK: mul_f_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x float> %2
}

define <16 x float> @test_fmulvv(<16 x float> %a, <16 x float> %b) { ; CHECK-LABEL: test_fmulvv:
  %1 = fmul <16 x float> %a,%b
  ; CHECK: mul_f v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x float> %1
}

define <16 x float> @test_fmulvvm(<16 x float> %a, <16 x float> %b, <16 x i1> %mask) { ; CHECK-LABEL: test_fmulvvm:
  %1 = fmul <16 x float> %a,%b
  %2 = select <16 x i1> %mask, <16 x float> %1, <16 x float> %a
  ; CHECK: mul_f_mask v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x float> %2
}

define <16 x i1> @icmp_sgtvv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_sgtvv:
  %c = icmp sgt <16 x i32> %a, %b
  ; CHECK: cmpgt_i s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sgtvs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_sgtvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp sgt <16 x i32> %a, %splat
  ; CHECK: cmpgt_i s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sgtvI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_sgtvI:
  %c = icmp sgt <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmpgt_i s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sgevv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_sgevv:
  %c = icmp sge <16 x i32> %a, %b
  ; CHECK: cmpge_i s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sgevs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_sgevs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp sge <16 x i32> %a, %splat
  ; CHECK: cmpge_i s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sgevI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_sgevI:
  %c = icmp sge <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmpge_i s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sltvv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_sltvv:
  %c = icmp slt <16 x i32> %a, %b
  ; CHECK: cmplt_i s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sltvs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_sltvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp slt <16 x i32> %a, %splat
  ; CHECK: cmplt_i s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_sltvI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_sltvI:
  %c = icmp slt <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmplt_i s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_slevv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_slevv:
  %c = icmp sle <16 x i32> %a, %b
  ; CHECK: cmple_i s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_slevs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_slevs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp sle <16 x i32> %a, %splat
  ; CHECK: cmple_i s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_slevI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_slevI:
  %c = icmp sle <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmple_i s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_eqvv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_eqvv:
  %c = icmp eq <16 x i32> %a, %b
  ; CHECK: cmpeq_i s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_eqvs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_eqvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp eq <16 x i32> %a, %splat
  ; CHECK: cmpeq_i s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_eqvI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_eqvI:
  %c = icmp eq <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmpeq_i s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_nevv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_nevv:
  %c = icmp ne <16 x i32> %a, %b
  ; CHECK: cmpne_i s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_nevs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_nevs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp ne <16 x i32> %a, %splat
  ; CHECK: cmpne_i s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_nevI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_nevI:
  %c = icmp ne <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmpne_i s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ugtvv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ugtvv:
  %c = icmp ugt <16 x i32> %a, %b
  ; CHECK: cmpgt_u s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ugtvs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_ugtvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp ugt <16 x i32> %a, %splat
  ; CHECK: cmpgt_u s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ugtvI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ugtvI:
  %c = icmp ugt <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmpgt_u s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ugevv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ugevv:
  %c = icmp uge <16 x i32> %a, %b
  ; CHECK: cmpge_u s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ugevs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_ugevs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp uge <16 x i32> %a, %splat
  ; CHECK: cmpge_u s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ugevI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ugevI:
  %c = icmp uge <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmpge_u s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ultvv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ultvv:
  %c = icmp ult <16 x i32> %a, %b
  ; CHECK: cmplt_u s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ultvs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_ultvs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp ult <16 x i32> %a, %splat
  ; CHECK: cmplt_u s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ultvI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ultvI:
  %c = icmp ult <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmplt_u s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ulevv(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ulevv:
  %c = icmp ule <16 x i32> %a, %b
  ; CHECK: cmple_u s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ulevs(<16 x i32> %a, i32 %b) {	; CHECK-LABEL: icmp_ulevs:
  %single = insertelement <16 x i32> undef, i32 %b, i32 0
  %splat = shufflevector <16 x i32> %single, <16 x i32> undef, <16 x i32> zeroinitializer
  %c = icmp ule <16 x i32> %a, %splat
  ; CHECK: cmple_u s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @icmp_ulevI(<16 x i32> %a, <16 x i32> %b) {	; CHECK-LABEL: icmp_ulevI:
  %c = icmp ule <16 x i32> %a, <i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27, i32 27>
  ; CHECK: cmple_u s{{[0-9]+}}, v{{[0-9]+}}, 27
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ogtvv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_ogtvv:
  %c = fcmp ogt <16 x float> %a, %b
  ; CHECK: cmpgt_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ogtvs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_ogtvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp ogt <16 x float> %a, %splat
  ; CHECK: cmpgt_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ogevv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_ogevv:
  %c = fcmp oge <16 x float> %a, %b
  ; CHECK: cmpge_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ogevs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_ogevs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp oge <16 x float> %a, %splat
  ; CHECK: cmpge_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_oltvv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_oltvv:
  %c = fcmp olt <16 x float> %a, %b
  ; CHECK: cmplt_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_oltvs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_oltvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp olt <16 x float> %a, %splat
  ; CHECK: cmplt_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_olevv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_olevv:
  %c = fcmp ole <16 x float> %a, %b
  ; CHECK: cmple_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_olevs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_olevs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp ole <16 x float> %a, %splat
  ; CHECK: cmple_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ugtvv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_ugtvv:
  %c = fcmp ugt <16 x float> %a, %b
  ; CHECK: cmple_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ugtvs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_ugtvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp ugt <16 x float> %a, %splat
  ; CHECK: cmple_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ugevv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_ugevv:
  %c = fcmp uge <16 x float> %a, %b
  ; CHECK: cmplt_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ugevs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_ugevs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp uge <16 x float> %a, %splat
  ; CHECK: cmplt_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ultvv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_ultvv:
  %c = fcmp ult <16 x float> %a, %b
  ; CHECK: cmpge_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ultvs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_ultvs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp ult <16 x float> %a, %splat
  ; CHECK: cmpge_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ulevv(<16 x float> %a, <16 x float> %b) {	; CHECK-LABEL: fcmp_ulevv:
  %c = fcmp ule <16 x float> %a, %b
  ; CHECK: cmpgt_f s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}

define <16 x i1> @fcmp_ulevs(<16 x float> %a, float %b) {	; CHECK-LABEL: fcmp_ulevs:
  %single = insertelement <16 x float> undef, float %b, i32 0
  %splat = shufflevector <16 x float> %single, <16 x float> undef, <16 x i32> zeroinitializer
  %c = fcmp ule <16 x float> %a, %splat
  ; CHECK: cmpgt_f s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
  ; CHECK: xor s{{[0-9]+}}, s{{[0-9]+}}
  ret <16 x i1> %c
}
