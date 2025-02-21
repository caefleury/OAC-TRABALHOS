library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity somador is
    generic (
        SIZE : natural := WORD_SIZE);
    port (
        A, B   : in std_logic_vector (SIZE - 1 downto 0);
        sum : out std_logic_vector (SIZE - 1 downto 0));
end somador;

architecture rt1 of somador is
begin
    sum <= std_logic_vector(signed(A) + signed(B));
end architecture rt1;

