library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

-- Unidade de controle principal do processador RISC-V
-- Gera todos os sinais de controle necessários para a execução das instruções
-- Decodifica o opcode e gera sinais apropriados para cada tipo de instrução

entity controle is
    port (
        -- Entrada da instrução
        opcode    : in  std_logic_vector(6 downto 0);  -- código da operação
        funct3    : in  std_logic_vector(2 downto 0);  -- função específica
        funct7    : in  std_logic_vector(6 downto 0);  -- função auxiliar
        
        -- Saídas de controle
        branch    : out std_logic;  -- indica instrução de desvio
        memread   : out std_logic;  -- habilita leitura da memória
        memtoreg  : out std_logic;  -- seleciona dado da memória para escrita no registrador
        aluop     : out std_logic_vector(1 downto 0);  -- operação da ULA
        memwrite  : out std_logic;  -- habilita escrita na memória
        alusrc    : out std_logic;  -- seleciona fonte B da ULA
        regwrite  : out std_logic;  -- habilita escrita no banco de registradores
        
        -- Sinais de controle adicionais
        is_auipc   : out std_logic;  -- indica instrução AUIPC
        is_lui     : out std_logic;  -- indica instrução LUI
        jump       : out std_logic;   -- indica instrução de salto
        is_mem_op  : out std_logic    -- indica operação de memória
    );
end entity;

architecture rtl of controle is
    -- Opcodes do RISC-V
    constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";  -- Load Upper Immediate
    constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111";  -- Add Upper Immediate to PC
    constant OP_REG    : std_logic_vector(6 downto 0) := "0110011";  -- Operações reg-reg
    constant OP_IMM    : std_logic_vector(6 downto 0) := "0010011";  -- Operações reg-imm
    constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";  -- Load da memória
    constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";  -- Store na memória
    constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";  -- Branch condicional
    constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";  -- Jump and Link
    constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";  -- Jump and Link Register
    
begin
    -- Processo que define todos os sinais de controle baseado no opcode
    process(opcode, funct3, funct7)
    begin
        -- Configuração dos sinais para cada tipo de instrução
        case opcode is
            when OP_LUI =>
                -- Load Upper Immediate
                -- Carrega constante nos 20 bits mais significativos
                branch    <= '0';  -- não é desvio
                memread   <= '0';  -- não lê memória
                memtoreg  <= '0';  -- resultado da ULA para registrador
                aluop     <= "00";  -- passa valor direto
                memwrite  <= '0';  -- não escreve na memória
                alusrc    <= '1';  -- usa imediato
                regwrite  <= '1';  -- escreve no registrador
                is_auipc  <= '0';  
                is_lui    <= '1';  -- é instrução LUI
                jump      <= '0';  
                is_mem_op <= '0';
                
            when OP_AUIPC =>
                -- Add Upper Immediate to PC
                -- Soma imediato ao PC
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '1';  -- é instrução AUIPC
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_REG =>
                -- Operações registrador-registrador
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "10";  -- operações R-type
                memwrite  <= '0';
                alusrc    <= '0';  -- usa registrador
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_IMM =>
                -- Operações com imediato
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "11";  -- operações I-type
                memwrite  <= '0';
                alusrc    <= '1';  -- usa imediato
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_LOAD =>
                -- Instruções de load
                branch    <= '0';
                memread   <= '1';  -- lê da memória
                memtoreg  <= '1';  -- dado da memória para registrador
                aluop     <= "00";  -- soma para endereço
                memwrite  <= '0';
                alusrc    <= '1';  -- usa imediato para offset
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '1';  -- é operação de memória
                
            when OP_STORE =>
                -- Instruções de store
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";  -- soma para endereço
                memwrite  <= '1';  -- escreve na memória
                alusrc    <= '1';  -- usa imediato para offset
                regwrite  <= '0';  -- não escreve em registrador
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '1';  -- é operação de memória
                
            when OP_BRANCH =>
                -- Instruções de branch condicional
                branch    <= '1';  -- é desvio condicional
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "01";  -- comparação
                memwrite  <= '0';
                alusrc    <= '0';  -- usa registrador
                regwrite  <= '0';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_JAL =>
                -- Jump and Link
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';  -- salva endereço de retorno
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '1';  -- é salto incondicional
                is_mem_op <= '0';
                
            when OP_JALR =>
                -- Jump and Link Register
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';  -- salva endereço de retorno
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '1';  -- é salto incondicional
                is_mem_op <= '0';
                
            when others =>
                -- Instrução inválida ou não implementada
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '0';
                regwrite  <= '0';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
        end case;
    end process;
end architecture;