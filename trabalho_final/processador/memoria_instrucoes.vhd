library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.riscv_pkg.all;


entity memoria_instrucoes is
    port (
        addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of memoria_instrucoes is
    type mem_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    impure function init_rom_hex return mem_type is
        file mem_file : text open read_mode is "C:/Users/caefl/Documents/OAC-TRABALHOS-master/OAC-TRABALHOS-master/trabalho_final/temp/memoria_instrucoes.txt";

        -- variáveis de leitura
        variable line_content : line;
        variable temp_data : std_logic_vector(DATA_WIDTH-1 downto 0);
        variable rom_content : mem_type;
    begin
        for i in 0 to 2**ADDR_WIDTH-1 loop
            if not endfile(mem_file) then
                readline(mem_file, line_content);
                -- ignora linhas null
                if line_content.all'length > 0 then
                    hread(line_content, temp_data);
                    rom_content(i) := temp_data;
                end if;
            else
                -- preenche o restante da memória com zeros
                rom_content(i) := (others => '0');
            end if;
        end loop;
        
        return rom_content;
    end function;
    
    signal mem : mem_type := init_rom_hex;
    
begin    

    data <= mem(to_integer(unsigned(addr)));
    
end architecture;