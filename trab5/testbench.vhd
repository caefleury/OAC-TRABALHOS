library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- módulo de teste para a ula risc-v (unidade lógica aritmética)
entity testbench is
end testbench;

architecture ula_tb of testbench is
    -- constantes do nosso testbench
    constant wsize : natural := 32;  -- tamanho do barramento
    constant delay : time := 10 ns;  -- tempo de atraso pra simulação
    
    -- componente da nossa ula que vamos testar
    component ulaRV is
        generic (
            wsize : natural := 32  -- tamanho do barramento de dados
        );
        port (
            opcode : in std_logic_vector(3 downto 0);  -- código da operação
            A, B : in std_logic_vector(wsize-1 downto 0);  -- operandos
            Z : out std_logic_vector(wsize-1 downto 0);  -- resultado
            cond : out std_logic  -- flag pra comparações
        );
    end component;
    
    -- sinais internos pra teste
    signal opcode_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal A_tb, B_tb : std_logic_vector(wsize-1 downto 0) := (others => '0');
    signal Z_tb : std_logic_vector(wsize-1 downto 0);
    signal cond_tb : std_logic;
    
begin
    -- instancia a nossa ula pra teste
    DUT: ulaRV 
        generic map (wsize => wsize)
        port map (
            opcode => opcode_tb,
            A => A_tb,
            B => B_tb,
            Z => Z_tb,
            cond => cond_tb  -- sinal de condição pra branch
        );
    
    -- processo principal dos testes
    process
        -- mostra info dos testes no console
        procedure print_test_info(test_name : string) is
        begin
            report "==================================";
            report "Testando: " & test_name;
            report "Entradas:";
            report "  opcode = " & integer'image(to_integer(unsigned(opcode_tb)));
            report "  A = " & integer'image(to_integer(signed(A_tb)));
            report "  B = " & integer'image(to_integer(signed(B_tb)));
            report "Saídas:";
            report "  Z = " & integer'image(to_integer(signed(Z_tb)));
            report "  cond = " & std_logic'image(cond_tb);
            report "==================================";
        end procedure;
    begin
        report "Iniciando os testes da ULA RISC-V";
        report "==================================";
        
        -- espera inicial para estabilização
        wait for delay;
        
        -- teste add com resultado positivo
        opcode_tb <= "0000";
        A_tb <= X"00000005";
        B_tb <= X"00000003";
        wait for delay;
        print_test_info("ADD Positivo");
        assert Z_tb = X"00000008" 
            report "Erro no ADD positivo" severity error;
            
        -- teste add com resultado zero
        A_tb <= X"00000003";
        B_tb <= X"FFFFFFFD"; -- -3 em complemento de 2
        wait for delay;
        print_test_info("ADD Zero");
        assert Z_tb = X"00000000" 
            report "Erro no ADD zero" severity error;
            
        -- teste add com resultado negativo
        A_tb <= X"FFFFFFFF"; -- -1
        B_tb <= X"FFFFFFFF"; -- -1
        wait for delay;
        print_test_info("ADD Negativo");
        assert Z_tb = X"FFFFFFFE" -- -2
            report "Erro no ADD negativo" severity error;

        -- teste sub com resultado positivo
        opcode_tb <= "0001";
        A_tb <= X"00000005";
        B_tb <= X"00000003";
        wait for delay;
        print_test_info("SUB Positivo");
        assert Z_tb = X"00000002" 
            report "Erro no SUB positivo" severity error;
            
        -- teste sub com resultado zero
        A_tb <= X"00000003";
        B_tb <= X"00000003";
        wait for delay;
        print_test_info("SUB Zero");
        assert Z_tb = X"00000000" 
            report "Erro no SUB zero" severity error;
            
        -- teste sub com resultado negativo
        A_tb <= X"00000003";
        B_tb <= X"00000005";
        wait for delay;
        print_test_info("SUB Negativo");
        assert Z_tb = X"FFFFFFFE" -- -2
            report "Erro no SUB negativo" severity error;

        -- teste and
        opcode_tb <= "0010";
        A_tb <= X"0F0F0F0F";
        B_tb <= X"00FF00FF";
        wait for delay;
        print_test_info("AND");
        assert Z_tb = X"000F000F"
            report "Erro no AND" severity error;

        -- teste or
        opcode_tb <= "0011";
        A_tb <= X"0F0F0F0F";
        B_tb <= X"00FF00FF";
        wait for delay;
        print_test_info("OR");
        assert Z_tb = X"0FFF0FFF"
            report "Erro no OR" severity error;

        -- teste xor
        opcode_tb <= "0100";
        A_tb <= X"0F0F0F0F";
        B_tb <= X"00FF00FF";
        wait for delay;
        print_test_info("XOR");
        assert Z_tb = X"0FF00FF0"
            report "Erro no XOR" severity error;

        -- teste sll (shift left logical)
        opcode_tb <= "0101";
        A_tb <= X"00000001";
        B_tb <= X"00000004";
        wait for delay;
        print_test_info("SLL");
        assert Z_tb = X"00000010"
            report "Erro no SLL" severity error;

        -- teste srl (shift right logical)
        opcode_tb <= "0110";
        A_tb <= X"80000000";
        B_tb <= X"00000004";
        wait for delay;
        print_test_info("SRL");
        assert Z_tb = X"08000000"
            report "Erro no SRL" severity error;

        -- teste sra (shift right arithmetic)
        opcode_tb <= "0111";
        A_tb <= X"80000000";
        B_tb <= X"00000004";
        wait for delay;
        print_test_info("SRA");
        assert Z_tb = X"F8000000"
            report "Erro no SRA" severity error;

        -- teste slt (set less than)
        opcode_tb <= "1000";
        A_tb <= X"FFFFFFFF"; -- -1
        B_tb <= X"00000001"; -- 1
        wait for delay;
        print_test_info("SLT");
        assert (Z_tb = X"00000001" and cond_tb = '1')
            report "Erro no SLT" severity error;

        -- teste sltu (set less than unsigned)
        opcode_tb <= "1001";
        A_tb <= X"FFFFFFFF"; -- maior sem sinal
        B_tb <= X"00000001"; -- menor sem sinal
        wait for delay;
        print_test_info("SLTU");
        assert (Z_tb = X"00000000" and cond_tb = '0')
            report "Erro no SLTU" severity error;

        -- teste sge (set greater equal)
        opcode_tb <= "1010";
        A_tb <= X"00000002";
        B_tb <= X"00000001";
        wait for delay;
        print_test_info("SGE");
        assert (Z_tb = X"00000001" and cond_tb = '1')
            report "Erro no SGE" severity error;

        -- teste sgeu (set greater equal unsigned)
        opcode_tb <= "1011";
        A_tb <= X"FFFFFFFF"; -- maior sem sinal
        B_tb <= X"00000001"; -- menor sem sinal
        wait for delay;
        print_test_info("SGEU");
        assert (Z_tb = X"00000001" and cond_tb = '1')
            report "Erro no SGEU" severity error;

        -- teste seq (set equal)
        opcode_tb <= "1100";
        A_tb <= X"00000001";
        B_tb <= X"00000001";
        wait for delay;
        print_test_info("SEQ");
        assert (Z_tb = X"00000001" and cond_tb = '1')
            report "Erro no SEQ" severity error;

        -- teste sne (set not equal)
        opcode_tb <= "1101";
        A_tb <= X"00000001";
        B_tb <= X"00000002";
        wait for delay;
        print_test_info("SNE");
        assert (Z_tb = X"00000001" and cond_tb = '1')
            report "Erro no SNE" severity error;

        report "==================================";
        report "Testes finalizados";
        wait;
    end process;
    
end ula_tb;
