library ieee;
use ieee.std_logic_1164.all;

entity controle is
    port (
        -- Input ports
        opcode      : in  std_logic_vector(6 downto 0);
        funct3      : in  std_logic_vector(2 downto 0);
        funct7      : in  std_logic_vector(6 downto 0);
        
        -- Output ports
        branch      : out std_logic;
        memRead     : out std_logic;
        memtoReg    : out std_logic;
        aluOp       : out std_logic_vector(1 downto 0);
        memWrite    : out std_logic;
        aluSrc      : out std_logic;
        regWrite    : out std_logic;
        jump        : out std_logic;
        auipc       : out std_logic
    );
end controle;

architecture behavioral of controle is
    -- Constants for opcodes
    constant OPCODE_R     : std_logic_vector(6 downto 0) := "0110011"; -- R-type
    constant OPCODE_I     : std_logic_vector(6 downto 0) := "0010011"; -- I-type ALU
    constant OPCODE_LOAD  : std_logic_vector(6 downto 0) := "0000011"; -- Load
    constant OPCODE_STORE : std_logic_vector(6 downto 0) := "0100011"; -- Store
    constant OPCODE_BRANCH: std_logic_vector(6 downto 0) := "1100011"; -- Branch
    constant OPCODE_LUI   : std_logic_vector(6 downto 0) := "0110111"; -- LUI
    constant OPCODE_AUIPC : std_logic_vector(6 downto 0) := "0010111"; -- AUIPC
    constant OPCODE_JAL   : std_logic_vector(6 downto 0) := "1101111"; -- JAL
    constant OPCODE_JALR  : std_logic_vector(6 downto 0) := "1100111"; -- JALR

begin
    process(opcode, funct3, funct7)
    begin
        -- Default values
        branch   <= '0';
        memRead  <= '0';
        memtoReg <= '0';
        aluOp    <= "00";
        memWrite <= '0';
        aluSrc   <= '0';
        regWrite <= '0';
        jump     <= '0';
        auipc    <= '0';
        
        case opcode is
            when OPCODE_R =>
                regWrite <= '1';
                aluOp    <= "10";
                
            when OPCODE_I =>
                regWrite <= '1';
                aluSrc   <= '1';
                aluOp    <= "11";
                
            when OPCODE_LOAD =>
                memRead  <= '1';
                regWrite <= '1';
                aluSrc   <= '1';
                memtoReg <= '1';
                
            when OPCODE_STORE =>
                memWrite <= '1';
                aluSrc   <= '1';
                
            when OPCODE_BRANCH =>
                branch   <= '1';
                aluOp    <= "01";
                
            when OPCODE_LUI =>
                regWrite <= '1';
                aluSrc   <= '1';
                aluOp    <= "00";
                
            when OPCODE_AUIPC =>
                regWrite <= '1';
                aluSrc   <= '1';
                auipc    <= '1';
                
            when OPCODE_JAL | OPCODE_JALR =>
                jump     <= '1';
                regWrite <= '1';
                
            when others =>
                null;
        end case;
    end process;
end behavioral;