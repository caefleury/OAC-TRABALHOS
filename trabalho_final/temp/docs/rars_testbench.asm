.text
main:
    addi x1, x0, 5      # Initialize x1 with 5
    addi x2, x0, 12     # Initialize x2 with 12
    addi x3, x0, 12     # Initialize x3 with 12
    addi x31, x0, -4    # Initialize x31 with -4
    add x4, x1, x2      # x4 = x1 + x2
    sub x5, x3, x2      # x5 = x3 - x2
    lui x6, 1           # Load upper immediate
    and x7, x2, x3      # x7 = x2 & x3
    slt x8, x1, x2      # x8 = (x1 < x2) ? 1 : 0
    or x9, x1, x3       # x9 = x1 | x3
    xor x10, x1, x2     # x10 = x1 ^ x2
    sll x11, x2, x1     # x11 = x2 << x1
    srl x12, x2, x1     # x12 = x2 >> x1
    sra x13, x2, x1     # x13 = x2 >>> x1
    slt x14, x1, x2     # x14 = (x1 < x2) ? 1 : 0
    sltu x15, x1, x2    # x15 = (x1 < x2) ? 1 : 0 (unsigned)
    sb x1, 1(x0)        # Store byte
    sb x2, 2(x0)        # Store byte
    sw x1, 3(x0)        # Store word
    sw x2, 4(x0)        # Store word
    lw x16, 1(x0)       # Load word
    lb x17, 2(x0)       # Load byte
    lbu x18, 31(x0)     # Load byte unsigned
    beq x2, x3, skip    # Branch if equal
    nop                 # No operation
skip:
    bne x2, x3, next    # Branch if not equal
    jal x19, next       # Jump and link
    jalr x20, x3, 0     # Jump and link register
next:
    nop