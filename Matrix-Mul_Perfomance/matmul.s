////////////////////////////////////////////////////////////////////////////////
// You're implementing the following function in ARM Assembly
//! C = A * B
//! @param C          result matrix
//! @param A          matrix A 
//! @param B          matrix B
//! @param hA         height of matrix A
//! @param wA         width of matrix A, height of matrix B
//! @param wB         width of matrix B
//
//  Note that while A, B, and C represent two-dimensional matrices,
//  they have all been allocated linearly. This means that the elements
//  in each row are sequential in memory, and that the first element
//  of the second row immedialely follows the last element in the first
//  row, etc. 
//
//void matmul(int* C, const int* A, const int* B, unsigned int hA, 
//    unsigned int wA, unsigned int wB)
//{
//  for (unsigned int i = 0; i < hA; ++i){
//    for (unsigned int j = 0; j < wB; ++j) {
//      int sum = 0;
//      for (unsigned int k = 0; k < wA; ++k) {
//        sum += A[i * wA + k] * B[k * wB + j];
//      }
//      C[i * wB + j] = sum;
//    }
//}
//
//  NOTE: This version should call the intadd and intmul functions
//
////////////////////////////////////////////////////////////////////////////////

	.arch armv8-a
	.global matmul
matmul:
	/* Make space on the stack for 5 - 8 bytes registers;
	   FP and LR:    	2 - 8 Bytes
	   &C, &A, &B:   	3 - 4 Bytes. WRONG!!. NEED FULL ADDRESS so, 3 - 8 Bytes. Need addresses on the stack
	   hA, wA, wB		Keep as paramter registers. Dont need on stack
	   sum				Caller registers. Dont need after function and there is no internal call

	   i, j, k: 		Caller registers. Dont need after function and there is no internal call
	   2 - 8 Byte + 3 - 8 byte registers = 16 + 24 = 40*/
	stp		x29, x30, [sp, -48]!	/* Move stack pointer and store FP and LR on stack*/
	mov		x29, sp					/* Load SP location in FP register*/


	/* Store addresses on the stack. Might not need to do*/
	str		x0,  [x29, 40]			/* Store value of x0 on stack. Value of x0 is address of C*/
	str		x1,  [x29, 32]			/* Store value of x1 on stack. Value of x1 is address of A*/
	str		x2,  [x29, 24]			/* Store value of x2 on stack. Value of x2 is address of B*/

/* We dont care about storing these paramater values on the stack. They will not be mutated*/
	/*str		w3,  [x29, 52]		/* Store value of w3 on stack. Value is hA*/
	/*str		w4,  [x29, 48]		/* Store value of w4 on stack. Value is wA*/
	/*str		w5,  [x29, 44]		/* Store value of w5 on stack. Value is wB*/

/*We dont care about storing these paramater values on the stack. They will not be mutated*/
	/*str		w19, [x29, 32]		/* Store value of callee on stack. This will be used for i*/
	/*str		w20, [x29, 28]		/* Store value of callee on stack. This will be used for j*/
	/*str		w21, [x29, 24]		/* Store value of callee on stack. This will be used for k*/


/*-------------------- Register Usage ------------------------*/
/*
	x0 &C
	x1 &A
	x2 &B
	w3 hA
	w4 wA
	w5 wB
	w6 hA * 4
	w7 wB * 4
	w8 wA * 4		// Potential problem using register 8 due to calls to intmul and intadd
 	w9	i
	w10	j
	w11	k
	w12	sum
	w13	temp register 5
	w14	temp register 6
	w15 index offset
*/


	/*------- Watch for pipeline hazards-------*/
	/* Initilize i = 0*/
	mov		w9, wzr
	/* Initilized byte width hA*/
	lsl		w6, w3, #2		/* Logical shift left 2 = multipling by 4 */
	/* Initilized byte width wB*/
	lsl		w7, w5, #2		/* Logical shift left 2 = multipling by 4 */
	/* Initilized byte width wA*/
	lsl		w8, w4, #2		/* Logical shift left 2 = multipling by 4 */

	/* Start outter for loop here*/
