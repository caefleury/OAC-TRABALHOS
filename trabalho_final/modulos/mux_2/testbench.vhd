library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

entity testbench is
end entity;

architecture tb of testbench is
    -- Component declaration
    component mux_2 is
        generic (
            WSIZE : natural := 32
        );
        port (
            sel      : in  std_logic;
            entrada_0 : in  std_logic_vector(WSIZE-1 downto 0);
            entrada_1 : in  std_logic_vector(WSIZE-1 downto 0);
            saida     : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;
    
    -- Test signals
    signal sel      : std_logic := '0';
    signal entrada_0 : std_logic_vector(31 downto 0);
    signal entrada_1 : std_logic_vector(31 downto 0);
    signal saida     : std_logic_vector(31 downto 0);
    
begin
    -- Instantiate the mux_2
    UUT: mux_2
        generic map (
            WSIZE => 32
        )
        port map (
            sel      => sel,
            entrada_0 => entrada_0,
            entrada_1 => entrada_1,
            saida     => saida
        );
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: sel = 0
        entrada_0 <= x"AAAAAAAA";
        entrada_1 <= x"55555555";
        sel <= '0';
        wait for 10 ns;
        assert saida = x"AAAAAAAA" report "Test 1 failed: should select entrada_0" severity error;
        
        -- Test case 2: sel = 1
        sel <= '1';
        wait for 10 ns;
        assert saida = x"55555555" report "Test 2 failed: should select entrada_1" severity error;
        
        -- Test case 3: changing inputs
        entrada_0 <= x"11111111";
        entrada_1 <= x"22222222";
        sel <= '0';
        wait for 10 ns;
        assert saida = x"11111111" report "Test 3 failed: should select new entrada_0" severity error;
        
        -- End simulation
        wait for 10 ns;
        report "All tests completed";
        wait;
    end process;
    
end architecture;