library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity somador is
    port (
        entrada_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        entrada_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        saida    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of somador is
begin
    -- Simple 32-bit adder for address calculations
    saida <= std_logic_vector(unsigned(entrada_a) + unsigned(entrada_b));
    
end architecture;