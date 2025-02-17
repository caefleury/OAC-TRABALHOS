library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity testbench is
end entity;

architecture tb of testbench is
    -- Component declaration
    component riscv_processor is
        generic (
            WSIZE : natural := 32
        );
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            debug_pc    : out std_logic_vector(31 downto 0);
            debug_inst  : out std_logic_vector(31 downto 0);
            debug_reg_write : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Clock period definitions
    constant PERIOD     : time := 10 ns;
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET     : time := 5 ns;
    
    -- Testbench signals
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal stop_clock : boolean := false;
    
    -- Debug signals
    signal debug_pc : std_logic_vector(31 downto 0);
    signal debug_inst : std_logic_vector(31 downto 0);
    signal debug_reg_write : std_logic_vector(31 downto 0);
    
    -- Test status
    signal test_status : boolean := true;
    
begin
    -- Instantiate the processor
    UUT: riscv_processor
        generic map (
            WSIZE => 32
        )
        port map (
            clk => clk,
            rst => rst,
            debug_pc => debug_pc,
            debug_inst => debug_inst,
            debug_reg_write => debug_reg_write
        );
    
    -- Clock generation
    clock_gen: process
    begin
        while not stop_clock loop
            wait for (PERIOD - (PERIOD * DUTY_CYCLE));
            clk <= not clk;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stimulus: process
        -- Helper procedures
        procedure print_status(
            constant test_name : in string;
            constant success : in boolean
        ) is
            variable l : line;
        begin
            write(l, test_name & ": ");
            if success then
                write(l, "PASS");
            else
                write(l, "FAIL");
                test_status <= false;
            end if;
            writeline(output, l);
        end procedure;
        
        procedure check_instruction(
            constant expected_inst : in std_logic_vector(31 downto 0);
            constant test_name : in string
        ) is
        begin
            wait until rising_edge(clk);
            wait for 1 ns; -- Allow for signal propagation
            print_status(test_name, debug_inst = expected_inst);
        end procedure;
        
    begin
        -- Print test header
        report "Starting RISC-V Processor Tests";
        
        -- Reset test
        rst <= '1';
        wait for PERIOD*2;
        rst <= '0';
        
        -- Test 1: Check if PC starts at 0 after reset
        print_status("PC Reset Test", debug_pc = x"00000000");
        
        -- Test 2: Check first instruction (addi x2, x0, 5)
        check_instruction(x"00500113", "First Instruction Test");
        
        -- Test 3: Check second instruction (addi x3, x0, 3)
        check_instruction(x"00300193", "Second Instruction Test");
        
        -- Test 4: Check add instruction (add x3, x1, x2)
        check_instruction(x"002081b3", "ADD Instruction Test");
        
        -- Test 5: Check store instruction (sw x3, 4(x0))
        check_instruction(x"00302223", "Store Instruction Test");
        
        -- Test 6: Check load instruction (lw x6, 1(x0))
        check_instruction(x"00102303", "Load Instruction Test");

        -- Test 7: Check immediate for logical ops
        check_instruction(x"00800293", "ADDI for Logical Test");

        -- Test 8: Check AND instruction
        check_instruction(x"0062f333", "AND Instruction Test");

        -- Test 9: Check OR instruction
        check_instruction(x"0062e3b3", "OR Instruction Test");

        -- Test 10: Check XOR instruction
        check_instruction(x"0063c433", "XOR Instruction Test");

        -- Test 11: Check SLTI instruction
        check_instruction(x"0032a513", "SLTI Instruction Test");

        -- Test 12: Check SB instruction
        check_instruction(x"00408023", "Store Byte Instruction Test");

        -- Test 13: Check LB instruction
        check_instruction(x"00008283", "Load Byte Instruction Test");
        
        -- Test 14: Check ALU instruction (sub x2, x3, x4)
        check_instruction(x"40418133", "SUB Instruction Test");
        
        -- Test 15: Check comparison instruction (slt x4, x3, x4)
        check_instruction(x"0041a233", "SLT Instruction Test");
        
        -- Test 16: Check branch instruction (bne x1, x2, -4)
        check_instruction(x"fe209ee3", "Branch Instruction Test");
        
        -- Allow some cycles for execution
        wait for PERIOD*10;
        
        -- End simulation
        stop_clock <= true;
        
        -- Print final status
        if test_status then
            report "All tests passed successfully!";
        else
            report "Some tests failed! Check the output log.";
        end if;
        
        wait;
    end process;
    
end architecture;