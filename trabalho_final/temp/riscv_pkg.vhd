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
    
    
    function to_alu_op(aluop : std_logic_vector(3 downto 0)) return alu_op_type;
    
    
    component ula is
        generic (
            WSIZE : natural
        );
        port (
            opcode : in std_logic_vector(3 downto 0);
            A, B : in std_logic_vector(DATA_WIDTH-1 downto 0);
            Z : out std_logic_vector(DATA_WIDTH-1 downto 0);
            zero : out std_logic;
            is_mem_op : in std_logic  
        );
    end component;

    component XREGS is
        generic (
            WSIZE : natural := 32
        );
        port (
            clk  : in  std_logic;
            rst  : in  std_logic;
            wren : in  std_logic;
            rd   : in  std_logic_vector(4 downto 0);
            rs1, rs2: in  std_logic_vector(4 downto 0);
            data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            ro1, ro2: out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component somador_pc is
        generic (
            WSIZE : natural := 32
        );
        port (
            entrada : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            saida   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            offset  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            sel     : in  std_logic;
            rst     : in  std_logic
        );
    end component;

    component somador is
        generic (
            WSIZE : natural := 32
        );
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
            addr     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            write_en : in  std_logic;
            funct3   : in  std_logic_vector(2 downto 0);
            data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component controle is
    port (
        -- Instruction input
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic_vector(6 downto 0);
        
        -- Control outputs
        branch : out std_logic;
        memread : out std_logic;
        memtoreg : out std_logic;
        aluop : out std_logic_vector(1 downto 0);
        memwrite : out std_logic;
        alusrc : out std_logic;
        regwrite : out std_logic;
        
        -- Additional control signals
        is_auipc : out std_logic;
        is_lui : out std_logic;
        jump : out std_logic;
        is_mem_op : out std_logic
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
