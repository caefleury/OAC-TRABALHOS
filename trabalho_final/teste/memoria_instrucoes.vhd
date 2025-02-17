library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.riscv_pkg.all;

entity memoria_instrucoes is
    generic (
        SIZE  : natural := WORD_SIZE;
        WADDR : natural := MEM_ADDR);
    port (
        address : in std_logic_vector (WADDR - 1 downto 0);
        q       : out std_logic_vector(SIZE - 1 downto 0));
end entity memoria_instrucoes;

architecture RTL of memoria_instrucoes is
    type rom_type is array (0 to (2**address'length) - 1) of std_logic_vector(q'range);

    impure function init_rom_hex return rom_type is
        file text_file : text open read_mode is "instruction_memory.txt";
        variable text_line : line;
        variable rom_content : rom_type := (others => (others => '0'));
        begin
        for i in 0 to (2**address'length) - 1 loop
            if (not endfile(text_file)) then
                readline(text_file, text_line);
                rom_content(i) := std_logic_vector(to_unsigned(to_integer(unsigned'("X" & text_line.all)), SIZE));
            end if;
        end loop;
        return rom_content;
    end function;

    signal rom : rom_type := init_rom_hex;

begin
    process(address)
    begin
        Q <= rom(to_integer(unsigned(address)));
    end process;
end architecture RTL;


