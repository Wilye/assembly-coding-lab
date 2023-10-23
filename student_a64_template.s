  // This is the general format of an assembly-language program file.
    // Written by: Shelby Yang sy22852
    .arch armv8-a
    .text
    // Code for all functions go here.



    // ***** WEEK 1 deliverables *****



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global ntz
    .type   ntz, %function

ntz:
    // (STUDENT TODO) Code for ntz goes here.
    // Input parameter n is passed in X0
    // Output value is returned in X0.
    // Check if the input is zero, if yes, return 64 as there are 64 trailing zeros

    // if n == 0, return 64
    CMP X0, #0
    B.EQ zero_case

    // count = 0
    MOVZ X1, #0

    // checks lower 32 bits
    ORR X2, XZR, #0xFFFFFFFF // mask for lower 32 bits in X2, can't do MOV or MOVK because out of range
    TST X0, X2                     
    B.EQ add_32
    B check_16
add_32:
    ADD X1, X1, #32 // count += 32
    LSR X0, X0, #32 // shift right by 32
    B check_16
check_16:
    ORR X2, XZR, #0xFFFF // mask for lower 16 bits in X2
    TST X0, X2                      
    B.EQ add_16
    B check_8
add_16:
    ADD X1, X1, #16 // count += 16
    LSR X0, X0, #16 // shift right by 16
    B check_8
check_8:
    ORR X2, XZR, #0xFF // loads mask for lower 8 bits
    TST X0, X2                      
    B.EQ add_8
    B check_4
add_8:
    ADD X1, X1, #8 // count += 8
    LSR X0, X0, #8 // shift right by 8, as we are done with these bits
    B check_4
check_4:
    ORR X2, XZR, #0xF // load mask for lower 4 bits
    TST X0, X2 // test lower 4 bits
    B.EQ add_4
    B check_2
add_4:
    ADD X1, X1, #4 // count += 4
    LSR X0, X0, #4 // shift right by 4 bc we are done with these bits
    B check_2
check_2:
    ORR X2, XZR, #0x3 // load mask for lower 2 bits
    TST X0, X2 /// test the lower 2 bits
    B.EQ add_2
    B check_1
add_2:
    ADD X1, X1, #2 // count += 2
    LSR X0, X0, #2 // shift right by 2 bc we are done with these bits
    B check_1
check_1:
    ORR X2, XZR, #0x1 // load mask for lowest bit
    TST X0, X2                      
    B.NE final // if the lowest bit is not zero we're done counting.
    ADD X1, X1, #1 // otherwise, count++
final:
    ORR X0, XZR, X1
    RET
zero_case:
    MOVZ X0, #64 
    RET
    .size   ntz, .-ntz
    // ... and ends with the .size above this line.




    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global aiken_to_long
    .type   aiken_to_long, %function

aiken_to_long:
    // Input parameter buf is passed in X0
    // Output value is returned in X3.
    orr X3, XZR, XZR  // result = 0
    orr X2, XZR, X0 // copy of buf in X2
    orr X4, XZR, XZR // to determine the position of the most significant nibble
find_msn: // find most significant nibble
    lsr X5, X2, X4
    cmp X5, #0
    b.ne continue_search
    sub X4, X4, #4 // subtract 4 because we've gone one nibble too far
    b process_nibbles
continue_search:
    add X4, X4, #4 // move to the next nibble
    b find_msn
process_nibbles:
    // process each nibble from msn to lsn
while_loop:
    cmp X4, #0
    b.lt end_loop // if we've shifted right past the lsn, we're done

    // isolate the current nibble
    lsr X5, X2, X4
    movz X6, #0xF, LSL #0
    ands X1, X5, X6

    // check for invalid nibble
    cmp X1, #0x5
    b.ge check_invalid_nibble
    b append_nibble // if it's not greater or equal, it's a valid nibble (0-4)
check_invalid_nibble:
    cmp X1, #0xA
    b.le invalid_nibble // nibble is between 0x5 and 0xA, which is invalid

    // nibble is 0xB to 0xF, convert to actual value
    sub X1, X1, #0xB
    add X1, X1, #5 // 0xB represents 5, 0xC represents 6, and so on
append_nibble:
    // multiply the current result by 10
    movz X6, #10, LSL #0
    lsl X7, X3, #1      // X7 = X3 * 2 
    lsl X8, X3, #3      // X8 = X3 * 8
    add X3, X7, X8      // X3 = (X3 * 2) + (X3 * 8)

    // add the new decimal digit to the result.
    add X3, X3, X1 // X3 = X3 + X1 (X1 is the decoded decimal digit)

    // move to the next nibble position.
    sub X4, X4, #4
    b while_loop
