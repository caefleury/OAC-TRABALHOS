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
        funct3   : in  std_logic_vector(2 downto 0);  
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)   
    );
end entity;

architecture rtl of memoria_dados is
    type mem_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    impure function init_ram_hex return mem_type is
        file mem_file : text open read_mode is "C:/Users/caefl/Documents/OAC-TRABALHOS-master/OAC-TRABALHOS-master/trabalho_final/temp/memoria_dados.txt";
        -- Variáveis para leitura do arquivo
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
                -- preenche o resto da memória com zeros
                ram_content(i) := (others => '0');  
            end if;
        end loop;
        return ram_content;
    end function;

    -- inicializa memória
    signal mem : mem_type := init_ram_hex;
    
begin
    process(clk)
        variable word_addr : integer;
    begin
        if rising_edge(clk) then
            -- verifica se os sinais de entrada são válidos antes de realizar a escrita
            if write_en = '1' and not (is_x(addr) or is_x(data_in)) then
                -- converte o endereço para inteiro
                word_addr := to_integer(unsigned(addr(11 downto 0)));  
                -- escrita na memória
                mem(word_addr) <= data_in;
            end if;
        end if;
    end process;

    process(addr, mem)
        variable word_addr : integer;
    begin
        -- iInicializa a saída com zeros para evitar metavalues dos erros do modelsim
        data_out <= (others => '0');
        
        -- verifica se o endereço é válido 
        if not is_x(addr) then
            word_addr := to_integer(unsigned(addr(11 downto 0)));  
            data_out <= mem(word_addr);
        end if;
    end process;
    
end architecture;