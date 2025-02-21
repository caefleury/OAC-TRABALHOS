library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity pc is
    generic (
        SIZE : natural := WORD_SIZE);
    port (
        clk	: in std_logic;
        wren	: in std_logic;
        rst	: in std_logic;
        d_in	: in std_logic_vector(SIZE - 1 downto 0) := (others => '0');
        d_out	: out std_logic_vector(SIZE - 1 downto 0) := (others => '0'));
end pc;

architecture behavioral of pc is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                d_out <= (others => '0');
            elsif wren = '1' then
                d_out <= d_in;
            end if;
        end if;
    end process;
end architecture behavioral;