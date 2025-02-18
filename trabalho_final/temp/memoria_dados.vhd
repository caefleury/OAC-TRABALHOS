library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.riscv_pkg.all;

entity memoria_dados is
    port (
        clk      : in  std_logic;
        addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        write_en : in  std_logic;
        funct3   : in  std_logic_vector(2 downto 0);  -- Add funct3 for load/store type
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of memoria_dados is
    type mem_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : mem_type := (others => (others => '0'));
    
begin
    -- Process to initialize memory from file
    process
        file mem_file : text;
        variable line_content : line;
        variable temp_data : std_logic_vector(31 downto 0);
        variable word_addr : integer := 0;
    begin
        -- Initialize memory from file
        file_open(mem_file, "C:/Users/caefl/Documents/OAC-TRABALHOS-master/OAC-TRABALHOS-master/trabalho_final/temp/memoria_dados.txt", read_mode);
        
        while not endfile(mem_file) loop
            readline(mem_file, line_content);
            if line_content.all'length > 0 then
                hread(line_content, temp_data);  -- Read hex value
                mem(word_addr) <= temp_data;
                word_addr := word_addr + 1;
            end if;
        end loop;
        
        file_close(mem_file);
        wait;
    end process;
    
    -- Write process (synchronous)
    process(clk)
        variable word_addr : integer;
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                word_addr := to_integer(unsigned(addr));
                mem(word_addr) <= data_in;
            end if;
        end if;
    end process;
    
    -- Read process (combinational)
    process(addr, mem)
        variable word_addr : integer;
    begin
        word_addr := to_integer(unsigned(addr));
        data_out <= mem(word_addr);
    end process;
    
end architecture;