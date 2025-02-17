library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

entity mux3 is
    generic (
        SIZE : natural := WORD_SIZE);
    port (
        A,B,C   : in std_logic_vector(SIZE - 1 downto 0);
        sel	: in std_logic_vector(1 downto 0);
        m_out	: out std_logic_vector(SIZE - 1 downto 0));
end mux3;

architecture rt1 of mux3 is
begin
    m_out <= A when sel = "00" else
             B when sel = "01" else
             C;
end architecture rt1;