invalid_nibble:
    orr X9, XZR, XZR
    mvn X0, X9 // moves NOT 0 (which is all 1s in binary or -1 in two's complement)
    ret
end_loop:
    orr X0, XZR, X3
    ret
    .size   aiken_to_long, .-aiken_to_long
    // ... and ends with the .size above this line.



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global unicode_to_UTF8
    .type   unicode_to_UTF8, %function

unicode_to_UTF8:
    // (STUDENT TODO) Code for unicode_to_UTF8 goes here.
    // Input parameter a is passed in X0; input parameter utf8 is passed in X1.
    // There are no output values.
    movz X2, #0xFFFF // move 0xFFFF into X2
    movk X2, #0x10, LSL #16 // insert 0x10 at bits 16 through 31, creating 0x10FFFF in X2
    cmp X0, X2 // compare 'a' with 0x10FFFF
    b.hi outside_unicode_range // if higher, it's invalid
    // handle 1 byte (U+0000 to U+007F)
    cmp X0, #0x7F
    b.ls one_byte_utf8 // if less or same
    // handle 2-byte (U+0080 to U+07FF)
    cmp X0, #0x7FF                   
    b.ls two_byte_utf8
    // handle 3-byte (U+0800 to U+FFFF)
    movz X3, #0xFFFF
    cmp X0, X3                      
    b.ls three_byte_utf8
    // has to be 4 byte
    b four_byte_utf8
