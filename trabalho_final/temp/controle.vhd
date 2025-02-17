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
        jump       : out std_logic   -- '1' para saltos
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
    
begin
    process(opcode, funct3, funct7)
    begin
        -- Default values
        branch    <= '0';
        memread   <= '0';
        memtoreg  <= '0';
        aluop     <= "00";
        memwrite  <= '0';
        alusrc    <= '0';
        regwrite  <= '0';
        is_auipc   <= '0';
        is_lui     <= '0';
        
        case opcode is
            when OP_LUI =>
                regwrite <= '1';
                alusrc   <= '1';
                is_lui   <= '1';
                
            when OP_AUIPC =>
                regwrite <= '1';
                alusrc   <= '1';
                is_auipc <= '1';
                
            when OP_REG =>
                regwrite <= '1';
                aluop    <= "10";
                
            when OP_IMM =>
                regwrite <= '1';
                alusrc   <= '1';
                aluop    <= "10";
                
            when OP_LOAD =>
                memread  <= '1';
                regwrite <= '1';
                alusrc   <= '1';
                memtoreg <= '1';
                is_byte_op <= funct3 = "000" or funct3 = "100";  -- LB/LBU
                
            when OP_STORE =>
                memwrite <= '1';
                alusrc   <= '1';
                is_byte_op <= funct3 = "000";  -- SB
                
            when OP_BRANCH =>
                branch   <= '1';
                aluop    <= "01";
                
            when others =>
                null;
        end case;
    end process;
    
end architecture;