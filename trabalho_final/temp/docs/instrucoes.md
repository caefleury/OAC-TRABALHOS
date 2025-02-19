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

## Sinais de Controle

Os seguintes sinais de controle são usados para configurar o processador:

- `ALUOp`: Define a operação da ULA
  - 00: Load/Store (soma)
  - 01: Branch (subtração)
  - 10: R-type/I-type (definido por funct3/funct7)

- `ALUSrc`: Seleciona a segunda entrada da ULA
  - 0: Registrador (rs2)
  - 1: Imediato

- `MemRead`: Habilita leitura da memória
- `MemWrite`: Habilita escrita na memória
- `MemtoReg`: Seleciona origem do dado para escrita no registrador
  - 0: Resultado da ULA
  - 1: Dado da memória

- `RegWrite`: Habilita escrita no banco de registradores
- `is_mem_op`: Indica operação de memória (load/store)
