library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture testbench of testbench is
    -- componente a ser testado
    component design is
        port (
            clk          : in  std_logic;
            write_enable : in  std_logic;
            byte_enable  : in  std_logic;
            sign_enable  : in  std_logic;
            mem_address  : in  std_logic_vector(12 downto 0);
            data_input   : in  std_logic_vector(31 downto 0);
            data_output  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Sinais de teste
    signal clk          : std_logic := '0';
    signal write_enable : std_logic := '0';
    signal byte_enable  : std_logic := '0';
    signal sign_enable  : std_logic := '0';
    signal mem_address  : std_logic_vector(12 downto 0) := (others => '0');
    signal data_input   : std_logic_vector(31 downto 0) := (others => '0');
    signal data_output  : std_logic_vector(31 downto 0);
    signal fim_teste    : boolean := false;

    -- Constantes
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instanciacao do componente
    DUT: design port map (
        clk          => clk,
        write_enable => write_enable,
        byte_enable  => byte_enable,
        sign_enable  => sign_enable,
        mem_address  => mem_address,
        data_input   => data_input,
        data_output  => data_output
    );

    -- Processo de geracao do clock
    clk_process: process
    begin
        while not fim_teste loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Processo de teste
    test_process: process
    begin
        -- Teste 1: Escrita e leitura de word
        write_enable <= '1';
        byte_enable  <= '0';  -- Modo word
        mem_address  <= "0000000000000";  -- Endereco 0
        data_input   <= x"12345678";
        wait for CLK_PERIOD;

        write_enable <= '0';
        wait for CLK_PERIOD;
        assert data_output = x"12345678"
            report "Erro na leitura de word"
            severity error;

        -- Teste 2: Escrita e leitura de byte com extensao de sinal
        write_enable <= '1';
        byte_enable  <= '1';  -- Modo byte
        sign_enable  <= '1';  -- Com extensao de sinal
        mem_address  <= "0000000000100";  -- Endereco 4
        data_input   <= x"000000FF";
        wait for CLK_PERIOD;

        write_enable <= '0';
        wait for CLK_PERIOD;
        assert data_output = x"000000FF"
            report "Erro na leitura de byte com extensao"
            severity error;

        -- Teste 3: Escrita e leitura de byte sem extensao de sinal
        write_enable <= '1';
        byte_enable  <= '1';  -- Modo byte
        sign_enable  <= '0';  -- Sem extensao de sinal
        mem_address  <= "0000000001000";  -- Endereco 8
        data_input   <= x"000000AA";
        wait for CLK_PERIOD;

        write_enable <= '0';
        wait for CLK_PERIOD;
        assert data_output = x"000000AA"
            report "Erro na leitura de byte sem extensao"
            severity error;

        -- Fim dos testes
        report "Testes concluidos com sucesso!";
        fim_teste <= true;
        wait;
    end process;

end testbench;
        report "Testes concluidos";
        wait;
    end process;
end testbench;
