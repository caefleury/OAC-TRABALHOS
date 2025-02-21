# Projeto da Disciplina: RISC-V Uniciclo em VHDL

## OBJETIVO

O projeto da disciplina consiste no desenvolvimento de uma versão do
processador RV Uniciclo em VHDL. A ferramenta utilizada para o
desenvolvimento do projeto deverá ser o ModelSim-Altera ou o
EdaPlayground.

## DESCRIÇÃO

O diagrama esquemático de referência para a arquitetura básica do RISC-V
Uniciclo é apresentado na figura 1.

Este diagrama não está completo. Por exemplo, não permite implementar as
operações JAL e JALR, que requerem o salvamento de PC+4 em um
registrador e ainda, no caso de JALR, o cálculo do endereço de salto.

A implementação VHDL consiste na descrição de cada módulo e sua
interligação através de sinais.

A parte operativa do RISC-V é 32 bits, ou seja, os dados armazenados em
memória, os registradores, a unidade lógico-aritmética, as instruções e as
conexões utilizam 32 bits.

No caso das memórias, sugere-se utilizar apenas 12 bits de endereço, de
forma a manter compatibilidade com o espaço de endereçamento da
configuração compacta do RARS, onde o segmento de código começa no
endereço zero e o segmento de dados começa no endereço 0x2000.

### Módulos principais:

#### PC (Contador de Programa)

- Registrador de 32 bits
- Apenas os bits necessários são enviados à memória de instruções
- Carregado a cada transição de subida do relógio

#### Memória de Instruções (MI)

- Armazena o código a ser executado
- Instruções de 32 bits
- Espaço de endereçamento reduzido (ex: 12 bits)
- Funciona como bloco combinacional
- Não permite endereçamento a byte
- Para 12 bits de endereço de byte (PC(11:0)), usar bits 2 a 11 do PC como endereço de instrução

#### Banco de Registradores (XREG)

- 32 registradores de 32 bits
- XREG[0] é constante (sempre zero, não pode ser escrito)
- Duas entradas de endereços para leitura simultânea
- Uma entrada para seleção de registrador para escrita
- Escrita ocorre na transição de subida do relógio
- Escrita controlada pelo sinal RegWrite (RegWrite = '1' habilita escrita)

#### Unidade Lógico-Aritmética (ULA)

- Opera sobre dados de 32 bits
- Resultado em 32 bits
- Sinal ZERO indica resultado zero
- Para deslocamentos: usar funções `shift_left` e `shift_right` do pacote `numeric_std`

#### Memória de Dados (MD)

- Armazena dados do programa
- Leitura/escrita em nível de byte ou word
- Leitura de byte com/sem extensão de sinal
- 14 bits de endereço (16KB)
- Endereço base: 0x00002000 (modelo RARS)
- Escrita na subida do relógio com MemWrite acionado

#### Outros Componentes

- 4 multiplexadores 2:1 (32 bits entrada/saída)
- 2 somadores de 32 bits para endereços

### Operações da ULA

| Operação  | Significado | OpCode |
|-----------|-------------|---------|
| ADD A, B  | Soma com vem-um | 0000 |
| SUB A, B  | Subtração | 0001 |
| AND A, B  | AND bit a bit | 0010 |
| OR A, B   | OR bit a bit | 0011 |
| XOR A, B  | XOR bit a bit | 0100 |
| SLL A, B  | Deslocamento à esquerda | 0101 |
| SRL A, B  | Deslocamento à direita sem sinal | 0110 |
| SRA A, B  | Deslocamento à direita com sinal | 0111 |
| SLT A, B  | Set if less than (com sinal) | 1000 |
| SLTU A, B | Set if less than (sem sinal) | 1001 |
| SGE A, B  | Set if greater/equal (com sinal) | 1010 |
| SGEU A, B | Set if greater/equal (sem sinal) | 1011 |
| SEQ A, B  | Set if equal | 1100 |
| SNE A, B  | Set if not equal | 1101 |

## INSTRUÇÕES A SEREM IMPLEMENTADAS

1. **Geração de constantes (K)**
   - AUIPC, LUI

2. **Aritméticas (A)**
   - ADD, SUB

3. **Aritméticas com imediato (Ai)**
   - ADDi

4. **Lógicas (L)**
   - AND, SLT, OR, XOR

5. **Lógicas com imediato (Li)**
   - ANDi, ORi, XORi

6. **Shift (S)**
   - SLL, SRL, SRA

7. **Shift com imediato (Si)**
   - SLLi, SRLi, SRAi

8. **Comparação (C)**
   - SLT, SLTu

9. **Comparação com imediato (Ci)**
   - SLTi, SLTUi

10. **Subrotinas (J)**
    - JAL, JALR

11. **Saltos 1 (S1)**
    - BEQ, BNE

12. **Saltos 2 (S2)**
    - BLT, BGE

13. **Saltos 3 (S3)**
    - BGEU, BLTU

14. **Memória (M)**
    - LW, LB, LBU, SW, SB

## VERIFICAÇÃO DO RISC-V UNICICLO

O processador implementado deve ser capaz de executar um código gerado
pelo RARS, utilizando o modelo de memória compacto.


