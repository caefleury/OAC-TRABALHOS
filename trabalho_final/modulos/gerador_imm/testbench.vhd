library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

entity testbench is
end testbench;

architecture geradorDeImediato_tb of testbench is
    -- componente que vamos testar
    component genImm32 is
        port (
            instr : in std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;
    
    -- sinais para conectar ao componente
    signal instr_tb : std_logic_vector(31 downto 0);
    signal imm32_tb : signed(31 downto 0);
    
    -- array com os casos de teste
    type test_vector is record
        -- instrução a ser testada
        instrucao : std_logic_vector(31 downto 0);
        -- valor esperado do imediato
        imediato_esperado : std_logic_vector(31 downto 0);
    end record;
    
    -- vetor com todos os casos de teste
    type test_array is array (0 to 10) of test_vector;
    constant testes : test_array := (
        0 => (X"000002b3", X"00000000"),
        1 => (X"01002283", X"00000010"),
        2 => (X"f9c00313", X"ffffff9c"),
        3 => (X"fff2c293", X"ffffffff"),
        4 => (X"16200313", X"00000162"),
        5 => (X"01800067", X"00000018"),
        6 => (X"40a3d313", X"0000000a"),
        7 => (X"00002437", X"00002000"),
        8 => (X"02542e23", X"0000003c"),
        9 => (X"fe5290e3", X"ffffffe0"),
        10 => (X"00c000ef", X"0000000c")
    );

begin
    -- conecta o componente aos sinais de teste
    DUT: genImm32 port map (
        instr => instr_tb,
        imm32 => imm32_tb
    );
    
    -- processo que faz os testes
    process
        variable erros : integer := 0;  -- conta quantos testes falharam
    begin
        
        -- testa cada caso
        for i in testes'range loop
            -- mostra qual teste está rodando
            report "teste " & integer'image(i+1) ;
            
            -- coloca a instrução na entrada
            instr_tb <= testes(i).instrucao;
            -- espera um pouco para o circuito processar
            wait for 10 ns;
            
            -- compara o resultado com o esperado
            if (imm32_tb = signed(testes(i).imediato_esperado)) then
                report "teste passou - imediato gerado: " & integer'image(to_integer(imm32_tb));
            else
                report "erro - esperado: " & integer'image(to_integer(signed(testes(i).imediato_esperado))) &
                       "resultado do teste: " & integer'image(to_integer(imm32_tb))
                severity error;
                erros := erros + 1;
            end if;
            
            -- espera mais um pouco antes do próximo teste
            wait for 10 ns;
        end loop;
        
        report "fim";
        wait; 
    end process;

end geradorDeImediato_tb;