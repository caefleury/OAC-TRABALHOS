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
        file_open(mem_file, "memoria_dados.txt", read_mode);
        
        while not endfile(mem_file) loop
            readline(mem_file, line_content);
            if line_content.all'length > 0 then
                hread(line_content, temp_data);  -- Read hex value
                mem(word_addr) <= temp_data;
                word_addr := word_addr + 1;  -- Move to next word
            end if;
        end loop;
        
        file_close(mem_file);
        wait;
    end process;
    
    -- Write process (synchronous)
    process(clk)
        variable word_addr : integer;
        variable byte_offset : integer;
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                word_addr := to_integer(unsigned(addr)) / 4;  -- Endereço da word
                byte_offset := to_integer(unsigned(addr)) mod 4;  -- Offset do byte
                
                if byte_en = '1' then
                    -- Byte write
                    case byte_offset is
                        when 0 => mem(word_addr*4) <= data_in(7 downto 0);
                        when 1 => mem(word_addr*4 + 1) <= data_in(7 downto 0);
                        when 2 => mem(word_addr*4 + 2) <= data_in(7 downto 0);
                        when 3 => mem(word_addr*4 + 3) <= data_in(7 downto 0);
                        when others => null;
                    end case;
                else
                    -- Word write
                    mem(word_addr*4)   <= data_in(31 downto 24);
                    mem(word_addr*4+1) <= data_in(23 downto 16);
                    mem(word_addr*4+2) <= data_in(15 downto 8);
                    mem(word_addr*4+3) <= data_in(7 downto 0);
                end if;
            end if;
        end if;
    end process;
    
    -- Read process (combinational)
    process(addr, byte_en, mem)
        variable word_addr : integer;
        variable byte_offset : integer;
        variable byte_data : std_logic_vector(7 downto 0);
    begin
        word_addr := to_integer(unsigned(addr)) / 4;  -- Endereço da word
        byte_offset := to_integer(unsigned(addr)) mod 4;  -- Offset do byte
        
        if byte_en = '1' then
            -- Byte read
            case byte_offset is
                when 0 => byte_data := mem(word_addr*4);
                when 1 => byte_data := mem(word_addr*4 + 1);
                when 2 => byte_data := mem(word_addr*4 + 2);
                when 3 => byte_data := mem(word_addr*4 + 3);
                when others => byte_data := (others => '0');
            end case;
            data_out <= x"000000" & byte_data;
        else
            -- Word read
            data_out <= mem(word_addr*4) & mem(word_addr*4+1) & 
                       mem(word_addr*4+2) & mem(word_addr*4+3);
        end if;
    end process;
    
end architecture;