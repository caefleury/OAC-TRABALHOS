.data
    num_test:    .word        0x00000002

.text

teste:
    addi t1, t1, 4
    
    lw t2, num_test
    
    add t3, t1, t2
    
    sub t1, t2, t3
    
    slt t3, t1, t2
    
    sltu t2, t1, t3

    sra  t2, t1, t3
     
     slti t2, t2, 1
     
     sll t2, t2, t2
     
     lui t1, 0x00001
     
     srl t1, t1, t2
     
     auipc t3, 0x00000
     
     beq t1, t3, teste
     
     addi t1, zero, 2
     
     bne t1, t2, teste
     
     jal teste2
     
teste2:
     
     jalr t1, zero, 0