outerloop:
	/* Compare i < (hA * 4)*/
	cmp		w9, w6
	/* branch if i >= (hA * 4) to exit*/
	bge		exit
	/* Initilize j = 0*/
	mov		w10, wzr

	/* Start middle for loop here. HAZARD?*/
middleloop:
	/* Compare j < (wB * 4)*/
	cmp		w10, w7
	/* branch if j >= (wB * 4) to end outer loop*/
	bge		endouterloop
	/* Initilize sum = 0. Caller/temp saved register*/
	mov		w12, wzr
	/* Initilize k = 0*/
	mov		w11, wzr

	/* Start inner for loop here. HAZARD?*/
innerloop:
	/* Compare k < (wA * 4)*/
	cmp		w11, w8
	/* branch if k >= (wA * 4) to end middle loop*/
	bge		endmiddleloop
	/* complex equation*/
	/* sum += A[i * wA + k] * B[k * wB + j]; */
	/* First [i * wA + k]*/
	/* caller/temp register_5 = i * wA*/
	
	/*Recreate instruction: mul		w13, w9, w4 */
	mov		w0, w9		/* Set w0 = w9 = i*/
	mov		w1, w4		/* Set w1 = w4 = wA*/
	/* Branch to intmul to multiple i * wA*/
	bl		intmul		/* w0 = i * wA*/

	/* caller/temp register_5 += k. */
	/*Recreate instruction: add		w13, w13, w11*/
	/* w0 already = i * wA so keep as is.*/
	mov		w1, w11		/* Set w1 = k*/
	/* Branch to intadd to add (i * wA) and k*/
	bl		intadd		/* w0 = (i * wA) + k*/
	/* Save result of intadd*/
	mov		w13, w0		/* w13 = w0 = (i * wA) + k*/

	/* Second [k * wB + j]*/
	/* caller/temp register_6 = k * wB*/
	/* Recreate instruction: mul		w14, w11, w5*/
	mov		w0, w11		/* Set w0 = w11 = k*/
	mov		w1, w5		/* Set w1 = w5  = wB*/
	/* Branch to intmul to multiply k * wB*/
	bl		intmul		/* w0 = k * wB*/

	/* caller/temp register_6 += j.*/
	/*Recreate instruction: add		w14, w14, w10*/
	/* w0 already = k * wB*/
	mov		w1, w10		/* w1 = w10 = j*/
	/* Branch to intadd to add (k * wB) + j*/
	bl		intadd		/* w0 = (k * wB) + j*/
	/* Save result of intadd. Not necessary. Can be optimized to ignore this step and just use B[w0] below*/
	mov		w14, w0		/* w14 = w0 = (k * wB) + j*/

	/* Index offset is already in i and k*/
	/* Load Address A that was stored on the stack back into x1*/
	ldr		x1, [x29, 32]
	/* Get A[i * wA + k] = A[w13] = A[temp_register_5].*/
	ldr		w13, [x1, x13]		/* Load the value at address of A(x1) at index w13*/
	/* Now w13 = A[i * wA + k]*/


	/* Index offset is already in k and j*/
	/* Load Address B that was stored on the stack back into x2*/
	ldr		x2, [x29, 24]
	/* Get B[k * wB + j] = B[w14] = B[temp_register_6].*/
	ldr		w14, [x2, x14]		/* Load the value at address of B(x2) at index w14*/
	/* Now w14 = B[k * wB + j]*/


	/* caller/temp register_5 = caller/temp register_5 * caller/temp register_6. Done with w14*/
	/* Recreate instruction: mul		w13, w14, w13*/
	mov		w0, w13		/* w0 = w13 = A[i * wA + k]*/
	mov		w1, w14		/* w1 = w14 = B[k * wB + j]*/
	/* Branch to intmul to multiply A[i * wA + k] and B[k * wB + j]*/
	bl		intmul		/* w0 = A[i * wA + k] * B[k * wB + j]*/
	
	
	/* sum += caller/temp register_5. Done with w13.*/
	/* Recreate instruction: add		w12, w12, w13*/
	/* w0 is already = A[i * wA + k] * B[k * wB + j]*/
	mov		w1, w12		/* Set w1 = w12 = Sum*/
	/* Branch to intadd to Add Sum + (A[i * wA + k] and B[k * wB + j]) */
	bl		intadd		/* w0 = Sum + w13*/
	/* Save result of intadd (Sum + w13) back to w12 = Sum*/
	mov		w12, w0		/* Sum = w0 = Sum + w0 = Sum + w13*/
	
	
	/* increment k by 4 bytes. How does pre increment come into play?*/
	/* Recreate instruction: add		w11, w11, #4*/
	/* Set parameters w0 = k and w1 = 4*/
	mov		w0, w11		/* w0 = k*/
	mov		w1, #4		/* w1 = 4*/
	/* Branch to intadd to increment index k + 4*/
	bl		intadd		/* w0 = k + 4*/
	/* Save result of intadd (k + 4) back to w11 = k*/
	mov		w11, w0		/* Set k = w0*/
	/* Unconditional branch to inner loop*/
	b		innerloop
