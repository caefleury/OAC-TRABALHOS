library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

entity mux2 is
    generic (
        SIZE : natural := WORD_SIZE);
    port (
        A, B    : in std_logic_vector(SIZE - 1 downto 0);
        sel	: in std_logic;
        m_out   : out std_logic_vector(SIZE - 1 downto 0));
end mux2;

architecture rt1 of mux2 is
begin
    m_out <= A when sel = '0' else B;
end architecture rt1;
