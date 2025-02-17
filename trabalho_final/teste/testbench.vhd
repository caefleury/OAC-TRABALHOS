library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity testbench is
end entity testbench;

architecture tb_arch of testbench is

component riscv is
    port (
        clk	: in std_logic;
        rst	: in std_logic;
        data  	: out std_logic_vector(WORD_SIZE - 1 downto 0));
end component;

signal clock_in : std_logic;
signal rst : std_logic;
signal data_out : std_logic_vector(31 downto 0);

begin
    riscv_i: riscv port map(clock_in, rst, data_out);

    clkgen: process begin
        clock_in <= '1'; wait for 100 ns;
        clock_in <= '0'; wait for 100 ns;
    end process clkgen;

    drive: process begin
        rst <= '0';
   		wait;
   end process drive;
end architecture tb_arch;
