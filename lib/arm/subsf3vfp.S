//===-- subsf3vfp.S - Implement subsf3vfp ---------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

//
// extern float __subsf3vfp(float a, float b);
//
// Returns the difference between two single precision floating point numbers 
// using the Darwin calling convention where single arguments are passsed
// like 32-bit ints.
//
	.syntax unified
	.align 2
DEFINE_COMPILERRT_FUNCTION(__subsf3vfp)
	vmov	s14, r0		// move first param from r0 into float register
	vmov	s15, r1		// move second param from r1 into float register
	vsub.f32 s14, s14, s15
	vmov	r0, s14		// move result back to r0
	bx	lr
END_COMPILERRT_FUNCTION(__subsf3vfp)
