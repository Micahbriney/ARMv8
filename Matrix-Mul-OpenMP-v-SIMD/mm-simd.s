////////////////////////////////////////////////////////////////////////////////
// You're implementing the following function in ARM Assembly
//! C = A * B
//! @param C          result matrix
//! @param A          matrix A 
//! @param B          matrix B
//! @param hA         height of matrix A
//! @param wA         width of matrix A
//! @param wB         width of matrix B
//
//void matmul(int* C, const int* A, const int* B, unsigned int hA, 
//    unsigned int wA, unsigned int wB)
//{
//  for (unsigned int i = 0; i < hA; ++i)
//    for (unsigned int j = 0; j < wB; ++j) {
//      int sum = 0;
//      for (unsigned int k = 0; k < wA; ++k) {
//        sum += A[i * wA + k] * B[j * wB + k];
//      }
//      C[i * wB + j] = sum;
//    }
//}
////////////////////////////////////////////////////////////////////////////////

.arch armv8-a
.global matmul

/*
 * Assumptions needed to make for this program to work:
 *    1. Matrix M is in row major order
 *    2. Matrix N is in column major order
 *    3. Both M and N have equal heights and widths i.e. Square Matrix
 *    4. Both M and N have a total size that is divisible by 4
 *
 * Argument Registers:
 * x0: Return matrix address
 * x1: Matrix A address
 * x2: Matrix B address
 * x3: hA
 * x4: wA
 * x5: wB
 */

/*-------------------- Register Usage ------------------------*/
/*
	x0 &C
	x1 &A
	x2 &B
	x3 hA
	x4 wA
	x5 wB
	x6 hA * 4
	x7 wB * 4
	x8 wA * 4
	x9	i
	x10	j
	x11	k
	x12	sum
	x13	temp register 5
	x14	temp register 6
    x15 index offset
*/

matmul:
    stp     x29, x30, [sp, -48]!    /* Unsure how much space. Probably lots, 1 v is 128 bits. 16 bytes per*/
    mov     x29, sp                 /* Load sp in fp register*/

    str     x0, [x29, 40]           /* Store address of C on stack*/
    str     x1, [x29, 32]           /* Store address of A on stack*/
    str     x2, [x29, 24]           /* Store address of B on stack*/

    
    /* Check to see if Matrix A or B is zero*/
    cmp     x3, xzr                 /* hA zero?*/
    ble     exit                    /* if hA is zero, exit*/
    cmp     x4, xzr                 /* hB zero?*/
    ble     exit                    /* if hB is zero, exit*/
    cmp     x5, xzr                 /* wB zero?*/
    ble     exit                    /* if wB is zero, exit*/

    /* Setup*/
    /* Because the arrays contain integers the index into the arrays need to be offset by 4
       for each element. For the loop to be able to handel this the height and width of the  
       Matrixs need to also be multiplied by 4*/
    /* Account for 32 bit size integers*/
    /* Initilized byte width hA*/
    lsl     x6, x3, #2                /*Locigcal shift left. Mult by 4*/
    /* Initilized byte width wB*/
    lsl     x7, x5, #2                /*Locigcal shift left. Mult by 4*/
    /* Initilized byte width wA*/
    lsl     x8, x4, #2                /*Locigcal shift left. Mult by 4*/

    mov     x9, xzr         /* Initilized i = 0*/
outerloop:
    cmp     x9, x6          /* Compare i < (hA * 4).*/
//    cmp     x9, x3          /* Compare i < (hA).*/
    bge     exit            /* branch if i >= hA to exit*/
    mov     x10, xzr        /* Initilize j = 0*/

middleloop:
    cmp     x10, x7         /* Compare j < (wB * 4)*/
//    cmp     x10, x5         /* Compare j < (wB)*/
    bge     outerloopend    /* branch if j >= wB to end outer loop*/
    mov     x12, xzr        /* Initilize sum = 0. Caller/temp saved register*/
    mov     x11, xzr        /* Initilize k = 0*/

