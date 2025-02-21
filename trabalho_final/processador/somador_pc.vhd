library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador_pc is
    generic (
        WSIZE : natural := 32
    );
    port (
        entrada : in  std_logic_vector(WSIZE-1 downto 0);
        saida   : out std_logic_vector(WSIZE-1 downto 0);
        offset  : in  std_logic_vector(WSIZE-1 downto 0);
        sel     : in  std_logic; 
        rst     : in  std_logic   
    );
end somador_pc;

architecture behavioral of somador_pc is
begin
    process(entrada, offset, sel, rst)
    begin
        if rst = '1' then
            saida <= (others => '0');
        elsif sel = '0' then
            saida <= std_logic_vector(unsigned(entrada) + 4);
        else
            saida <= std_logic_vector(unsigned(entrada) + unsigned(offset));
        end if;
    end process;
end behavioral;