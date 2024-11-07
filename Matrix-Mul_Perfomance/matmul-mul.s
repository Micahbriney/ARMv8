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
//  for (unsigned int i = 0; i < hA; ++i)
//    for (unsigned int j = 0; j < wB; ++j) {
//      int sum = 0;
//      for (unsigned int k = 0; k < wA; ++k) {
//        sum += A[i * wA + k] * B[k * wB + j];
//      }
//      C[i * wB + j] = sum;
//    }
//}
//
//  NOTE: This version should use the MUL/MLA and ADD instructions
//
////////////////////////////////////////////////////////////////////////////////

/* Variables: &C, &A, &B, hA, wA, wB, i, j, sum, k*/

	.arch armv8-a
	.global matmul
matmul:
	/* Make space on the stack for 10 paramters;
	   FP and LR:    	2 - 8 Bytes
	   &C, &A, &B:   	3 - 4 Bytes. Need addresses on the stack
	   hA, wA, wB		Keep as paramter registers. Dont need on stack
	   sum				Caller registers. Dont need after function and there is no internal call

	   i, j, k: 		Caller registers. Dont need after function and there is no internal call
	   2 - 8 Byte + 3 - 4 byte registers = 16 + 12 = 28*/
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
	w8 wA * 4
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


	/* For testing loop/ print i value*/
/* 	ldr    x0, =string0
	mov    x1, w9
	bl     printf */




	/* Start outter for loop here*/
outerloop:
	/* Compare i < hA. HAZARD?*/
	cmp		w9, w6
	/* branch if i >= hA to exit*/
	bge		exit
	/* Initilize j = 0*/
	mov		w10, wzr




	/* For testing loop/ print j value*/
	/* ldr    x0, =string1
	/* mov    x1, w10
	/* bl     printf




	/* Start middle for loop here. HAZARD?*/
middleloop:
	/* Compare j < wB*/
	cmp		w10, w7
	/* branch if j >= wB to end outer loop*/
	bge		endouterloop
	/* Initilize sum = 0. Caller/temp saved register*/
	mov		w12, wzr
	/* Initilize k = 0*/
	mov		w11, wzr



	/* For testing loop/ print j value*/
	/* ldr    x0, =string2
	mov    x1, w11
	bl     printf
 */




	/* Start inner for loop here. HAZARD?*/
innerloop:
	/* Compare k < wA*/
	cmp		w11, w8
	/* branch if k >= wA to end middle loop*/
	bge		endmiddleloop
	/* complex equation*/
	/* sum += A[i * wA + k] * B[k * wB + j]; */
	/* First [i * wA + k]*/
	/* caller/temp register_5 = i * wA*/
	mul		w13, w9, w4
	/* caller/temp register_5 += k. HAZARD. */
	add		w13, w13, w11
	/* Second [k * wB + j]*/
	/* caller/temp register_6 = k * wB*/
	mul		w14, w11, w5
	/* caller/temp register_6 += j. HAZARD*/
	add		w14, w14, w10

	/* Index offset is already in i and K... Create index address offset. (i * wA + k) + 4 bytes*/
	//add		w13, w13, =.word	/* Add a 4 Byte offset to index (i * wA + k)*/
	/* Get A[i * wA + k] = A[w13] = A[temp_register_5].*/
	ldr		w13, [x1, x13]		/* Load the value at address of A(x1) at index w13*/
	/* Now w13 = A[i * wA + k]*/


	/* Index offset is already in k and j... Create index address offset. (k * wB + j) + 4 bytes*/
	//add		w14, w14, =.word	/* Add a 4 Byte offset to index (k * wB + j)*/
	/* Get B[k * wB + j] = B[w14] = B[temp_register_6].*/
	ldr		w14, [x2, x14]		/* Load the value at address of B(x2) at index w14*/
	/* Now w14 = B[k * wB + j]*/

	/* caller/temp register_5 = caller/temp register_5 * caller/temp register_6. Done with w14*/
	mul		w13, w14, w13		/* w13 = A[i * wA + k] * B[k * wB + j]*/
	/* sum += caller/temp register_5. Done with w13. HAZARD*/
	add		w12, w12, w13		/* Sum = Sum + w13*/
	/* increment k by 4 bytes. pre increment?*/
	add		w11, w11, #4
	/* Unconditional branch to inner loop*/
	b		innerloop
/*------- Leaving inner loop --------*/
endmiddleloop:

	/* Complex math equation number 2*/
	/* C[i * wB + j] = sum */

	/* caller/temp register_5 = i * wB*/
	mul		w13, w9, w5
	/* caller/temp register_5 += j. HAZARD*/
	add		w13, w13, w10

	/* Index Address offset*/
	//add		w13, w13, .word		/* Add index w13 by offset of 1 int*/

	/* Store C[i * wB + j] = C[caller/temp register_5] with sum value*/
	str		w12, [x0, x13] 		/* C[i * wB + j] = sum*/
	/* increment j by 4 bytes. ?Pre increment?*/
	add		w10, w10, #4
	/* Unconditional branch to middle loop*/
	b		middleloop
/*-------- Leaving middle loop --------*/
endouterloop:

	/* Increment i by 4 bytes. ?Pre increment?*/
	add		w9, w9, #4
	/* Unconditional branch to outer loop*/
	b		outerloop

exit:

	/* No callee registers to restore*/
	/*ldr		x0,  [x29, 40]		/* Store value of x0 on stack. Value of x0 is address of C*/
	/*ldr		x1,  [x29, 32]		/* Store value of x1 on stack. Value of x1 is address of A*/
	/*ldr		x2,  [x29, 24]	

	/* Restore FP and LR values*/
	ldp		x29, x30, [sp], 48	/* Move stack pointer and store FP and LR on stack*/
	/* Return*/
	ret



/* printdata:
	.word	string0
	.word	string1
	.word	string2
*/
/* string0:
	.asciz	"Loop i: %d \n"
string1:
	.asciz	"Loop j: %d \n"
string2:
	.asciz	"Loop k: %d \n"  */


/* Questions for teacher?*/


/* 2. Why did my printf function break out of the loop when running gdb*/

