	.arch armv8-a
	.text

/* print function is complete, no modifications needed */
    .global	print
print:
      stp    x29, x30, [sp, -16]! //Store FP, LR.
      add    x29, sp, 0
      mov    x3, x0
      mov    x2, x1
      ldr    w0, startstring
      mov    x1, x3
      bl     printf
      ldp    x29, x30, [sp], 16
      ret

startstring:
	.word	string0

   .global	towers
towers:
   stp   x29, x30, [sp, -64]!  /* Store fp, lr. Enough for 8 - 8 byte registers*/
   add   x29, sp, 0            /* Copy sp location to fp location*/
   /* Save calllee-saved registers to stack */
   str   x19, [x29, 56]    /* Variable: numDisks*/
   str   x20, [x29, 48]    /* Variable: start*/
   str   x21, [x29, 40]    /* Variable: goal*/
   str   x22, [x29, 32]    /* Variable: peg = temp*/ 
   str   x23, [x29, 24]    /* Variable: steps*/
   /* Save a copy of all 3 incoming parameters to callee-saved registers */
   mov   x19, x0     /* Copy value in param 1 register to callee 1 register*/
   mov   x20, x1     /* Copy value in param 2 register to callee 2 register*/
   mov   x21, x2     /* Copy value in param 3 register to callee 3 register*/
if:
   cmp   x19, 2      /* Compare numDisks with 2 or (numDisks - 2)*/
   bge   else        /* Check if less than, else branch to else */
   mov   x0, x20     /* set print function's start to incoming start */
   mov   x1, x21     /* set print function's end to goal */
   bl    print       /* call print function */
   mov   x0, 1       /* Set return register to 1 */
   b     endif       /* branch to endif */

else:
   mov   x22, 6        /* Use a callee-saved varable for temp and set it to 6 */
   sub   x22, x22, x20 /* Subract start from temp and store to itself */
   sub   x22, x22, x21 /* Subtract goal from temp and store to itself (temp = 6 - start - goal)*/
   sub   x0, x19, 1    /* subtract 1 from original numDisks and store it to numDisks parameter */
   mov   x2, x22       /* Set end parameter as temp */
   bl    towers        /* Call towers function */
   mov   x23, x0       /* Save result to callee-saved register for total steps */
   mov   x0, 1         /* Set numDiscs parameter to 1 */
   mov   x1, x20       /* Set start parameter to original start */
   mov   x2, x21       /* Set goal parameter to original goal */
   bl    towers        /* Call towers function */
   add   x23, x23, x0  /* Add result to total steps so far */
   sub   x0, x19, 1    /* Set numDisks parameter to original numDisks - 1 */
   mov   x1, x22       /* set start parameter to temp */
   mov   x2, x21       /* set goal parameter to original goal */
   bl    towers        /* Call towers function */
   add   x0, x23, x0   /* Add result to total steps so far and save it to return register */


endif:
   /* ----- Restore Registers ----- */  
   ldr   x19, [x29, 56]     /* Variable: numDisks*/
   ldr   x20, [x29, 48]     /* Variable: start*/
   ldr   x21, [x29, 40]     /* Variable: goal*/
   ldr   x22, [x29, 32]     /* Variable: peg = temp*/ 
   ldr   x23, [x29, 24]     /* Variable: steps*/

   ldp   x29, x30, [sp], 64  /* Load the previous frame pointer back into the register*/
   ret   /* Return from towers function */

/* Function main is complete, no modifications needed*/
    .global	main
main:
      stp    x29, x30, [sp, -32]!   /* push down SP to store FP and LR*/
      add    x29, sp, 0             /* set fp to bottom of new frame*/
      ldr    w0, printdata          /* load address of "printdata" into w0*/
      bl     printf                 /* branch to printf*/
      ldr    w0, printdata + 4      /* load "printdata" + 4 byte offset to wo*/
      add    x1, x29, 28            /* store fp + 28 offset address to x1*/
      bl     scanf                  /* branch to scanf. Res stored at x1 adrs*/
      ldr    w0, [x29, 28]          /* numDisks. Ld adrs of scanf res to w0 */
      mov    x1, #1                 /* Start. Copy value 1 to x1 */
      mov    x2, #3                 /* Goal. Copy value 3 to x2 */
      bl     towers                 /* brach to towers address*/
      mov    w4, w0
      ldr    w0, printdata + 8
      ldr    w1, [x29, 28]
      mov    w2, #1
      mov    w3, #3
      bl     printf
      mov    x0, #0
      ldp    x29, x30, [sp], 16
      ret
end:

printdata:
	.word	string1
	.word	string2
	.word	string3

string0:
	.asciz	"Move from peg %d to peg %d\n"
string1:
	.asciz	"Enter number of discs to be moved: "
string2: 
	.asciz	"%d"     /* Scanf doesn't need to clear buffer with a space before "%d". 
                        For chars it needs to clear buffer with a space ie " %d"*/
	.space	1        /* For alignment*/
string3:
	.ascii	"\n%d discs moved from peg %d to peg %d in %d steps."
	.ascii	"\012\000"
