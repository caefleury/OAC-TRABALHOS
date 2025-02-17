library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_tb is
end program_counter_tb;

architecture behavioral of program_counter_tb is
    -- Component declaration
    component program_counter is
        port (
            clk     : in std_logic;
            rst     : in std_logic;
            pc_next : in std_logic_vector(31 downto 0);
            pc_out  : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signal declarations
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal pc_next : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_out  : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: program_counter
        port map (
            clk     => clk,
            rst     => rst,
            pc_next => pc_next,
            pc_out  => pc_out
        );
    
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        rst <= '1';
        wait for 100 ns;
        
        -- Release reset
        rst <= '0';
        wait for CLK_PERIOD;
        
        -- Test normal operation
        -- Test case 1: Increment PC by 4
        pc_next <= x"00000004";
        wait for CLK_PERIOD;
        assert pc_out = x"00000004" 
            report "Test case 1 failed: PC not incremented correctly"
            severity error;
            
        -- Test case 2: Jump to address
        pc_next <= x"00000100";
        wait for CLK_PERIOD;
        assert pc_out = x"00000100"
            report "Test case 2 failed: PC not jumping correctly"
            severity error;
            
        -- Test case 3: Test reset during operation
        pc_next <= x"00000200";
        wait for CLK_PERIOD/2;
        rst <= '1';
        wait for CLK_PERIOD;
        assert pc_out = x"00000000"
            report "Test case 3 failed: Reset not working during operation"
            severity error;
            
        -- End simulation
        wait for CLK_PERIOD;
        report "Test completed successfully";
        wait;
    end process;
    
end behavioral;