library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench_rom is
end testbench_rom;

architecture testbench of testbench_rom is
    component rom_rv is
        port (
            address : in  std_logic_vector(10 downto 0);
            dataout : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Sinais de teste
    signal address : std_logic_vector(10 downto 0) := (others => '0');
    signal dataout : std_logic_vector(31 downto 0);
    signal fim_teste : boolean := false;

    -- Função para ler o arquivo de instruções e criar um array de referência
    type instr_array is array (0 to 15) of std_logic_vector(31 downto 0);
    impure function carrega_instrucoes_ref return instr_array is
        file arquivo : text open read_mode is "instrucoes.txt";
        variable linha : line;
        variable temp : std_logic_vector(31 downto 0);
        variable resultado : instr_array;
    begin
        for i in 0 to 15 loop
            if not endfile(arquivo) then
                readline(arquivo, linha);
                hread(linha, temp);
                resultado(i) := temp;
            else
                resultado(i) := (others => '0');
            end if;
        end loop;
        return resultado;
    end function;

begin
    -- Instanciação do componente
    DUT: rom_rv port map (
        address => address,
        dataout => dataout
    );

    -- Processo de teste
    test_process: process
        variable instrucoes_ref : instr_array;
    begin
        -- Carrega as instruções de referência
        instrucoes_ref := carrega_instrucoes_ref;

        -- Testa os primeiros 16 endereços
        for i in 0 to 15 loop
            address <= std_logic_vector(to_unsigned(i, 11));
            wait for 10 ns;  -- Espera a saída estabilizar
            
            assert dataout = instrucoes_ref(i)
                report "Erro na leitura do endereco " & integer'image(i) & 
                      ". Esperado: " & to_hstring(instrucoes_ref(i)) &
                      ", Obtido: " & to_hstring(dataout)
                severity error;
        end loop;

        -- Fim dos testes
        report "Testes concluidos com sucesso!";
        fim_teste <= true;
        wait;
    end process;

end testbench;
