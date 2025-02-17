library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package riscv_pkg is
    -- Constants for memory addressing
    constant ADDR_WIDTH : integer := 12;  -- 12-bit addressing for RARS compatibility
    constant DATA_WIDTH : integer := 32;  -- 32-bit data width
    constant REG_WIDTH  : integer := 5;   -- 5 bits for register addressing (32 registers)
    
    -- Memory segments (RARS compatibility)
    constant TEXT_SEGMENT_START : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"000";  -- Code segment starts at 0x000
    constant DATA_SEGMENT_START : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"200";  -- Data segment starts at 0x2000
    
    -- RISC-V Opcodes
    constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";
    constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111";
    constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";
    constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";
    constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";
    constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OP_OPIMM  : std_logic_vector(6 downto 0) := "0010011";
    constant OP_OP     : std_logic_vector(6 downto 0) := "0110011";
    
    -- Memory access types
    type byte_enable_type is array(3 downto 0) of std_logic;
    
    -- ALU Operations
    type alu_op_type is (
        ALU_ADD,    -- Addition
        ALU_SUB,    -- Subtraction
        ALU_AND,    -- Logical AND
        ALU_OR,     -- Logical OR
        ALU_XOR,    -- Logical XOR
        ALU_SLL,    -- Shift Left Logical
        ALU_SRL,    -- Shift Right Logical
        ALU_SRA,    -- Shift Right Arithmetic
        ALU_SLT,    -- Set Less Than
        ALU_SLTU    -- Set Less Than Unsigned
    );
    
    -- Instruction Types
    type instr_type is (
        R_TYPE,     -- Register-Register operations
        I_TYPE,     -- Immediate operations
        S_TYPE,     -- Store operations
        B_TYPE,     -- Branch operations
        U_TYPE,     -- Upper immediate operations
        J_TYPE      -- Jump operations
    );
    
    -- Control signals
    type control_type is record
        branch      : std_logic;
        memread     : std_logic;
        memtoreg    : std_logic;
        aluop      : std_logic_vector(1 downto 0);
        memwrite   : std_logic;
        alusrc     : std_logic;
        regwrite   : std_logic;
    end record;
    
    -- Function declarations
    function to_alu_op(aluop : std_logic_vector(3 downto 0)) return alu_op_type;
    
    -- Component declarations
    component ula is
        port (
            A, B     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            op       : in  alu_op_type;
            result   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            zero     : out std_logic
        );
    end component;
    
    component banco_xregs is
        port (
            clk, wren : in std_logic;
            rs1, rs2  : in std_logic_vector(REG_WIDTH-1 downto 0);
            rd        : in std_logic_vector(REG_WIDTH-1 downto 0);
            data      : in std_logic_vector(DATA_WIDTH-1 downto 0);
            ro1, ro2  : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component somador_pc is
        port (
            entrada : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            saida   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            offset  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            sel     : in  std_logic
        );
    end component;

    component somador is
        port (
            entrada_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            entrada_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            saida    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component mux_2 is
        port (
            sel       : in  std_logic;
            entrada_0 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            entrada_1 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            saida     : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component gerador_imediato is
        port (
            instr : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            imm   : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component memoria_instrucoes is
        port (
            addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component memoria_dados is
        port (
            clk      : in  std_logic;
            addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            write_en : in  std_logic;
            byte_en  : in  std_logic;  -- '1' for byte operations, '0' for word
            data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
end package riscv_pkg;

package body riscv_pkg is
    function to_alu_op(aluop : std_logic_vector(3 downto 0)) return alu_op_type is
    begin
        case aluop is
            when "0000" => return ALU_ADD;
            when "0001" => return ALU_SUB;
            when "0010" => return ALU_AND;
            when "0011" => return ALU_OR;
            when "0100" => return ALU_XOR;
            when "0101" => return ALU_SLL;
            when "0110" => return ALU_SRL;
            when "0111" => return ALU_SRA;
            when "1000" => return ALU_SLT;
            when "1001" => return ALU_SLTU;
            when others => return ALU_ADD;  -- Default case
        end case;
    end function;
end package body;
