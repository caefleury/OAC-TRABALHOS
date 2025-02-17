library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity design is
    port (
        clk          : in  std_logic;
        write_enable : in  std_logic;
        byte_enable  : in  std_logic;
        sign_enable  : in  std_logic;
        mem_address  : in  std_logic_vector(12 downto 0);
        data_input   : in  std_logic_vector(31 downto 0);
        data_output  : out std_logic_vector(31 downto 0)
    );
end design;

architecture behavioral of design is
    type memoria_type is array (0 to 8191) of std_logic_vector(7 downto 0);
    signal memoria : memoria_type := (others => (others => '0'));
    
begin
    processo_escrita: process(clk)
        variable endereco_atual : integer;
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                if byte_enable = '1' then
                    -- Modo byte: escreve apenas um byte
                    endereco_atual := to_integer(unsigned(mem_address));
                    memoria(endereco_atual) <= data_input(7 downto 0);
                else
                    -- Modo word: escreve 4 bytes
                    endereco_atual := to_integer(unsigned(mem_address(12 downto 2))) * 4;
                    memoria(endereco_atual)     <= data_input(7 downto 0);
                    memoria(endereco_atual + 1) <= data_input(15 downto 8);
                    memoria(endereco_atual + 2) <= data_input(23 downto 16);
                    memoria(endereco_atual + 3) <= data_input(31 downto 24);
                end if;
            end if;
        end if;
    end process processo_escrita;

    processo_leitura: process(mem_address, byte_enable, sign_enable, memoria)
        variable endereco_atual : integer;
        variable temp_output : std_logic_vector(31 downto 0);
    begin
        if byte_enable = '1' then
            -- Modo byte: le apenas um byte
            endereco_atual := to_integer(unsigned(mem_address));
            if sign_enable = '1' and memoria(endereco_atual)(7) = '1' then
                -- Extensao de sinal
                temp_output(31 downto 8) := (others => '1');
                temp_output(7 downto 0) := memoria(endereco_atual);
            else
                -- Extensao com zero
                temp_output(31 downto 8) := (others => '0');
                temp_output(7 downto 0) := memoria(endereco_atual);
            end if;
        else
            -- Modo word: le 4 bytes consecutivos
            endereco_atual := to_integer(unsigned(mem_address(12 downto 2))) * 4;
            temp_output(7 downto 0)   := memoria(endereco_atual);
            temp_output(15 downto 8)  := memoria(endereco_atual + 1);
            temp_output(23 downto 16) := memoria(endereco_atual + 2);
            temp_output(31 downto 24) := memoria(endereco_atual + 3);
        end if;
        data_output <= temp_output;
    end process processo_leitura;

end behavioral;
