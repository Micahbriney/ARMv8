
/*

Z = a * X + Y

where Z, X, Y are vectors (arrays)

void zaxpy( int *Z, int * x, int *y, int a, int N){

	int i;
	
	for(i = 0; i < N, i ++){
		z[i] = a * x[i] + y[i];
		
	}
*/

/*

X0 = z
X1 = x
X2 = y
W3 = a
W4 = N


*/


zaxpy:
	Cmp 	w4, wzr        /* If N is zero then exit before setting up i*/
	Ble   	exit         // Branch to exit if N <= 0
	Mov 	x7, 0          // Load varaible i = 0
	
	/* Multiple N * 4 to use as an offset. So N = 5 becomes N = 20 or 5 * 4 bytes*/
	lsl     w4, w4, #2 // N = N * 4. Logical shift left 2 is the same as multipling by 4
	
loop:
	ldr   	x5, [x1, x7]   // load address of x with offset of i into x5. So, x5 = x[i]
	Mul 	x6, x5, x3     // a * x[i] … Note x3 is a
	Ldr   	x5, [x2, x7]   // Load address of y with offset of I into x5 (overwrite x[i] [don’t need for this loop anymore]) 
	Add  	x5, x5, x6     // a * x[i], y[i]  Hazard solved by forwarding
	Str  	x5, [x0, x7]   // z[i] Hazard solved by forwarding from above
	Add 	x7, x7, 4      // increment the index by 4 bytes (size of an int). Hazard solved by forwarding
	Cmp 	x7, x4         //  Hazard solved by forwarding from above
	Ble   	loop
Exit:
	Ret




Loop: 
	ldr     x5, [x1, x7]
	mul     x6, x5, x3
	ldr     x5, [x2, x7]
    add     x5, x5, x6
    str     x5, [x0, x7]
    add     x7, x7, 4 
    
    ldr     x5, [x1, x7]
	mul     x6, x5, x3
	ldr     x5, [x2, x7]
    add     x5, x5, x6
    str     x5, [x0, x7]
    add     x7, x7, 4

    cmp     x7, x4
    ble     loop


/* Fixing Hazards with more avaialbe registers and changing order*/
Loop: 
	ldr     x5, [x1, x7]
	mul     x6, x5, x3
	ldr     x11, [x2, x7]    /* Changed x5 to x11*/
    add     x5, x5, x6
    str     x5, [x0, x7]
    add     x13, x7, 4       /* Changed x7 to x13*/ 
    
    ldr     x5, [x1, x7]    /* Changed x5 to x9*/
	mul     x10, x5, x3     /* Changed x6 to x10*/
	ldr     x12, [x2, x7]    /* Changed x5 to x12*/
    add     x5, x5, x6
    str     x5, [x0, x7]
    add     x7, x7, 4

    cmp     x7, x4
    ble     loop


    /* Changing order of instructions from above to account for load hazard's 4 cycle delay*/

betterloop:
    add     x13, x7, 4      /* Changed x7 to x13*/ 
    ldr     x5, [x1, x7]
    ldr     x9, [x1, x7]    /* Changed x5 to x9*/
	ldr     x11, [x2, x7]   /* Changed x5 to x11*/
	ldr     x12, [x2, x7]   /* Changed x5 to x12*/
	mul     x6, x5, x3
	mul     x10, x5, x3     /* Changed x6 to x10*/
    add     x5, x6, x11     /* */
    add     x9, x10, x12
    str     x5, [x0, x7]
    str     x9, [x0, x13]
    add     x7, x7, #8       /* Changed #4 to #8*/
    cmp     x7, x4
    ble     betterloop
