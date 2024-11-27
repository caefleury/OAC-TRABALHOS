.data
    # Test data
    array: .word 1, 2, 3, 4, 5
    str:   .string "Test string"

.text
main:
    # Test immediate arithmetic
    li      t0, 10          # Load immediate
    addi    t1, t0, 5       # Add immediate
    slti    t2, t1, 20      # Set less than immediate
    slli    t3, t0, 2       # Shift left logical immediate
    srli    t4, t0, 1       # Shift right logical immediate
    srai    t5, t0, 1       # Shift right arithmetic immediate
    
    # Test register arithmetic
    add     s0, t0, t1      # Add
    sub     s1, t1, t0      # Subtract
    and     s2, t0, t1      # And
    or      s3, t0, t1      # Or
    xor     s4, t0, t1      # Xor
    slt     s5, t0, t1      # Set less than
    sltu    s6, t0, t1      # Set less than unsigned
    
    # Test memory operations
    la      t0, array       # Load address
    lw      t1, 0(t0)       # Load word
    sw      t1, 4(t0)       # Store word
    lb      t2, 8(t0)       # Load byte
    lbu     t3, 8(t0)       # Load byte unsigned
    lh      t4, 8(t0)       # Load halfword
    lhu     t5, 8(t0)       # Load halfword unsigned
    sb      t2, 12(t0)      # Store byte
    sh      t4, 12(t0)      # Store halfword
    
    # Test branches
    li      t0, 5
    li      t1, 10
    beq     t0, t0, label1  # Branch if equal
    j       exit            # Should not reach here
label1:
    bne     t0, t1, label2  # Branch if not equal
    j       exit            # Should not reach here
label2:
    blt     t0, t1, label3  # Branch if less than
    j       exit            # Should not reach here
label3:
    bge     t1, t0, label4  # Branch if greater or equal
    j       exit            # Should not reach here
label4:
    bltu    t0, t1, label5  # Branch if less than unsigned
    j       exit            # Should not reach here
label5:
    bgeu    t1, t0, label6  # Branch if greater or equal unsigned
    j       exit            # Should not reach here
label6:
    
    # Test jumps
    jal     ra, function    # Jump and link
    j       exit            # Jump to exit after return
    
function:
    # Test upper immediate
    lui     t0, 0x12345     # Load upper immediate
    auipc   t1, 0x1000     # Add upper immediate to PC
    jalr    zero, ra, 0     # Return
    
exit:
    # End program
    li      a7, 10          # Exit syscall
    ecall                   # Make the syscall
