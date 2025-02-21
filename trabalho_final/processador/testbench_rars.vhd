library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity testbench_rars is
end testbench_rars;

architecture tb of testbench_rars is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal instruction : std_logic_vector(31 downto 0);
    signal pc : std_logic_vector(31 downto 0);
    

    signal debug_reg_write : std_logic_vector(31 downto 0);
    signal debug_alu_result : std_logic_vector(31 downto 0);
    signal debug_alu_op : std_logic_vector(3 downto 0);
    signal debug_mem_addr : std_logic_vector(31 downto 0);
    signal debug_mem_data : std_logic_vector(31 downto 0);
    signal debug_mem_we : std_logic;
    signal debug_branch_taken : std_logic;
    signal debug_reg_write_addr : std_logic_vector(4 downto 0);
    signal debug_branch : std_logic;
    signal debug_memread : std_logic;
    signal debug_memtoreg : std_logic;
    signal debug_aluop : std_logic_vector(1 downto 0);
    signal debug_memwrite : std_logic;
    signal debug_alusrc : std_logic;
    signal debug_regwrite : std_logic;
    signal debug_jump : std_logic;
    signal debug_alu_result_ext : std_logic_vector(31 downto 0);
    signal debug_mem_rdata : std_logic_vector(31 downto 0);
    signal debug_mem_wdata : std_logic_vector(31 downto 0);
    signal debug_next_pc : std_logic_vector(31 downto 0);
    signal debug_rs1_data : std_logic_vector(31 downto 0);
    signal debug_rs2_data : std_logic_vector(31 downto 0);
    signal debug_imm_value : std_logic_vector(31 downto 0);
    

    type rom_type is array (0 to 14) of std_logic_vector(31 downto 0);
    signal rom : rom_type := (
        X"00500313",  -- addi t1, zero, 5
        X"00c00393",  -- addi t2, zero, 12
        X"00c00e13",  -- addi t3, zero, 12
        X"ffc00f93",  -- addi t6, zero, -4
        X"00730533",  -- add a0, t1, t2
        X"407e05b3",  -- sub a1, t3, t2
        X"01c39263",  -- bne t2, t3, test_function
        X"00400293",  -- addi t0, zero, 4
        X"0fc10417",  -- auipc s0, 0xfc1
        X"fe040413",  -- addi s0, s0, -32
        X"00642023",  -- sw t1, 0(s0)
        X"00742223",  -- sw t2, 4(s0)
        X"00042f03",  -- lw t5, 0(s0)
        X"00af0f13",  -- addi t5, t5, 10
        X"01e42223"   -- sw t5, 4(s0)
    );
    
    component riscv_processor is
        generic (
            WSIZE : natural := 32
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            debug_pc : out std_logic_vector(WSIZE-1 downto 0);
            debug_inst : out std_logic_vector(WSIZE-1 downto 0);
            debug_reg_write : out std_logic_vector(WSIZE-1 downto 0);
            debug_alu_result : out std_logic_vector(WSIZE-1 downto 0);
            debug_alu_op : out std_logic_vector(3 downto 0);
            debug_mem_addr : out std_logic_vector(WSIZE-1 downto 0);
            debug_mem_data : out std_logic_vector(WSIZE-1 downto 0);
            debug_mem_we : out std_logic;
            debug_branch_taken : out std_logic;
            debug_reg_write_addr : out std_logic_vector(4 downto 0);
            debug_branch : out std_logic;
            debug_memread : out std_logic;
            debug_memtoreg : out std_logic;
            debug_aluop : out std_logic_vector(1 downto 0);
            debug_memwrite : out std_logic;
            debug_alusrc : out std_logic;
            debug_regwrite : out std_logic;
            debug_jump : out std_logic;
            debug_alu_result_ext : out std_logic_vector(WSIZE-1 downto 0);
            debug_mem_rdata : out std_logic_vector(WSIZE-1 downto 0);
            debug_mem_wdata : out std_logic_vector(WSIZE-1 downto 0);
            debug_next_pc : out std_logic_vector(WSIZE-1 downto 0);
            debug_rs1_data : out std_logic_vector(WSIZE-1 downto 0);
            debug_rs2_data : out std_logic_vector(WSIZE-1 downto 0);
            debug_imm_value : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

begin
    processor: riscv_processor 
        generic map (
            WSIZE => 32
        )
        port map (
            clk => clk,
            rst => rst,
            debug_pc => pc,
            debug_inst => instruction,
            debug_reg_write => debug_reg_write,
            debug_alu_result => debug_alu_result,
            debug_alu_op => debug_alu_op,
            debug_mem_addr => debug_mem_addr,
            debug_mem_data => debug_mem_data,
            debug_mem_we => debug_mem_we,
            debug_branch_taken => debug_branch_taken,
            debug_reg_write_addr => debug_reg_write_addr,
            debug_branch => debug_branch,
            debug_memread => debug_memread,
            debug_memtoreg => debug_memtoreg,
            debug_aluop => debug_aluop,
            debug_memwrite => debug_memwrite,
            debug_alusrc => debug_alusrc,
            debug_regwrite => debug_regwrite,
            debug_jump => debug_jump,
            debug_alu_result_ext => debug_alu_result_ext,
            debug_mem_rdata => debug_mem_rdata,
            debug_mem_wdata => debug_mem_wdata,
            debug_next_pc => debug_next_pc,
            debug_rs1_data => debug_rs1_data,
            debug_rs2_data => debug_rs2_data,
            debug_imm_value => debug_imm_value
        );

    process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    process
    begin
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        
        for i in 0 to 14 loop
            instruction <= rom(i);
            wait for 10 ns;
        end loop;
        
        instruction <= rom(14);
        wait for 10 ns;
        
        wait for 50 ns;
        assert false report "Simulação concluída" severity failure;
    end process;

end tb;
