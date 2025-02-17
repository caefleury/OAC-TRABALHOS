library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.riscv_pkg.all;

entity memoria_dados is
    generic (
        SIZE    : natural := WORD_SIZE;
        WADDR   : natural := MEM_ADDR);
    port (
        address	    : in std_logic_vector (WADDR - 1 downto 0);
        clk	    : in std_logic;
        data	    : in std_logic_vector (SIZE - 1 downto 0);
        wren	    : in std_logic;
        mem_read    : in std_logic;
        q		    : out std_logic_vector (SIZE - 1 downto 0) := (others => '0'));
end entity memoria_dados;

architecture RTL of memoria_dados is
    type data_mem_type is array (0 to (2**address'length) - 1) of std_logic_vector(data'range);

    impure function init_ram_hex return data_mem_type is
        file text_file : text open read_mode is "data_memory.txt";
        variable text_line : line;
        variable ram_content : data_mem_type := (others => (others => '0'));
        begin
        for i in 0 to (2**address'length) - 1 loop
            if (not endfile(text_file)) then
                readline(text_file, text_line);
                ram_content(i) := std_logic_vector(to_unsigned(to_integer(unsigned'("X" & text_line.all)), SIZE));
            end if;
        end loop;
        return ram_content;
    end function;

    signal mem : data_mem_type := init_ram_hex;

begin
    q <= mem(to_integer(unsigned(address))) when mem_read = '1' else (others => '0');
    process(clk)
    begin
        if rising_edge(clk) then
            if wren = '1' then 
                mem(to_integer(unsigned(address))) <= data;
            end if;
        end if;
    end process;
end architecture RTL;


