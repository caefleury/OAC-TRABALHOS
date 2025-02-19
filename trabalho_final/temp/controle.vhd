library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

entity controle is
    port (
        -- Instruction input
        opcode    : in  std_logic_vector(6 downto 0);
        funct3    : in  std_logic_vector(2 downto 0);
        funct7    : in  std_logic_vector(6 downto 0);
        
        -- Control outputs
        branch    : out std_logic;
        memread   : out std_logic;
        memtoreg  : out std_logic;
        aluop     : out std_logic_vector(1 downto 0);
        memwrite  : out std_logic;
        alusrc    : out std_logic;
        regwrite  : out std_logic;
        
        -- Additional control signals for specific instructions
        is_auipc   : out std_logic;  -- '1' para AUIPC
        is_lui     : out std_logic;  -- '1' para LUI
        jump       : out std_logic;   -- '1' para saltos
        is_mem_op  : out std_logic    -- '1' para operações de memória
    );
end entity;

architecture rtl of controle is
    -- RISC-V Opcodes
    constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";
    constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111";
    constant OP_REG    : std_logic_vector(6 downto 0) := "0110011";
    constant OP_IMM    : std_logic_vector(6 downto 0) := "0010011";
    constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";
    constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";
    constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";
    
begin
    process(opcode, funct3, funct7)
    begin
        case opcode is
            when OP_LUI =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '1';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_AUIPC =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '1';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_REG =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "10";
                memwrite  <= '0';
                alusrc    <= '0';
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_IMM =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "10";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_LOAD =>
                branch    <= '0';
                memread   <= '1';
                memtoreg  <= '1';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '1';
                
            when OP_STORE =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '1';
                alusrc    <= '1';
                regwrite  <= '0';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '1';
                
            when OP_BRANCH =>
                branch    <= '1';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "01";
                memwrite  <= '0';
                alusrc    <= '0';
                regwrite  <= '0';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '0';
                is_mem_op <= '0';
                
            when OP_JAL =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '1';
                is_mem_op <= '0';
                
            when OP_JALR =>
                branch    <= '0';
                memread   <= '0';
                memtoreg  <= '0';
                aluop     <= "00";
                memwrite  <= '0';
                alusrc    <= '1';
                regwrite  <= '1';
                is_auipc  <= '0';
                is_lui    <= '0';
                jump      <= '1';
                is_mem_op <= '0';
                
            when others =>
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