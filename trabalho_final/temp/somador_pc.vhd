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
        sel     : in  std_logic  -- 0 for PC+4, 1 for PC+offset
    );
end somador_pc;

architecture behavioral of somador_pc is
begin
    process(entrada, offset, sel)
    begin
        if sel = '0' then
            -- Normal PC increment by 4
            saida <= std_logic_vector(unsigned(entrada) + 4);
        else
            -- Branch/Jump offset addition
            saida <= std_logic_vector(unsigned(entrada) + unsigned(offset));
        end if;
    end process;
end behavioral;