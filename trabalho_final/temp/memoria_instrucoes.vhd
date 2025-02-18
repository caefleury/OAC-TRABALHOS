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
    signal mem : mem_type := (others => (others => '0'));
    
begin
    -- Process to initialize memory from file
    process
        file mem_file : text;
        variable line_content : line;
        variable temp_data : std_logic_vector(DATA_WIDTH-1 downto 0);
        variable word_addr : integer := 0;
    begin
        -- Initialize memory from file
        file_open(mem_file, "C:/Users/caefl/Documents/OAC-TRABALHOS/trabalho_final/temp/memoria_instrucoes.txt", read_mode);
        
        while not endfile(mem_file) loop
            readline(mem_file, line_content);
            if line_content.all'length > 0 then
                hread(line_content, temp_data);  -- Read hex value
                mem(word_addr) <= temp_data;    -- Store instruction
                word_addr := word_addr + 1;     -- Move to next instruction
            end if;
        end loop;
        
        file_close(mem_file);
        wait;
    end process;
    
    -- Asynchronous read (combinational)
    data <= mem(to_integer(unsigned(addr)));
    
end architecture;