innerloop:
    cmp		x11, x8         /*Compare k < (wA * 4)*/
    bge		innerloopend   /* branch if k >= wA to end middle loop*/
    
    /* SIMD equation*/
    //------------------sum += A[i * wA + k] * B[j * wB + k];----------------

	/* sum += A[i * wA + k] * B[k * wB + j]; */
	/* First [i * wA + k]*/
    /* Can optimize by placing this in outerloop. Since i is not chaging here*/
    mul		x13, x9, x4     /* caller/temp register_5 = i * wA*/
    add		x13, x13, x11   /* caller/temp register_5 += k. */
	/* Second [k * wB + j]------------------------------ Row Major*/
	/* Second [k + wB * j]------------------------------ changed to Column Major*/
	/* caller/temp register_6 = k * wB------------------ Row Major*/
	/* caller/temp register_6 = j * wB------------------ changed to Column Major*/
	
    mul		x14, x10, x5    /* caller/temp register_6 = j * wB*/
	/* caller/temp register_6 += j.--------------------- Row Major*/
	/* caller/temp register_6 += k.--------------------- changed to Column Major*/
    add		x14, x14, x11   /* caller/temp register_6 += k.*/

	/* Index offset is already in k and j*/
    /* Get A[i * wA + k] = A[w13] = A[temp_register_5]. Done with x13*/
    ld1     {v0.4s}, [x1], 16       /* Load 4 values at address A(x1) starting at index x13*/
    //ldr		x13, [x1, x13]		/* Load the value at address of A(x1) at index w13*/
	/* Now v0.4S = A[i * wA + k], A[(i + 4) * wA + k], A[(i + 8) * wA + k], A[(i + 12) * wA + k]*/

	/* Get B[k * wB + j] = B[w14] = B[temp_register_6]. Done with x14*/
    ld1     {v1.4s}, [x2], 16      /* Load 4 values at address B(x2) at index x14*/
    //ldr		w14, [x2, x14]		/* Load the value at address of B(x2) at index w14*/
	/* Now v1.4S = B[k * wB + j], B[(k + 4) * wB + j], B[(k + 8) * wB + j], B[(k +12) * wB + j]*/

	/* caller/vector register 5 = caller/temp register_5 * caller/temp register_6. Done with w14*/
    mul     v2.4s, v0.4s, v1.4s     /* Multiply elements A[i0:i3] by B[i0:i3]*/
    //mul		w13, w14, w13		/* w13 = A[i * wA + k] * B[k * wB + j]*/

    /* Sum all vectors & store in scalar register*/
    addv    s1, v2.4s               /* Sum all vectors to get 1 scalar value*/
    mov     w13, v1.s[0]            /* Store vector into scaler register*/

    /* sum += caller/temp register_5. Done with w13.*/
    add     x12, x12, x13           /* Accumulate sum register*/
	/* increment k by 16 bytes. (4 ints * sizeof int(4)*/
    add		x11, x11, #16           /* Increment k by 16*/
	/* Unconditional branch to inner loop*/
    b       innerloop               /* Continue innerloop*/

innerloopend:
/*------- Leaving inner loop --------*/
middleloopend:

	/* Complex math equation number 2*/
	/* C[i * wB + j] = sum */
    mul		x13, x9, x5     	/* caller/temp register_5 = i * wB*/
    add		x13, x13, x10       /* caller/temp register_5 += j.*/
	/* Store C[i * wB + j] = C[caller/temp register_5] with sum value*/
    str		x12, [x0, x13] 		/* C[i * wB + j] = sum. Done with x13*/
    add		x10, x10, #4    	/* increment j by 4 bytes. ?Pre increment?*/

/* Question for teacher. What is the best way to go about decrementing the matrix A address
   for using the same row and then incrementing the address for using the next row?*/
/* Need to reset ld1 offset of x1. preincrement by -k
   This is because the same x1 Matrix row is used multiple times.*/
    mov      x13, -1             /* Store --1 in x13. Reuse x13.*/
    mul      x13, x13, x11       /* Make k negative. Reuse x13*/
   /* Is this the best way to decrement the Matrix A address? Can i just add x1, x13?*/
    ld1      {v0.4s}, [x1], x13  /* Decrement x1 address for reuse in innerloop. Done with x13*/

    b		middleloop          /* Unconditional branch to middle loop*/

/*-------- Leaving middle loop --------*/
outerloopend:
    add		x9, x9, #4	        /* Increment i by 4 bytes.*/
    
    /* Is this the best way to Increment the matrix A address? Can i just add x1, x11?*/
    ld1     {v0.4s}, [x1], x11  /* Increment x1 address for reuse in innerloop*/
    
    /* Need to reset the original address of B*/
    ldr     x2, [x29, 24]           /* Load address of B back into x2 register*/
         
//    x8 * x6 /* Total space in matrix * sizeof data type */
//    mov     x13, -1             /* Store --1 in x13. Reuse x13.*/
//   mul     x13, x13, x10       /* Make j negative. Reuse x13*/
//    ld1     {v1.4s}, [x2], x13  /* Decrement x2 address for reuse in innerloop. Done with x13*/
    b		outerloop           /* Unconditional branch to outer loop*/

exit:
	/* Restore FP and LR values*/
    ldp		x29, x30, [sp], 48	/* Move stack pointer and store FP and LR on stack*/
	/* Return*/
    ret
