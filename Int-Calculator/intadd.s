    // intadd function in this file

    .arch armv8-a
    .global intadd

intadd:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp
    stp     x2, x3, [sp, -16]!   /* Put x2, and x3 on stack. Dont care about values*/
                                 /* Using x2 as sum and x3 as carry*/
if:
    /* First check if params x0 and x1 are zero*/
    /* Is Param 1 zero?*/
    cmp     x0, 0               /* Compare param1 to zero*/
    beq     returnparam2        /* branch to returnparm2 and return param2*/

    /* Is Param 2 zero?*/
    cmp     x1, 0               /* Compare param2 to zero*/
    beq     returnparam1        /* branch to returnparm1 and return param1*/
    /*If neither are zero then start adding*/

    lsr     x9, x0, 63
    cmp     x9, 1
    beq     twoscomp1

    lsr     x9, x1, 63
    cmp     x9, 1
    beq     twoscomp2

twoscomp1:
    /* Flip all the bits and Add 1*/
    

twoscomp2:

do:
    /* first XOR x0 ^ x1 and store result in x2 (sum)*/
    eor     x2, x0, x1          /* x2 stores sum result*/
    /* Second AND x0 & x1 and store result in x3 (carry)*/
    and     x3, x0, x1          /* X3 stores carry result*/
    /* Third Shift x3 << 1 carry */
    lsl     x3, x3, 1

while:
    /* Fourth compare carry result with zero*/
    cmp     x3, 0
    beq     returnsum

    /* first XOR x2 ^ x3 and store result in x2 (sum)*/
    eor     x2, x0, x1          /* x2 stores sum result*/
    /* Second AND x2 & x3 and store result in x3 (carry)*/
    and     x3, x0, x1          /* X3 stores carry result*/
    /* Third Shift x3 << 1 carry */
    lsl     x3, x3, 1

    b       while


returnparam2:
    mov     x0, x1
    /* Can fall through to returnparam1 b return command*/
returnparam1:
    /* Note: x0 already holds return value*/
    b       return

returnsum:
    mov     x0, x2              /* Move Sum result to return register x0*/

return:
/* Restore FP and LR, Don't care about x2, and x3*/
    //ldp     x29, x30, [sp], 32



    ldp     x2, x3, [sp], 16   /* Pop x2, and x3 off stack.*/
    ldp     x29, x30, [sp], 16 /* Pop LR and FP off stack*/
    
    ret