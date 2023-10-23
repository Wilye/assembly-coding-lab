# assembly-coding-lab
Assembly Coding Lab

I wrote chArm-v2 assembly code to realize the eight functions
specified below.

1. unsigned long ntz(const unsigned long n); This function counts the number of trail-
ing 0-bits in the argument n. The answer can be anywhere from 0 to 64. There are no error conditions
that need to be checked. The function must use a recursive doubling algorithm and must be straight-
line code. No loops permitted.
Hint: Think of how you can create a mask that will identify the trailing 0-bits of n.
2. long Aiken_to_long(const unsigned long buf);
This function takes the argument buf, interprets each nibble as the binary encoding of a base-10
digit using the Aiken code1, and returns the binary representation of the encoded number. The Aiken
code represents 0 as 0x0, 1 as 0x1, 2 as 0x2, 3 as 0x3, and 4 as 0x4. The representations of the
remaining base-10 digits are the bitwise complements of 9 minus the digit: thus, 5 is represented as
0xB, 6 as 0xC, 7 as 0xD, 8 as 0xE, and 9 as 0xF.
Thus, if buf == 0x042FUL, the result is 429 == 0x1ADUL; if buf == 0x0DED12UL, the
result is 78712 == 0x13378UL. It is an error for any nibble of the argument to contain the patterns
0x5 through 0xA. Such input errors must be detected by your implementation, and conveyed back to
the caller by returning the result value −1. You may use loops to implement this function. You may
not use lookup tables.
3. void unicode_to_UTF8(const unsigned long a, char utf8[4]);
This function writes into the char array utf8 the UTF-8 encoding of the code point U+a. Thus, if
a == 0x41, the utf8 array should be set to {0x41, 0x00, 0x00, 0x00}; if a == 0x22B,
the utf8 array should be set to {0xC8, 0xAB, 0x00, 0x00}; and if a == 0x1F638, the
utf8 array should be set to {0xF0, 0x9F, 0x98, 0xB8}. If a is outside the Unicode codespace,
set all four elements of the utf8 array to 0xFF.
4. unsigned long UTF8_to_unicode(const char utf8[4]);
This function returns the value a such that the char array utf8 contains the UTF-8 encoding of
the code point U+a. Thus, if the utf8 array is {0x41, 0x00, 0x00, 0x00}, the function
should return 0x41; if the utf8 array is {0xC8, 0xAB, 0x00, 0x00}, the function should re-
turn 0x22B; and if the utf8 array is {0xF0, 0x9F, 0x98, 0xB8}, the function should return
0x1F638. You do not have to check for any error conditions.
5. long ustrncmp(const char* str1, const char* str2,
const unsigned long num);
This function compares the first num characters of str1 and str2. If all of the first num characters
of str1 are equal to the corresponding character of str2, return 2. If you reach a null terminator
in either string before finding an unequal character (i.e., they had been equal so far), return 100.
Otherwise, you will find a character within the first num characters of str1 and str2 that are
different. In this case, return −1 if the character in str1 is less than the character in str2 (according
1Historical note: This code was invented by Howard Aiken, of “Harvard architecture” fame.
3
to the ASCII collating sequence), and return 1 otherwise. You do not need to check for null inputs in
this problem.
6. unsigned long gcd_rec(const unsigned long a, const unsigned long b);
This function returns the greatest common divisor of the arguments a and b using a recursive version
of Euclid’s algorithm.2 If either argument has value zero, return the value −1.
You must use the BL instruction in this function to implement self-recursion. You may want to
implement a helper function for this problem.
7. long tree_traversal(const node_t* root, const long bit_string,
const long bit_string_length)
This function traverses a binary (but not necessarily balanced) tree and returns the value stored inside
the final node of a given path.3 The parameter root contains the root of the tree, the parameter
bit_string contains a list of tree-traversal directions, and the parameter bit_string_length
contains the length of bit_string. The bit string is read from right to left. A zero bit refers to the
left child and a one bit refers to the right child. Return the value contained inside the node at the end
of the traversal. If you encounter a null pointer at any point, return −1. If bit_string_length
is 0, return −1.
The type node_t is defined as follows.
typedef struct node {
struct node* left;
struct node* right;
long value;
} node_t;
8. unsigned long Collatz_TST(unsigned long n);
Given an arbitrary positive integer n, define the function f such that:
f (n) =
(
n/2, if n is even
3n + 1, if n is odd.
Now define the sequence C(n) = [c0, c1, · · ·] as follows:
ci =
(
n, if i = 0
f (ci−1), otherwise.
The total stopping time (TST) of n is defined as the smallest k such that ck in the sequence C(n)
is equal to 1.4 The Collatz conjecture, one of the most famous unsolved problems in mathematics,
asserts that the total stopping time of every n is finite.
This function returns the TST of its parameter n. For instance, Collatz_TST(9) == 19,
Collatz_TST(871) == 178, and Collatz_TST(9780657631) == 1132.
You must use the function ntz in implementing this function. You do not need to check for any error
conditions in the input.

The chArm-v2 instruction set consists of the following 23-instruction subset of the full A64 instruction
set:
• Data transfer: LDUR, STUR.
• Data processing — immediate: MOVK, MOVZ, ADRP.
• Computation: ADD, ADDS, SUB, SUBS, CMP, MVN, ORR, EOR, ANDS, TST, LSL, LSR, ASR.
• Control transfer: B, B.cond, BL, RET.
• Miscellaneous: NOP.
chArm-v2 supports only the 64-bit versions of these instructions. That is, all registers are X registers, not W
registers.
