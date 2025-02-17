# Trabalho: Memória RV

## 1. Objetivo

Desenvolver em VHDL:

- Uma memória de instruções (ROM) de 32 bits de largura, endereçada por 11 bits (capacidade de 2048 palavras).
- Uma memória de dados (RAM) de 32 bits de largura, endereçada a byte, com 13 bits de endereço (8192 bytes, organizados em 2048 palavras de 32 bits).

Interface com sinais de controle e dados coerentes com a arquitetura RISC-V:

- Para a ROM: somente leitura (sem controle de escrita), com carga inicial a partir de um arquivo de texto.
- Para a RAM: suporte a leitura e escrita, além da capacidade de acessar dados por palavra ou byte (com/sem sinal).

## 2. Características das Memórias

### 2.1 Memória de Instruções (ROM)

- Barramento de endereço: 11 bits, permitindo o endereçamento de até 2048 posições (cada posição armazena 1 palavra de 32 bits).
- Barramento de dados de saída: 32 bits (instrução completa).
- Carga de Instruções: Deve ser feita a partir de um arquivo texto externo em formato hexadecimal (1 palavra de 32 bits por linha).
- Leitura Combinacional: Ao receber o endereço, a ROM disponibiliza a instrução correspondente nos 32 bits de saída.
- Padrão VHDL: Utilizar VHDL-2008 para facilitar a inicialização via arquivo e declarar as memórias como vetores de std_logic_vector.

Entidade Sugerida:

```vhdl
entity rom_rv is
  port (
    address : in  std_logic_vector(10 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
end entity rom_rv;
```

### 2.2 Memória de Dados (RAM)

- Barramento de endereço: 13 bits, permitindo endereçar até 8192 bytes.
- Barramento de dados:
  - Entrada (write data): 32 bits.
  - Saída (read data): 32 bits.
- Controles:
  - `we` (write-enable): quando ativo em '1', permite a escrita na RAM na borda do clock.
  - `byte_en`: seleciona acesso a byte (1) ou a word (0).
  - `sgn_en`: indica se a leitura de byte é com extensão de sinal (1) ou sem sinal (0).

Organização Interna:

- A RAM armazena bytes, mas lê e escreve em 32 bits (palavras) quando `byte_en = 0`.
- Caso `byte_en = 1`, a operação de leitura/escrita deve se restringir a 1 byte (o byte selecionado é definido pelos bits menos significativos do endereço).

Inicialização:

- Opcionalmente, pode-se inicializar todo o conteúdo com zero, por exemplo, usando `(others => (others => '0'))`.
- Padrão VHDL: Utilizar VHDL-2008. Declarar a memória como um vetor de bytes e implementar a lógica para leituras e escritas de byte ou word.

Entidade Sugerida:

```vhdl
entity ram_rv is
  port (
    clck    : in  std_logic;
    we      : in  std_logic;
    byte_en : in  std_logic;
    sgn_en  : in  std_logic;
    address : in  std_logic_vector(12 downto 0);
    datain  : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
end entity ram_rv;
```

## 3. Estrutura Interna (Abordagem Sugerida)

### 3.1 Declarações e Tipos

Defina um tipo de array para armazenar dados na RAM. Por exemplo:

```vhdl
type mem_type is array (0 to (2**address'length)-1) of std_logic_vector(7 downto 0);
signal mem : mem_type;
```

Cada elemento contém 8 bits (1 byte), pois a RAM é organizada a nível de byte.

Para a ROM, utilize um tipo análogo (ou array unidimensional de 32 bits) e carregue seu conteúdo a partir de um arquivo texto usando construtos VHDL-2008 (instrução `file open`, etc.).

### 3.2 Acesso Word vs. Byte na RAM

**Acesso a Word:**

- Quando `byte_en = '0'`, considerar os 2 bits menos significativos de address como zero ao fazer leitura/escrita de 4 bytes contíguos.
- Garantir que `we = '1'` atualize todos os 4 bytes que compõem a word.

