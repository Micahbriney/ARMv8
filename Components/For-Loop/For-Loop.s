/*
// Prototypes
int f2 (int);

// The function you should convert to ARM
int f1 (int a) {
  int result=0, i;
  
  for (i=0; i<10; i++) {
    result += f2(i+a);
  }
  return result;
}

 */

f1: 
    /* Init fp and lr*/
    stp     x29, x30, [sp, -48]! /* Make room for 5 - 8 Byte registers*/
    mov     x29, sp              /* Move a copy of sp to fp*/
    
    /* Copy param a value to stack*/
    str     x0, [x29, 40]        /* Variable: parameter a*/
    /* Create callee saved registers to stack*/
    str     x19, [x29, 32]       /* Variable: result*/
    str     x20, [x29, 24]       /* Variable: i*/
    /* Initialize "result" to 0 "result=0" */
    mov     x19, #0
    /* Initialize 'i' to 0 "for(i=0;..." */
    mov     x20, #0
    @ /* For loop condition. Loop if "i < 10" */
    @ cmp     x21, #10        /* This is unnecessary. 'i' will always init to 0*/
    @ bge     noloop          /* This is unnecessary. 'i' will always init to 0*/

loop:
    ldr     x0, [x29, 40]       /* Fixed code*/
    //The following line was incorrect on the quiz
    //add     x0, x29, 40         /* copy "a" value to f2 parameter */
    add     x0, x0, x20         /* Fixed code*/
    //The following line was incorrect on the quiz. x19 is result NOT i
    //add     x0, x0, x19         /* Add "a+i" */
    /* Call f2 function*/
    bl      f2
    /* */
    add     x19, x19, x0         /* Add f2 returned value to result*/
    /* Increment i "... i++)" */
    add     x20, x20, #1
    /* For loop condition. Loop if "i < 10" */
    cmp     x20, #10
    blt     loop
    b       exit

@ noloop:     /* This is unnecessary. There is no case to reach here*/
@     mov     x0, #0               /* Set return register to 0*/

exit:
    /* Restore register values from stack to callee registers*/
    ldr     x19, [x29, 32]
    ldr     x20, [x29, 24]
    ldp     x29, x30, [sp], 48   /* Restore fp, lr from stack*/
    ret