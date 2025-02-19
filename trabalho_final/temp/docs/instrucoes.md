# Documentação das Instruções RISC-V

Este documento detalha todas as instruções em nossa implementação RISC-V, incluindo seu código de máquina, propósito e sinais de controle.

## Sequência de Instruções

### 1. ADDI (Adicionar Imediato)
```
Instrução: 00500113
Assembly: addi x2, x0, 5
Propósito: Adiciona o imediato 5 ao valor de x0 (0) e armazena em x2
Sinais de Controle:
- RegWrite = 1 (escreve no registrador)
- ALUSrc = 1 (usa imediato)
- ALUOp = 10 (operação tipo I)
```

### 2. ADDI (Adicionar Imediato)
```
Instrução: 00300193
Assembly: addi x3, x0, 3
Propósito: Adiciona o imediato 3 ao valor de x0 (0) e armazena em x3
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 3. ADD (Adição)
```
Instrução: 002081b3
Assembly: add x3, x1, x2
Propósito: Soma os conteúdos de x1 e x2, armazena em x3
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0 (usa registrador)
- ALUOp = 10 (operação tipo R)
```

### 4. SW (Armazenar Palavra)
```
Instrução: 00302223
Assembly: sw x3, 2(x0)
Propósito: Armazena palavra de x3 na memória no endereço x0 + 2
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1
```

### 5. LW (Carregar Palavra)
```
Instrução: 00102303
Assembly: lw x6, 1(x0)
Propósito: Carrega palavra da memória no endereço x0 + 1 para x6
Sinais de Controle:
- RegWrite = 1
- MemRead = 1
- MemtoReg = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1
```

### 6. ADDI (Adicionar Imediato)
```
Instrução: 00800293
Assembly: addi x5, x0, 8
Propósito: Adiciona o imediato 8 ao valor de x0 (0) e armazena em x5
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 7. AND (E Lógico)
```
Instrução: 0062f333
Assembly: and x6, x5, x6
Propósito: Realiza AND bit a bit entre x5 e x6, armazena em x6
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10
```

### 8. OR (OU Lógico)
```
Instrução: 0062e3b3
Assembly: or x7, x5, x6
Propósito: Realiza OR bit a bit entre x5 e x6, armazena em x7
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10
```

### 9. XOR (OU Exclusivo)
```
Instrução: 0063c433
Assembly: xor x8, x7, x6
Propósito: Realiza XOR bit a bit entre x7 e x6, armazena em x8
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10
```

### 10. SLTI (Set Less Than Immediate)
```
Instrução: 0032a513
Assembly: slti x10, x5, 3
Propósito: Define x10 como 1 se x5 < 3, senão define como 0
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 11. SW (Armazenar Palavra)
```
Instrução: 00402223
Assembly: sw x4, 4(x0)
Propósito: Armazena palavra de x4 na memória no endereço x0 + 4
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1
```

### 12. LW (Carregar Palavra)
```
Instrução: 00008303
Assembly: lw x6, 0(x1)
Propósito: Carrega palavra da memória no endereço x1 + 0 para x6
Sinais de Controle:
- RegWrite = 1
- MemRead = 1
- MemtoReg = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1
```

### 13. SUB (Subtração)
```
Instrução: 40418133
Assembly: sub x2, x3, x4
Propósito: Subtrai x4 de x3 e armazena em x2
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10
```

### 14. SLT (Set Less Than)
```
Instrução: 0041a233
Assembly: slt x4, x3, x4
Propósito: Define x4 como 1 se x3 < x4, senão define como 0
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10
```

### 15. LUI (Load Upper Immediate)
```
Instrução: 000012b7
Assembly: lui x5, 1
Propósito: Carrega o imediato 1 nos 20 bits mais significativos de x5
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 00
```

### 16. ADDI após LUI
```
Instrução: 01428293
Assembly: addi x5, x5, 20
Propósito: Adiciona 20 ao valor em x5
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 17. AUIPC (Add Upper Immediate to PC)
```
Instrução: 00001337
Assembly: auipc x6, 1
Propósito: Soma o imediato 1 (deslocado) ao PC e armazena em x6
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 00
```

### 18. ADDI após AUIPC
```
Instrução: 00830313
Assembly: addi x6, x6, 8
Propósito: Adiciona 8 ao valor em x6
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 19. SLLI (Shift Left Logical Immediate)
```
Instrução: 00129293
Assembly: slli x5, x5, 1
Propósito: Desloca x5 1 bit para a esquerda
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 20. SRLI (Shift Right Logical Immediate)
```
Instrução: 00235313
Assembly: srli x6, x6, 2
Propósito: Desloca x6 2 bits para a direita (lógico)
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 21. SRAI (Shift Right Arithmetic Immediate)
```
Instrução: 00231393
Assembly: srai x7, x6, 2
Propósito: Desloca x6 2 bits para a direita (aritmético)
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 22. SUB
```
Instrução: 402383b3
Assembly: sub x7, x7, x2
Propósito: Subtrai x2 de x7 e armazena em x7
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10
```

### 23. SRAI
```
Instrução: 00139413
Assembly: srai x8, x7, 1
Propósito: Desloca x7 1 bit para a direita (aritmético)
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 24. SRLI
```
Instrução: 00235493
Assembly: srli x9, x6, 2
Propósito: Desloca x6 2 bits para a direita (lógico)
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10
```

### 25. SW
```
Instrução: 00502023
Assembly: sw x5, 0(x0)
Propósito: Armazena palavra de x5 na memória no endereço x0 + 0
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1
```

### 26. LW
```
Instrução: 00408503
Assembly: lw x10, 4(x1)
Propósito: Carrega palavra da memória no endereço x1 + 4 para x10
Sinais de Controle:
- RegWrite = 1
- MemRead = 1
- MemtoReg = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1
```

### 27. BEQ (Branch if Equal)
```
Instrução: 00208263
Assembly: beq x1, x2, 4
Propósito: Desvia 4 instruções se x1 = x2
Sinais de Controle:
- Branch = 1
- ALUSrc = 0
- ALUOp = 01
```

### 28. JAL (Jump and Link)
```
Instrução: 0000006f
Assembly: jal x0, 0
Propósito: Salta para o endereço PC + 0
Sinais de Controle:
- RegWrite = 1
- Jump = 1
- ALUOp = 00
```

### 29. JALR (Jump and Link Register)
```
Instrução: 00008067
Assembly: jalr x0, x1, 0
Propósito: Salta para o endereço x1 + 0
Sinais de Controle:
- RegWrite = 1
- Jump = 1
- ALUSrc = 1
- ALUOp = 00
```
