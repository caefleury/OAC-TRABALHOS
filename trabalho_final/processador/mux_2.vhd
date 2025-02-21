library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

entity mux_2 is
    generic (
        WSIZE : natural := 32
    );
    port (
        sel     : in  std_logic;
        entrada_0 : in  std_logic_vector(WSIZE-1 downto 0);
        entrada_1 : in  std_logic_vector(WSIZE-1 downto 0);
        saida     : out std_logic_vector(WSIZE-1 downto 0)
    );
end entity;

architecture rtl of mux_2 is
begin
    saida <= entrada_0 when sel = '0' else entrada_1;
end architecture;
