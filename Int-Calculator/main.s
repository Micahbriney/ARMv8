    // Template main.s file for Lab 3
    // partner names here

    .arch armv8-a

    // --------------------------------
    .global main
main:
    // driver function main lives here, modify this for your other functions
    
    /* For testing*/
//    mov     x0, #12
//    mov     x1, #-3

//    bl      intadd

//    bl      intsub

//    bl      intmul

  
    stp     x29, x30, [sp, -16]! /* Push down sp and make room for fp & lr*/
    stp     x0, x1, [sp, -32]!   /* Push down sp and make room for 2 - 8 byte registers*/
    mov     x29, sp              /* Copy sp location to fp*/
    
    str     x19, [x29, 0]
    str     x20, [x29, 8]
    str     x21, [x29, 16]

prompt:
    /*----------------- Prompt for Num 1-----------------------*/
    ldr     w0, =string0         /* Load string0 into w0 register*/
    bl      printf               /* Print string0*/
    /* Address location for num1*/
    ldr     x0, =scanint
    ldr     x1, [x29]              /* Hopfully copies sp address to x1 */
                     
    /* Scanf takes 2 params, x0 = format, x1 = pointer/address to memory
        format such as " %c" or "%d", scanf puts value at address of x1*/
    
    bl      scanf                /* branch to scanf. Res stored at x1 adrs x29 + 40 */

    /* TODO figure out issue with storing value scanf's stored in address.
     Probably some offset issue*/

    ldr     x19, [x29]          /* Load mutation of "value" at address x29, param register */

    /*----------------- Prompt for Num 2-----------------------*/
    ldr     w0, =string1         /* Load string1 into w0 register*/
    bl      printf               /* Print string1*/
    /* Address location for num2*/
    ldr     w0, =scanint
    ldr     x1, [x29]
    bl      scanf                /* branch to scanf. Res stored at x1 address x29 + 32*/
    /* TODO figure out issue with storing value scanf's stored in address.
     Probably some offset issue*/    
    ldr     x20, [x29, 8]                /* Load mutation of "value" at address x29, param register */
    

    /*----------------- Prompt for Operation-----------------------*/
    ldr     w0, =string2         /* Load string2 into w0 register*/
    bl      printf               /* Print string2*/
    /* Address location for operation*/
    ldr     w0, =scanchar
    ldr     x1, [x29]
    bl      scanf                /* branch to scanf. Res stored at x1 address x29 + 32*/
    /* TODO figure out issue with storing value scanf's stored in address.
     Probably some offset issue*/
    ldr     x21, [x29, 16]                /* Load mutation of "value" at address x29, param register */

    /*----------------- Check operation-----------------------*/
if:
    mov     x2, x29
    
    /* Multiplication*/
    cmp     x2, 42               /* Asci values '+' = 43, '-' = 45, '*' = 42*/
    bne     gotomul

    /* Addition*/
    cmp     x2, 43               /* Asci values '+' = 43, '-' = 45, '*' = 42*/
    bne     gotoadd

    /* Subtraction*/
    cmp     x2, 45               /* Asci values '+' = 43, '-' = 45, '*' = 42*/
    bne     gotosub

    b       invalid



    ldr     x0, [x29, 28]        /* Load scanf Res from address into w0 register when done with scanf*/
    ldr     w0, =string1         /* Load string1 into w0 register*/
    bl      printf               /* Print string1*/

    ldr     w0, =string2         /* Load string2 into w0 register*/

invalid:
    ldr     w0, =string5         /* Load string5 in w0 register*/
    bl      printf

again:
    ldr     w0, =string4         /* Load string4 in w0 register*/
    bl      printf
    // You'll need to scan characters for the operation and to determine
    // if the program should repeat.
    // To scan a character, and compare it to another, do the following
loop: ldr     w0, =scanchar
      mov     x1, sp          // Save stack pointer to x1, you must create space
      bl      scanf           // Scan user's answer
      ldr     x1, =yes        // Put address of 'y' in x1
      ldrb    w1, [x1]        // Load the actual character 'y' into x1
      ldrb    w0, [sp]        // Put the user's value in r0
      cmp     w0, w1          // Compare user's answer to char 'y'
      b       loop            // branch to appropriate location

gotoadd:
    /* Check for negative numbers*/
    
    bl      intadd
gotosub:
    bl      intsub
gotomul:
    bl      intmul

yes:
    .byte   'y'
scanchar:
    .asciz  " %c"
scanint:
    .asciz  "%d"
    .space  1


string0:
    .asciz  "Enter Number 1: "
string1:
    .asciz  "Enter Number 2: "
string2:
    .asciz  "Enter Operation: "
string3:
    .asciz  "Result is: "
string4:
    .asciz  "Again?"
string5:
    .asciz  "Invalid Operation Entered."

