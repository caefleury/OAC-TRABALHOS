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
    
    -- Function to initialize memory from file
    impure function init_ram_hex return mem_type is
        file mem_file : text open read_mode is "C:/Users/caefl/Documents/OAC-TRABALHOS-master/OAC-TRABALHOS-master/trabalho_final/temp/memoria_dados.txt";
        variable line_content : line;
        variable temp_data : std_logic_vector(31 downto 0);
        variable ram_content : mem_type;
    begin
        for i in 0 to 2**ADDR_WIDTH-1 loop
            if not endfile(mem_file) then
                readline(mem_file, line_content);
                if line_content.all'length > 0 then
                    hread(line_content, temp_data);
                    ram_content(i) := temp_data;
                end if;
            else
                ram_content(i) := (others => '0');
            end if;
        end loop;
        return ram_content;
    end function;

    -- Initialize memory using the function
    signal mem : mem_type := init_ram_hex;
    
begin
    -- Write process (synchronous)
    process(clk)
        variable word_addr : integer;
    begin
        if rising_edge(clk) then
            -- Check for valid inputs before performing memory operations
            if write_en = '1' and not (is_x(addr) or is_x(data_in)) then
                word_addr := to_integer(unsigned(addr(11 downto 0)));  -- Use only lower 12 bits
                mem(word_addr) <= data_in;
            end if;
        end if;
    end process;

    -- Read process (asynchronous)
    process(addr, mem)
        variable word_addr : integer;
    begin
        -- Initialize output to prevent metavalues
        data_out <= (others => '0');
        
        -- Check for valid address before reading
        if not is_x(addr) then
            word_addr := to_integer(unsigned(addr(11 downto 0)));  -- Use only lower 12 bits
            data_out <= mem(word_addr);
        end if;
    end process;
    
end architecture;