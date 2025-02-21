# Documentação das Instruções RISC-V

Este documento detalha todas as instruções em nossa implementação RISC-V, incluindo seu código de máquina, propósito e sinais de controle.

## Sequência de Instruções

### 1. ADDI 
Instrução: `00500093`
Assembly: `addi x1, x0, 5`
Propósito: Inicializa x1 com valor 5
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10

### 2. ADDI 
Instrução: `00C00113`
Assembly: `addi x2, x0, 12`
Propósito: Inicializa x2 com valor 12
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10

### 3. ADDI 
Instrução: `00C00193`
Assembly: `addi x3, x0, 12`
Propósito: Inicializa x3 com valor 12
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10

### 4. ADDI 
Instrução: `FFC00F93`
Assembly: `addi x31, x0, -4`
Propósito: Inicializa x31 com valor -4
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 10

### 5. ADD 
Instrução: `00208233`
Assembly: `add x4, x1, x2`
Propósito: Soma x1 e x2, armazena em x4
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 6. SUB 
Instrução: `402182B3`
Assembly: `sub x5, x3, x2`
Propósito: Subtrai x2 de x3, armazena em x5
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 7. LUI (Load Upper Immediate)
Instrução: `00001337`
Assembly: `lui x6, 1`
Propósito: Carrega o valor 1 nos 20 bits mais significativos de x6
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 1
- ALUOp = 00

### 8. AND 
Instrução: `003173B3`
Assembly: `and x7, x2, x3`
Propósito: AND bit a bit entre x2 e x3, armazena em x7
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 9. SLT (Set Less Than)
Instrução: `0020A433`
Assembly: `slt x8, x1, x2`
Propósito: Define x8 como 1 se x1 < x2, senão 0
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 10. OR (OU Lógico)
Instrução: `0031E4B3`
Assembly: `or x9, x1, x3`
Propósito: OR bit a bit entre x1 e x3, armazena em x9
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 11. XOR (OU Exclusivo)
Instrução: `0020C533`
Assembly: `xor x10, x1, x2`
Propósito: XOR bit a bit entre x1 e x2, armazena em x10
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 12. SLL (Shift Left Logical)
Instrução: `00111593`
Assembly: `sll x11, x2, x1`
Propósito: Desloca x2 à esquerda por x1 posições, armazena em x11
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 13. SRL (Shift Right Logical)
Instrução: `00115613`
Assembly: `srl x12, x2, x1`
Propósito: Desloca x2 à direita por x1 posições, armazena em x12
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 14. SRA (Shift Right Arithmetic)
Instrução: `40115693`
Assembly: `sra x13, x2, x1`
Propósito: Desloca aritmético x2 à direita por x1 posições, armazena em x13
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 15. SLT (Set Less Than)
Instrução: `0020A733`
Assembly: `slt x14, x1, x2`
Propósito: Define x14 como 1 se x1 < x2, senão 0
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 16. SLTU (Set Less Than Unsigned)
Instrução: `0020B7B3`
Assembly: `sltu x15, x1, x2`
Propósito: Define x15 como 1 se x1 < x2 (unsigned), senão 0
Sinais de Controle:
- RegWrite = 1
- ALUSrc = 0
- ALUOp = 10

### 17. SB (Store Byte)
Instrução: `00100123`
Assembly: `sb x1, 1(x0)`
Propósito: Armazena byte menos significativo de x1 na memória no endereço x0 + 1
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 18. SB (Store Byte)
Instrução: `00200223`
Assembly: `sb x2, 2(x0)`
Propósito: Armazena byte menos significativo de x2 na memória no endereço x0 + 2
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 19. SW (Store Word)
Instrução: `00102223`
Assembly: `sw x1, 3(x0)`
Propósito: Armazena x1 na memória no endereço x0 + 3
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 20. SW (Store Word)
Instrução: `00202423`
Assembly: `sw x2, 4(x0)`
Propósito: Armazena x2 na memória no endereço x0 + 4
Sinais de Controle:
- MemWrite = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 21. LW (Load Word)
Instrução: `00102823`
Assembly: `lw x16, 1(x0)`
Propósito: Carrega palavra da memória no endereço x0 + 1 para x16
Sinais de Controle:
- RegWrite = 1
- MemRead = 1
- MemtoReg = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 22. LB (Load Byte)
Instrução: `00200883`
Assembly: `lb x17, 2(x0)`
Propósito: Carrega byte com extensão de sinal da memória no endereço x0 + 2 para x17
Sinais de Controle:
- RegWrite = 1
- MemRead = 1
- MemtoReg = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 23. LBU (Load Byte Unsigned)
Instrução: `01F00903`
Assembly: `lbu x18, 31(x0)`
Propósito: Carrega byte sem extensão de sinal da memória no endereço x0 + 31 para x18
Sinais de Controle:
- RegWrite = 1
- MemRead = 1
- MemtoReg = 1
- ALUSrc = 1
- ALUOp = 00
- is_mem_op = 1

### 24. BEQ (Branch if Equal)
Instrução: `00218463`
Assembly: `beq x2, x3, 8`
Propósito: Salta 8 bits se x2 = x3
Sinais de Controle:
- Branch = 1
- ALUSrc = 0
- ALUOp = 01

### 25. NOP (No Operation)
Instrução: `00000013`
Assembly: `addi x0, x0, 0`
Propósito: Não faz nada
Sinais de Controle:
- RegWrite = 0
- ALUSrc = 1
- ALUOp = 10

### 26. BNE (Branch if Not Equal)
Instrução: `00219463`
Assembly: `bne x2, x3, 8`
Propósito: Salta 8 bits se x2 ≠ x3
Sinais de Controle:
- Branch = 1
- ALUSrc = 0
- ALUOp = 01

### 27. JAL (Jump and Link)
Instrução: `00800973`
Assembly: `jal x19, 8`
Propósito: Salta 8 bits e salva PC+4 em x19
Sinais de Controle:
- RegWrite = 1
- Jump = 1

### 28. JALR (Jump and Link Register)
Instrução: `000300A7`
Assembly: `jalr x20, x3, 0`
Propósito: Salta para endereço em x3 + 0 e salva PC+4 em x20
Sinais de Controle:
- RegWrite = 1
- Jump = 1
- ALUSrc = 1