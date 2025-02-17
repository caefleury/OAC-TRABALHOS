library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        pc_next : in std_logic_vector(31 downto 0);
        pc_out  : out std_logic_vector(31 downto 0)
    );
end program_counter;

architecture behavioral of program_counter is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_out <= (others => '0'); -- Reset PC to 0
            else
                pc_out <= pc_next; -- Update PC with next address
            end if;
        end if;
    end process;
end behavioral;