one_byte_utf8:
    // 1-byte UTF-8 format: 0xxxxxxx
    stur X0, [X1] // store the low byte of 'a' into utf8[0]
    orr X2, XZR, XZR  // prepare 0x0 to clear the other bytes
    stur X2, [X1, #1] // clear utf8[1] 
    stur X2, [X1, #2]             
    stur X2, [X1, #3] 
    b finished
two_byte_utf8:
    // 110xxxxx 10xxxxxx
    movz X2, #0xC0 // move 0xC0 (11000000) into X2 for the first byte
    orr X2, X2, X0, lsr #6 //shift 'a' right by 6 bits and OR with 0xC0 for the first byte
    stur X2, [X1]  // store the first byte into utf8[0]

    ands X3, X0, #0x3F                
    movz X2, #0x80                  
    orr X2, X2, X3                   
    stur X2, [X1, #1] // store the second byte into utf8[1]
    
    orr X2, XZR, XZR  // prepare 0x0 to clear the other bytes
    stur X2, [X1, #2]                
    stur X2, [X1, #3]                
    b finished
three_byte_utf8:
    // 1110xxxx 10xxxxxx 10xxxxxx
    movz X2, #0xE0  // move 0xE0 (11100000) into X2 for the first byte
    orr X2, X2, X0, lsr #12 // shift 'a' right by 12 bits and OR with 0xE0 for the first byte
    stur X2, [X1] // store the first byte into utf8[0]

    lsr X3, X0, #6                   
    ands X3, X3, #0x3F               
    movz X2, #0x80                   
    orr X2, X2, X3                   
    stur X2, [X1, #1] // store the second byte into utf8[1]

    ands X3, X0, #0x3F                
    movz X2, #0x80                   
    orr X2, X2, X3                   
    stur X2, [X1, #2] // store the third byte into utf8[2]
    
    orr X2, XZR, XZR                 // prepare 0x0 to clear the other byte
    stur X2, [X1, #3]                // clear utf8[3]
    b finished
four_byte_utf8:
    // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    movz X2, #0xF0 // move 0xF0 (11110000) into X2 for the first byte
    orr X2, X2, X0, lsr #18 // shift 'a' right by 18 bits and OR with 0xF0 for the first byte
    stur X2, [X1] // store the first byte into utf8[0]

    lsr X3, X0, #12                  
    ands X3, X3, #0x3F                
    movz X2, #0x80 
    orr X2, X2, X3 // OR with 0x80 for the second byte
    stur X2, [X1, #1] // store the second byte into utf8[1]

    lsr X3, X0, #6  
    ands X3, X3, #0x3F 
    movz X2, #0x80 
    orr X2, X2, X3 
    stur X2, [X1, #2] // store the third byte into utf8[2]

    ands X3, X0, #0x3F // mask 'a' with 0x3F (00111111) for the fourth byte
    movz X2, #0x80                   
    orr X2, X2, X3                   
    stur X2, [X1, #3] // store the fourth byte into utf8[3]
    b finished

outside_unicode_range:
    // set all four elements of utf8 to 0xFF
    movz X0, #0x0            
    movk X0, #0xFFFF, LSL 0  
    movk X0, #0xFFFF, LSL 16 
    stur X0, [X1] // store the 0xFFFFFFFF into utf8
    b finished

finished:
    ret
    .size   unicode_to_UTF8, .-unicode_to_UTF8
    // ... and ends with the .size above this line.



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global UTF8_to_unicode
    .type   UTF8_to_unicode, %function

UTF8_to_unicode:
    // (STUDENT TODO) Code for UTF8_to_unicode goes here.
    // Input parameter utf8 is passed in X0.
    // Output value is returned in X0.
    // load first byte
    ldur w1, [x0]

    // check for 1 byte 0xxxxxxx
    ands w2, w1, #0x80  // mask the leftmost bit
    tst w2, w2 
    b.eq one_byte_unicode 

    // check for 2 byte 110xxxxx 10xxxxxx
    ands w2, w1, #0xE0  // mask the leftmost 3 bits
    cmp w2, #0xC0  // compare with 11000000
    b.eq two_byte_unicode

    // check for 3 byte 1110xxxx 10xxxxxx 10xxxxxx
    ands w2, w1, #0xF0  // mask the leftmost 4 bits
    cmp w2, #0xE0  // compare with 11100000
    b.eq three_byte_unicode

    // must be 4-byte 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    b four_byte_unicode
one_byte_unicode:
    orr x0, xzr, x1
    ret
two_byte_unicode:
    ldur w2, [x0, #1]

    ands w1, w1, #0x1F  // mask out the leftmost 3 bits of w1
    ands w2, w2, #0x3F  // mask out the leftmost 2 bits of w2
    // shift w1 left by 6 bits and OR with w2
    lsl w1, w1, #6
    orr w0, w1, w2
    ret
three_byte_unicode:
    ldur w2, [x0, #1]
    ldur w3, [x0, #2]
    // w1: 1110xxxx -> xxxx
    // w2: 10xxxxxx -> xxxxxx
    // w3: 10xxxxxx -> xxxxxx
    ands w1, w1, #0x0F  // mask out the leftmost 4 bits of w1
    ands w2, w2, #0x3F  // mask out the leftmost 2 bits of w2
    ands w3, w3, #0x3F  // mask out the leftmost 2 bits of w3
    // shift w1 left by 12 bits, w2 left by 6 bits, and leave w3 as is
    lsl w1, w1, #12
    lsl w2, w2, #6
    orr w0, w1, w2
    orr w0, w0, w3
    ret
four_byte_unicode:
    ldur w2, [x0, #1]
    ldur w3, [x0, #2]
    ldur w4, [x0, #3]
    ands w1, w1, #0x07  // mask out leftmost 5 bits of w1
    ands w2, w2, #0x3F  // mask out leftmost 2 bits of w2
    ands w3, w3, #0x3F  // mask out leftmost 2 bits of w3
    ands w4, w4, #0x3F  // mask out leftmost 2 bits of w4
    // combine the bits
    lsl w1, w1, #18
    lsl w2, w2, #12
    lsl w3, w3, #6
    orr w0, w1, w2
    orr w0, w0, w3
    orr w0, w0, w4
    ret
    .size   UTF8_to_unicode, .-UTF8_to_unicode
    // ... and ends with the .size above this line.



    // ***** WEEK 2 deliverables *****



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global ustrncmp
    .type   ustrncmp, %function

ustrncmp:
    // (STUDENT TODO) Code for ustrncmp goes here.
    // Input parameter str1 is passed in X0; input parameter str2 is passed in X1;
    //  input parameter num is passed in X2
    // Output value is returned in X0.
    movz x10, #0 // n = 0
ustrncmp_while_loop:
    cmp x10, x2 //if n == num, exit the loop
    b.eq ustrncmp_exit_loop
    add  x11, x0, x10 // calculate base address for indexing into str1
    ldur x3, [x11] // Load the nth character of str1 into x3
    ands x3, x3, #0xFF  // Isolate the nth character of str1
    add  x11, x1, x10 // calculate base address for indexing into str2
    ldur x4, [x11] // loads the nth character of str2 into x4
    ands x4, x4, #0xFF  // Isolate the nth character of str2
    cmp x3, #0
    b.eq ustrncmp_is_null
    cmp x4, #0
    b.eq ustrncmp_is_null
    cmp x3, x4
    b.lt ustrncmp_charstr1_le_charstr2
    b.ne ustrncmp_not_equal
    add x10, x10, #1
    b ustrncmp_while_loop
ustrncmp_charstr1_le_charstr2:
    movz x1, #0  // x1 = 0
    mvn x0, x1   // x0 = ~x1 = -1
    ret
ustrncmp_is_null:
    movz x0, #100
    ret
ustrncmp_not_equal:
    movz x0, #1
    ret
ustrncmp_exit_loop:
    movz x0, #2
    ret

    .size   ustrncmp, .-ustrncmp
    // ... and ends with the .size above this line.



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global gcd_rec
    .type   gcd_rec, %function

gcd_rec:
    // (STUDENT TODO) Code for gcd_rec goes here.
    // Input parameter a is passed in X0; input parameter b is passed in X1.
    // Output value is returned in X0.
    cmp x0, #0
    b.eq .zero_value
    cmp x1, #0
    b.eq .zero_value

    // adjust the stack pointer to make space for saving LR of the ORIGINAL CALLER!
    sub sp, sp, #16
    // save LR on the stack
    stur x30, [sp]
.gcd:
    cmp x1, #0
    b.eq .should_return
    orr x2, xzr, x0         // copy a to X2
    orr x3, xzr, x1         // copy b to X3
.gcd_loop:
    cmp X2, X3           // compare X2 (a) and X3 (b)
    b.lo .gcd_done             // if X2 < X3, branch to done
    sub X2, X2, X3       // X2 = X2 - X3
    b .gcd_loop           // repeat loop
.gcd_done:
    orr x0, xzr, x1
    orr x1, xzr, x2   // now X1 holds a mod b
    bl .gcd               // recursive call: gcd_rec(b, a mod b)
    // recursion will return result in X0
    ret
.should_return:
    // restore original caller LR from the stack
    ldur x30, [sp]
    // adjust the stack pointer back to its original position
    add sp, sp, #16
    ret
.zero_value:
    movz x4, #0
    mvn x0, x4  // Set return value to -1
    ret

    .size   gcd_rec, .-gcd_rec
    // ... and ends with the .size above this line.



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global tree_traversal
    .type   tree_traversal, %function

tree_traversal:
    cmp x2, #0
    b.eq return_minus_one  // if bit_string_length is 0, return -1
    cmp x0, #0
    b.eq return_minus_one  // if root is null, return -1
tree_traversal_loop:
    sub x2, x2, #1  // bit_string_length--
    orr x4, xzr, x2
    ands x3, x1, #1  // isolate the LSB of bit_string
    lsr x1, x1, #1  // shift bit_string right to prepare for next iteration (so the second most LSB becomes the LSB)

    cmp x3, #0
    b.eq left_child  // if LSB is 0, go left
    b right_child       // otherwise, go right
left_child:
    ldur x0, [x0]  // load the address of the left child
    cmp x0, #0
    b.eq return_minus_one  // if the left child is null, return -1
    cmp x2, #0
    b.eq load_value  // if no more bits to process (bit string length == 0), load the value
    b tree_traversal_loop
right_child:
    ldur x0, [x0, #8]  // load the address of the right child
    cmp x0, #0
    b.eq return_minus_one  
    cmp x2, #0
    b.eq load_value 
    b tree_traversal_loop
load_value:
    ldur x0, [x0, #16]  // load the value from the node
    ret
return_minus_one:
    movz x4, #0
    mvn x0, x4
    ret

    .size   tree_traversal, .-tree_traversal
    // ... and ends with the .size above this line.



    // Every function starts from the .align below this line ...
    .align  2
    .p2align 3,,7
    .global collatz_TST
    .type   collatz_TST, %function

collatz_TST:
    // Input parameter n is passed in X0
    // Output value is returned in X0.
    
    // initialize count to 0
    MOVZ X1, #0

.loop:
    // check if n is 1, if yes, we're done
    CMP X0, #1
    B.EQ .done

    SUB SP, SP, #32
    STUR X0, [SP]      // save original value of n
    STUR X1, [SP, #8] // save count
    STUR LR, [SP, #16]  // save LR
    
    // call ntz to find the number of times n can be halved
    BL ntz
    orr x3, xzr, x0
    
    // restore n and LR from the stack
    LDUR X0, [SP]      // load original value of n into X3
    LDUR X1, [SP, #8] // restore count
    LDUR LR, [SP, #16]  // restore LR
    ADD SP, SP, #32

    cmp x3, #0
    b.eq .odd

.even:
    LSR X0, X0, #1
    B .increment

.odd:
    // n is odd, perform n = 3n + 1
    // use logical shift left to multiply by 2 (n*2) and then add n to result (n*3)
    LSL X2, X0, #1
    ADD X0, X0, X2
    // now add 1 to get 3n + 1
    ADD X0, X0, #1
    B .increment

.increment:
    // increment the count
    ADD X1, X1, #1
    B .loop

.done:
    // return the count in X0
    orr X0, xzr, X1
    RET

    .size   collatz_TST, .-collatz_TST
    // ... and ends with the .size above this line.



    .section    .rodata
    .align  4
    // (STUDENT TODO) Any read-only global variables go here.
    .data
    // (STUDENT TODO) Any modifiable global variables go here.
    .align  3
