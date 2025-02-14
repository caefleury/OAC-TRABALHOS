# Projeto do Banco de Registradores do RISC-V

## Objetivo

Projetar, simular e sintetizar um banco de registradores similar ao utilizado no RISC-V.

## Características

- 32 registradores de 32 bits
- Dois barramentos de leitura
- Um barramento para escrita de dado
- Registrador 0 (índice zero) é constante, não pode ser alterado. Qualquer leitura deste registrador retorna o valor zero e escritas não afetam o seu valor.

## Interface

```vhdl
entity XREGS is
    generic (WSIZE : natural := 32);
    port (
        clk, wren : in std_logic;
        rs1, rs2, rd : in std_logic_vector(4 downto 0);
        data : in std_logic_vector(WSIZE-1 downto 0);
        ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
    );
end XREGS;
```

### Descrição dos Portos

- **WSIZE**: Tamanho da palavra do banco de registradores.
- **wren**: Habilitação de escrita. Ao ser acionado (‘1’), o registrador endereçado por `rd` é escrito com o valor presente na entrada `data` na transição de subida do relógio.
- **clk**: Relógio do circuito.
- **rs1**: Endereço do registrador a ser lido em `ro1`, 5 bits.
- **rs2**: Endereço do registrador a ser lido em `ro2`, 5 bits.
- **data**: Valor a ser escrito no registrador endereçado por `rd`, 32 bits.
- **ro1**: Porta de saída para leitura do registrador endereçado por `rs1`.
- **ro2**: Porta de saída para leitura do registrador endereçado por `rs2`.

## Observações

Um banco de registradores é similar a uma memória. Deve-se criar um tipo de dados (comando `type`) representando um vetor de palavras (comando `array`) e instanciá-lo.

## Verificação dos Resultados Usando ASSERT

O comando `ASSERT` é utilizado para verificação dos resultados no testbench. O formato é:

```vhdl
ASSERT condição
    [REPORT "mensagem"]
    [SEVERITY severity_level]
```

- **REPORT**: Permite enviar mensagens específicas relativas ao erro. A mensagem é escrita caso a condição avalie para falso.
- **SEVERITY**: Indica o nível de gravidade do erro, que pode assumir um dos seguintes valores: Note, Warning, Error (default) ou Failure.

Usando `ASSERT`, pode-se checar se o resultado esperado foi obtido, imprimindo mensagem de erro em caso contrário.

## Atividades de Verificação

- Preencher o banco de registradores com uma sequência de valores (laço `for` pode ser usado).
- Ler os valores escritos e verificar com `ASSERT` se estão corretos. Fazer a leitura para ambas as saídas.
- Neste processo, escrever um valor diferente de zero no registrador zero do banco, e verificar se ele não é alterado.