**Acesso a Byte:**

- Quando `byte_en = '1'`, utilizar os bits menos significativos de address para identificar qual dos 4 bytes da word será lido ou escrito.
- Em leitura, caso `sgn_en = '1'`, estender o bit de sinal (bit 7 do byte) para preencher os bits mais significativos (bits 31..8).
- Em leitura, caso `sgn_en = '0'`, completar os bits mais significativos com zero.

## 4. Método de Teste (Testbench)

Crie um arquivo de teste em VHDL para cada memória:

### 4.1 Teste da Memória de Instruções (ROM)

**Inicialização via Arquivo:**

- Prepare um arquivo texto contendo instruções em formato hexadecimal (uma por linha).
- Carregue esse arquivo na ROM durante a construção da simulação (instruções VHDL-2008).

**Leituras Sequenciais:**

- Varra alguns endereços (ex.: 0 a 15) e observe no waveform se cada instrução lida coincide com o valor armazenado no arquivo.

**Validação:**

- Verifique se o sinal dataout corresponde exatamente às palavras definidas no arquivo, para cada endereço.

Exemplo de laço de verificação:

```vhdl
for i in 0 to 15 loop
  address <= std_logic_vector(to_unsigned(i, 11));
  wait for 10 ns;  -- aguarda tempo de leitura combinacional
end loop;
```

### 4.2 Teste da Memória de Dados (RAM)

**Sinal de Clock:**
Crie um processo de geração de clock:

```vhdl
clk_gen: process
begin
  while true loop
    clck <= '0';
    wait for 5 ns;
    clck <= '1';
    wait for 5 ns;
  end loop;
end process;
```

**Escrita e Leitura de Words:**

1. Configure `byte_en = '0'` e `we = '1'`
2. Escreva algumas palavras em endereços diferentes (que sejam múltiplos de 4)
3. Em seguida, coloque `we = '0'` e leia esses endereços, conferindo se o retorno coincide com o valor escrito

**Escrita e Leitura de Bytes:**

1. Configure `byte_en = '1'` e `we = '1'`
2. Selecione endereços com qualquer valor nos 2 bits menos significativos
3. Escreva bytes específicos (por exemplo, `0xAA`, `0xBB` etc.) e depois leia-os de volta

**Extensão de Sinal:**

- Ao ler bytes com `sgn_en = '1'`, verifique se o bit mais significativo do byte (bit 7) é propagado corretamente aos bits 8..31 do dataout
- Ao ler bytes com `sgn_en = '0'`, verifique se esses bits são preenchidos com zero

**Verificação de Integridade:**

Exemplo de laço:

```vhdl
-- Escrita de words
for i in 0 to 3 loop
  address <= std_logic_vector(to_unsigned(i*4, 13));
  datain  <= std_logic_vector(to_unsigned(i, 32)); -- valor a gravar
  we      <= '1';
  byte_en <= '0'; 
  wait for 10 ns;
end loop;

-- Leitura de words
we <= '0';
for i in 0 to 3 loop
  address <= std_logic_vector(to_unsigned(i*4, 13));
  wait for 10 ns; -- tempo de leitura
  -- verificar se dataout bate com o valor gravado anteriormente
end loop;
```

## 5. Entrega

1. Código VHDL dos módulos:
   - `ram_rv.vhd`
   - `rom_rv.vhd`
   - Testbenches correspondentes (`tb_ram_rv.vhd`, `tb_rom_rv.vhd` etc.)

2. Arquivo de Instruções:
   - Arquivo texto (ex.: `instrucoes.txt`) com as instruções em formato hexadecimal, a serem carregadas na memória de instruções (ROM)

3. Simulações:
   - Capturas de Tela ou logs do waveform demonstrando a correta leitura/escrita em diferentes cenários (word/byte, com e sem extensão de sinal)
