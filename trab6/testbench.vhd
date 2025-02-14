library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

-- testbench do banco de registradores
entity testbench is
end testbench;

architecture behavioral of testbench is
    -- constantes do teste
    constant PERIODO : time := 10 ns;
    constant WSIZE : natural := 32;

    -- sinais pro teste
    signal rd, rs1, rs2 : std_logic_vector(4 downto 0) := (others => '0');
    signal data : std_logic_vector(WSIZE-1 downto 0) := (others => '0');
    signal ro1, ro2 : std_logic_vector(WSIZE-1 downto 0);
    signal wren : std_logic := '0';
    signal clk : std_logic := '0';

    -- componente a ser testado
    component XREGS is
        generic (WSIZE : natural := 32);
        port (
            data : in std_logic_vector(WSIZE-1 downto 0);
            rd : in std_logic_vector(4 downto 0);
            rs1, rs2 : in std_logic_vector(4 downto 0);
            wren : in std_logic;
            clk : in std_logic;
            ro2, ro1 : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

begin
    -- gera clock
    process
    begin
        while now < 1000 ns loop
            clk <= '0';
            wait for PERIODO/2;
            clk <= '1';
            wait for PERIODO/2;
        end loop;
        wait;
    end process;

    -- instancia o componente
    DUT: XREGS
        generic map (WSIZE => WSIZE)
        port map (
            data => data,
            rd => rd,
            rs1 => rs1,
            rs2 => rs2,
            wren => wren,
            clk => clk,
            ro1 => ro1,
            ro2 => ro2
        );

    -- processo de teste
    process
    begin
        -- zera tudo
        wren <= '0';
        wait for PERIODO;

        -- teste 2: tenta escrever no x0
        wren <= '1';
        rd <= "00000";
        data <= X"FFFFFFFF";
        wait for PERIODO;

        -- le x0 pra ver se continua zero
        wren <= '0';
        rs1 <= "00000";
        rs2 <= "00000";
        wait for PERIODO;

        -- checa se x0 ta zerado
        assert ro1 = X"00000000"
            report "Erro: registrador x0 foi modificado (ro1)"
            severity error;
        
        assert ro2 = X"00000000"
            report "Erro: registrador x0 foi modificado (ro2)"
            severity error;

        -- teste 1: escreve e le todos os registradores
        for i in 1 to 31 loop
            -- escreve o valor i no registrador i
            wren <= '1';
            rd <= std_logic_vector(to_unsigned(i, 5));
            data <= std_logic_vector(to_unsigned(i, WSIZE));
            wait for PERIODO;

            -- le e verifica
            wren <= '0';
            rs1 <= std_logic_vector(to_unsigned(i, 5));
            rs2 <= std_logic_vector(to_unsigned(i, 5));
            wait for PERIODO;

            -- checa se deu certo
            assert ro1 = std_logic_vector(to_unsigned(i, WSIZE))
                report "Erro: registrador " & integer'image(i) & " valor errado na porta ro1"
                severity error;
            
            assert ro2 = std_logic_vector(to_unsigned(i, WSIZE))
                report "Erro: registrador " & integer'image(i) & " valor errado na porta ro2"
                severity error;
        end loop;

        -- teste 3: le dois registradores diferentes
        wren <= '0';
        rs1 <= "00001";
        rs2 <= "00010";
        wait for PERIODO;

        -- verifica valores
        assert ro1 = X"00000001"
            report "Erro: valor errado no reg x1"
            severity error;
        
        assert ro2 = X"00000002"
            report "Erro: valor errado no reg x2"
            severity error;

        report "termina";
        wait;
    end process;

end behavioral;