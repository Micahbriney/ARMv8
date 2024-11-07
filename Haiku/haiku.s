    .global main
main:
    // Run lineOne routine

    // pre-increment the stack point to create space for two 8-byte registers
    // link register (x30), and frame pointer (x29), and store them.
	stp x29, x30, [sp, -16]!

    // Load the argument and perform the call. Like 'printf("...")' in C.
	ldr x0, =lineOne
	bl printf

    // initialize the return value in the return register
	mov x0, 0

    // restore the registers and post-decrement 
    // the stack pointer for consistency
	ldp x29, x30, [sp], 16

    // Run lineTwo routine
    
    // pre-increment stack pointer to create space for two 8-byte registers
    // link register (x30), and frame pointer (x29), and store them.
	stp x29, x30, [sp, -16]!

    // Load the argument and perform the call. Like 'printf("..")' in c.
	ldr x0, =lineTwo
    //branch and store return address in link register x30
	bl printf

    // initialize the return value in the return register
	mov x0, 0

    // restore the registers and post-decrement 
    // the stack pointer for consistency
	ldp x29, x30, [sp], 16

    // Run lineThree routine
    
    // pre-increment stack pointer to create space for two 8-byte registers
    // link register (x30), and frame pointer (x29), and store them.
	stp x29, x30, [sp, -16]!

    // Load the argument and perform the call. Like 'printf("..")' in c.
	ldr x0, =lineThree
    //branch and store return address in link register x30
	bl printf

    // initialize the return value in the return register
	mov x0, 0

    // restore the registers and post-decrement 
    // the stack pointer for consistency
	ldp x29, x30, [sp], 16 

    // return from the call
	ret

    // directive .asciz will zero byte terminate the string
lineOne:
	.asciz "Starting twenty five\n"
lineTwo:
	.asciz "all quarters will go goodbye\n"
lineThree:
	.asciz "semesters will rise.\n"
