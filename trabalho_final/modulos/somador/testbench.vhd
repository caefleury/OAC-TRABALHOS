library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity testbench is
end entity;

architecture tb of testbench is
    -- Component declaration
    component somador is
        port (
            entrada_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            entrada_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            saida    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    -- Test signals
    signal entrada_a : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal entrada_b : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saida    : std_logic_vector(DATA_WIDTH-1 downto 0);
    
begin
    -- Instantiate the somador
    UUT: somador
        port map (
            entrada_a => entrada_a,
            entrada_b => entrada_b,
            saida    => saida
        );
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: 5 + 3
        entrada_a <= x"00000005";
        entrada_b <= x"00000003";
        wait for 10 ns;
        assert saida = x"00000008" report "Test 1 failed: 5 + 3 = 8" severity error;
        
        -- Test case 2: 10 + 20
        entrada_a <= x"0000000A";
        entrada_b <= x"00000014";
        wait for 10 ns;
        assert saida = x"0000001E" report "Test 2 failed: 10 + 20 = 30" severity error;
        
        -- Test case 3: Max value + 1 (overflow test)
        entrada_a <= x"FFFFFFFF";
        entrada_b <= x"00000001";
        wait for 10 ns;
        assert saida = x"00000000" report "Test 3 failed: overflow test" severity error;
        
        -- End simulation
        wait for 10 ns;
        report "All tests completed";
        wait;
    end process;
    
end architecture;