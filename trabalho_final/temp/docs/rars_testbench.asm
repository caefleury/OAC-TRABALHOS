
.text
main:
    # Teste de instruções imediatas e aritméticas
    addi x2, x0, 5          # x2 = 5
    addi x3, x0, 3          # x3 = 3
    add x3, x1, x2          # x3 = x1 + x2 (0 + 5 = 5)
    
    # Teste de store/load
    sw x3, 4(x0)           # Memoria[4] = x3 (5)
    lw x6, 1(x0)           # x6 = Memoria[1]
    
    # Teste para operações lógicas
    addi x5, x0, 8         # x5 = 8
    and x6, x5, x6         # x6 = x5 & x6
    or x7, x5, x6          # x7 = x5 | x6
    xor x8, x7, x6         # x8 = x7 ^ x6
    
    # Teste de comparação
    slti x10, x5, 3        # x10 = (x5 < 3) ? 1 : 0
    
    # Mais testes de memória
    sw x4, 4(x0)           # Memoria[4] = x4
    lw x6, 0(x1)           # x6 = Memoria[x1 + 0]
    
    # Operações aritméticas
    sub x2, x3, x4         # x2 = x3 - x4
    slt x4, x3, x4         # x4 = (x3 < x4) ? 1 : 0
    
    # Testes com valores maiores
    lui x5, 1              # x5 = 1 << 12
    addi x5, x5, 20        # x5 = x5 + 20
    
    # Testes de shift
    slli x5, x5, 1         # x5 = x5 << 1
    srli x6, x6, 2         # x6 = x6 >> 2
    srai x7, x6, 2         # x7 = x6 >> 2 (aritmético)
    sra x7, x7, x2         # x7 = x7 >> x2 (aritmético)
    
    # Teste de comparação unsigned
    sltiu x8, x7, 1        # x8 = (x7 < 1) ? 1 : 0
    
    # Testes de salto
    beq x1, x2, skip       # if (x1 == x2) skip
    jal x0, continue       # jump to continue
skip:
    nop                    # No operation
continue:
    jalr x0, x1, 0        # Jump to address in x1

    # Fim do programa
    ebreak                 # Encerra a execução