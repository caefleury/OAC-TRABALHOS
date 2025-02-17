-- ROM do RISCV 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rom_rv is
    port (
        address : in  std_logic_vector(10 downto 0);
        dataout : out std_logic_vector(31 downto 0)
    );
end entity rom_rv;

architecture behavioral of rom_rv is
    type instr_mem is array (0 to 2047) of std_logic_vector(31 downto 0);
    
    impure function carrega_instrucoes return instr_mem is

        file arquivo : text open read_mode is "instrucoes.txt";
        
        variable linha : line;
        variable instrucoes : instr_mem;
        variable instrucao : std_logic_vector(31 downto 0);
    begin
        instrucoes := (others => (others => '0'));
        
        for i in 0 to 2047 loop
            if not endfile(arquivo) then
                readline(arquivo, linha);
                hread(linha, instrucao);
                instrucoes(i) := instrucao;
            end if;
        end loop;
        
        return instrucoes;
    end function;

    signal instrucoes : instr_mem := carrega_instrucoes;

begin
    dataout <= instrucoes(to_integer(unsigned(address)));

end behavioral;
