library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity riscv_processor is
    generic (
        WSIZE : natural := 32
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;  -- Added reset signal
        -- Debug ports
        debug_pc    : out std_logic_vector(WSIZE-1 downto 0);
        debug_inst  : out std_logic_vector(WSIZE-1 downto 0);
        debug_reg_write : out std_logic_vector(WSIZE-1 downto 0);
        -- Additional debug ports
        debug_alu_result : out std_logic_vector(WSIZE-1 downto 0);
        debug_alu_op : out std_logic_vector(3 downto 0);
        debug_mem_addr : out std_logic_vector(WSIZE-1 downto 0);
        debug_mem_data : out std_logic_vector(WSIZE-1 downto 0);
        debug_mem_we : out std_logic;
        debug_branch_taken : out std_logic;
        debug_reg_write_addr : out std_logic_vector(4 downto 0)
    );
end riscv_processor;

architecture behavioral of riscv_processor is
    -- Component declarations
    component controle is
        port (
            opcode      : in  std_logic_vector(6 downto 0);
            funct3      : in  std_logic_vector(2 downto 0);
            funct7      : in  std_logic_vector(6 downto 0);
            branch      : out std_logic;
            memRead     : out std_logic;
            memtoReg    : out std_logic;
            aluOp       : out std_logic_vector(1 downto 0);
            memWrite    : out std_logic;
            aluSrc      : out std_logic;
            regWrite    : out std_logic;
            jump        : out std_logic;
            is_auipc    : out std_logic;
            is_mem_op   : out std_logic
        );
    end component;
    
    component XREGS is
        generic (WSIZE : natural := 32);
        port (
            clk  : in  std_logic;
            rst  : in  std_logic;
            wren : in  std_logic;
            rd   : in  std_logic_vector(4 downto 0);
            rs1, rs2: in  std_logic_vector(4 downto 0);
            data : in  std_logic_vector(WSIZE-1 downto 0);
            ro1, ro2: out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;
    
    component memoria_instrucoes is
        port (
            addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data     : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

    component memoria_dados is
        port (
            clk      : in  std_logic;
            addr     : in  std_logic_vector(WSIZE-1 downto 0);
            write_en : in  std_logic;
            funct3   : in  std_logic_vector(2 downto 0);
            data_in  : in  std_logic_vector(WSIZE-1 downto 0);
            data_out : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;
    
    component ula is
        generic (WSIZE : natural := 32);
        port (
            opcode : in  std_logic_vector(3 downto 0);
            A, B   : in  std_logic_vector(WSIZE-1 downto 0);
            Z      : out std_logic_vector(WSIZE-1 downto 0);
            zero   : out std_logic;
            is_mem_op : in std_logic
        );
    end component;
    
    component somador_pc is
        generic (WSIZE : natural := 32);
        port (
            entrada : in  std_logic_vector(WSIZE-1 downto 0);
            saida   : out std_logic_vector(WSIZE-1 downto 0);
            offset  : in  std_logic_vector(WSIZE-1 downto 0);
            sel     : in  std_logic;
            rst     : in  std_logic
        );
    end component;

    component somador is
        generic (
            WSIZE : natural := 32
        );
        port (
            entrada_a : in  std_logic_vector(WSIZE-1 downto 0);
            entrada_b : in  std_logic_vector(WSIZE-1 downto 0);
            saida    : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

    component mux_2 is
        generic (WSIZE : natural := 32);
        port (
            sel       : in  std_logic;
            entrada_0 : in  std_logic_vector(WSIZE-1 downto 0);
            entrada_1 : in  std_logic_vector(WSIZE-1 downto 0);
            saida     : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;
    
    -- Internal signals
    signal pc_current, pc_next : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal instruction : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal reg_write_data : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal rs1_data, rs2_data : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal alu_result : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal mem_read_data : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal immediate : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    
    -- Memory signals
    signal mem_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal mem_word_data : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    
    -- Adder signals
    signal pc_plus_4 : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal pc_plus_imm : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal addr_result : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    
    -- MUX signals
    signal alu_src_mux_out : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal mem_to_reg_mux_out : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal branch_mux_out : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal auipc_mux_out : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    
    -- Control signals
    signal branch, memRead, memtoReg, memWrite, aluSrc, regWrite, jump, is_auipc, is_mem_op : std_logic := '0';
    signal aluOp : std_logic_vector(1 downto 0) := "00";
    signal zero : std_logic := '0';
    signal branch_taken : std_logic := '0';
    signal alu_input_b : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal alu_opcode : std_logic_vector(3 downto 0) := "0000";
    
begin
    -- Calculate branch condition
    branch_taken <= branch and zero;
    
    -- Select ALU input B
    alu_input_b <= rs2_data when aluSrc = '0' else immediate;
    
    -- Calculate ALU opcode
    alu_opcode <= aluOp & instruction(14 downto 13);

    -- PC register
    process(clk, rst)
    begin
        if rst = '1' then
            pc_current <= (others => '0');  -- Reset PC to 0
        elsif rising_edge(clk) then
            pc_current <= pc_next;
        end if;
    end process;

    -- PC Adder (PC+4 or PC+imm)
    pc_adder: somador_pc
        generic map (WSIZE => WSIZE)
        port map (
            entrada => pc_current,
            saida   => pc_next,
            offset  => immediate,
            sel     => branch_taken,
            rst     => rst
        );

    -- Immediate Adder (for AUIPC and address calculations)
    imm_adder: somador
        generic map (WSIZE => WSIZE)
        port map (
            entrada_a => pc_current,
            entrada_b => immediate,
            saida    => addr_result
        );

    -- MUX for ALU source B selection
    alu_src_mux: mux_2
        generic map (WSIZE => WSIZE)
        port map (
            sel       => aluSrc,
            entrada_0 => rs2_data,
            entrada_1 => immediate,
            saida     => alu_src_mux_out
        );

    -- MUX for memory to register writeback
    mem_to_reg_mux: mux_2
        generic map (WSIZE => WSIZE)
        port map (
            sel       => memtoReg,
            entrada_0 => alu_result,
            entrada_1 => mem_read_data,
            saida     => mem_to_reg_mux_out
        );

    -- MUX for branch selection
    branch_mux: mux_2
        generic map (WSIZE => WSIZE)
        port map (
            sel       => branch_taken,
            entrada_0 => pc_plus_4,
            entrada_1 => pc_plus_imm,
            saida     => branch_mux_out
        );

    -- MUX for AUIPC selection
    auipc_mux: mux_2
        generic map (WSIZE => WSIZE)
        port map (
            sel       => is_auipc,
            entrada_0 => alu_result,
            entrada_1 => addr_result,
            saida     => auipc_mux_out
        );
    
    -- Instruction memory instantiation
    inst_mem: memoria_instrucoes
        port map (
            addr => pc_current(ADDR_WIDTH+1 downto 2),  -- Divide PC by 4 by dropping the 2 LSBs
            data => instruction
        );
    
    -- Immediate generator
    imm_gen: gerador_imediato
        port map (
            instr => instruction,
            imm   => immediate
        );

    -- Control unit
    ctrl: controle
        port map (
            opcode   => instruction(6 downto 0),
            funct3   => instruction(14 downto 12),
            funct7   => instruction(31 downto 25),
            branch   => branch,
            memRead  => memRead,
            memtoReg => memtoReg,
            aluOp    => aluOp,
            memWrite => memWrite,
            aluSrc   => aluSrc,
            regWrite => regWrite,
            jump     => jump,
            is_auipc => is_auipc,
            is_mem_op => is_mem_op
        );
    
    -- Register file
    regs: XREGS
        generic map (WSIZE => WSIZE)
        port map (
            clk  => clk,
            rst  => rst,
            wren => regWrite,
            rd   => instruction(11 downto 7),
            rs1  => instruction(19 downto 15),
            rs2  => instruction(24 downto 20),
            data => reg_write_data,
            ro1  => rs1_data,
            ro2  => rs2_data
        );
    
    -- ALU
    main_alu: ula
        generic map (WSIZE => WSIZE)
        port map (
            opcode => alu_opcode,
            A      => rs1_data,
            B      => alu_input_b,
            Z      => alu_result,
            zero   => zero,
            is_mem_op => is_mem_op
        );
    
    -- Data memory instantiation
    data_mem: memoria_dados
        port map (
            clk      => clk,
            addr     => alu_result(ADDR_WIDTH-1 downto 0),  -- Slice to match memory address width
            write_en => memWrite,
            funct3   => instruction(14 downto 12),  -- funct3 field from instruction
            data_in  => rs2_data,
            data_out => mem_read_data
        );
    
    -- Debug outputs
    debug_pc <= pc_current;
    debug_inst <= instruction;
    debug_reg_write <= reg_write_data;
    debug_alu_result <= alu_result;
    debug_alu_op <= alu_opcode;
    debug_mem_addr <= alu_result when memWrite = '1' or memRead = '1' else (others => '0');
    debug_mem_data <= rs2_data when memWrite = '1' else mem_read_data;
    debug_mem_we <= memWrite;
    debug_branch_taken <= branch_taken;
    debug_reg_write_addr <= instruction(11 downto 7);
    
end behavioral;