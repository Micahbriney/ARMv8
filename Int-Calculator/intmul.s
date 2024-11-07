    // intmul function in this file

    .arch armv8-a
    .global intmul

intmul:

    stp     x29, x30, [sp, -16]!
    mov     x29, sp              /* ?should this be below the following instruction?*/
    stp     x2, x3, [sp, -32]!   /* Put x2, and x3 on stack. Dont care about values*/
    str     x19, [x29, -8]       /* Put x19 on stack. Just below fp.*/
                                 /* Using x2 as sum and x3 as carry*/

if:
    /* First check if params x0 (Multiplicand) and x1 (Multiplier) are zero*/
    /* Is Param 1 zero?*/
    cmp     x0, 0               /* Compare param1 to zero. Multiplicand*/
    beq     returnzero          /* branch to returnparm2 and return param2*/

    /* Is Param 2 zero?*/
    cmp     x1, 0               /* Compare param2 to zero. Multiplier*/
    beq     returnzero          /* branch to returnparm1 and return param1*/
    /*If neither are zero then start adding*/
else:
    /* Start multiplication process of shift and add*/
    mov     x19, #0              /* Initilize product variable*/
    cmp     x1, 0                /* Check if multiplier == 0 */
    beq     returnproduct
    /* Compare lsb*/
    //cmp     

returnzero:
    mov     x0, 0               /* Store 0 in return param x0*/
    b      return

returnproduct:
    mov     x0, x19             /* Move value of callee register x19 (product) to return register*/

return:
    /* Restore FP and LR, Don't care about x2, and x3*/
    ldp     x29, x30, [sp], 32
    ret