/*------- Leaving inner loop --------*/
endmiddleloop:

	/* Complex math equation number 2*/
	/* C[i * wB + j] = sum */

	/* caller/temp register_5 = i * wB*/
	/* Recreate instruction: mul		w13, w9, w5*/
	mov		w0, w9		/* Set w0 = i*/
	mov		w1, w5		/* Set w1 = wB*/
	/* Branch to intmul to multiply i * wB*/
	bl		intmul		/* w0 = w9 * w5 = i * wB*/

	/* caller/temp register_5 += j.*/
	/* Recreate instruction: add		w13, w13(w0), w10*/
	/* w0 already set equal to i * wB*/
	mov		w1, w10		/* Set w1 = w10 = j*/
	/* Branch to intadd to add (i * wB) and j*/
	bl		intadd		/* w0 = (i * wB) + j*/
	/* Save result of intadd (i * wB) + j*/
	mov		w13, w0		/* w13 = (i * wB) + j*/


	/* Index Address offset. !!! Use x0 for full 64 bit address!!!*/
	ldr		x0, [x29, 40]	/* Load the address of C stored on the stack into x0*/
	/* Store C[i * wB + j] = C[caller/temp register_5] with sum value*/
	str		w12, [x0, x13] 		/* C[i * wB + j] = sum*/
	
	/* increment j by 4 bytes. How does pre increment come into play?*/
	/* Recreate instruction: add		w10, w10, #4*/
	/* Set parameters w0 = j and w1 = 4*/
	mov		w0, #4		/* Set w0 = 4*/
	mov		w1, w10		/* Set w1 = w10 = j*/
	/* Branch to intadd to add j and 4*/
	bl		intadd		/* w0 = j + 4*/
	/* Save result back into j = w10*/
	mov		w10, w0		/* w10 = w0 = j*/
	/* Unconditional branch to middle loop*/
	b		middleloop
/*-------- Leaving middle loop --------*/
endouterloop:

	/* Increment i by 4 bytes. How does pre increment come into play?*/
	/* Recreate instruction: add		w9, w9, #4*/
	/* Set parameters w0 = i and w1 = 4*/
	mov		w0, #4		/* Set w0 = 4*/
	mov		w1, w9		/* Set w1 = i*/
	/* Branch to intadd to add i and 4*/
	bl		intadd		/* w0 = w0 + w1 = 4 + i*/
	/* Save w0 back into i */
	mov		w9, w0		/* w9 = w0 = i*/
	/* Unconditional branch to outer loop*/
	b		outerloop

exit:

	/* No callee registers to restore*/
	/*ldr		x0,  [x29, 40]		/* Store value of x0 on stack. Value of x0 is address of C*/
	/*ldr		x1,  [x29, 32]		/* Store value of x1 on stack. Value of x1 is address of A*/
	/*ldr		x2,  [x29, 24]		/* Store value of x2 on stack. Value of x2 is address of B*/

	/* Restore FP and LR values*/
	ldp		x29, x30, [sp], 48	/* Move stack pointer and store FP and LR on stack*/
	/* Return*/
	ret




