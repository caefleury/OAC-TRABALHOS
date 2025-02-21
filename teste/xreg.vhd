library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity xreg is
    generic (
        SIZE : natural := WORD_SIZE;
        ADDR : natural := BREG_INDEX
    );
    port (
        clk, wren  : in std_logic;
        rs1, rs2, rd    : in std_logic_vector(ADDR-1 downto 0);
        data_in         : in std_logic_vector(SIZE-1 downto 0);
        A, B            : out std_logic_vector(SIZE-1 downto 0));
end xreg;

architecture behavioral of xreg is
    type memory is array (0 to (2**ADDR) - 1) of std_logic_vector (SIZE-1 downto 0);
    signal xreg : memory := (others => (others => '0'));
begin
    A <=  xreg(to_integer(unsigned(rs1)));
    B <=  xreg(to_integer(unsigned(rs2)));

    process(clk)
    begin
        if rising_edge(clk) then
            if ((wren = '1') and (to_integer(unsigned(rd)) /= 0)) then
                xreg(to_integer(unsigned(rd))) <= data_in;
            end if;
        end if;
    end process;
end architecture behavioral;

