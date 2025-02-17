library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- módulo da ula (unidade lógica aritmética) do risc-v

entity ulaRV is
    generic (
        -- tamanho padrão do risc-v rv32i
        WSIZE : natural := 32  
    );
    port (
        -- código da operação
        opcode : in std_logic_vector(3 downto 0);  
        -- operandos de entrada
        A, B : in std_logic_vector(WSIZE-1 downto 0);  
        -- resultado da operação
        Z : out std_logic_vector(WSIZE-1 downto 0);  
        -- flag de condição - usado em comparações
        cond : out std_logic  
    );
end ulaRV;

architecture comportamental of ulaRV is
    -- sinais auxiliares para manipulação dos operandos
    signal A_signed : signed(WSIZE-1 downto 0);
    signal B_signed : signed(WSIZE-1 downto 0);
    signal A_unsigned : unsigned(WSIZE-1 downto 0);
    signal B_unsigned : unsigned(WSIZE-1 downto 0);
    
begin
    -- converte os operandos para signed e unsigned para facilitar as operações
    A_signed <= signed(A);
    B_signed <= signed(B);
    A_unsigned <= unsigned(A);
    B_unsigned <= unsigned(B);
    
    -- process principal que implementa todas as operações da ula
    process(opcode, A, B, A_signed, B_signed, A_unsigned, B_unsigned)
        -- variáveis auxiliares para armazenar resultados temporários
        variable shift_amount : integer;
        variable result_temp : std_logic_vector(WSIZE-1 downto 0);
        variable cond_temp : std_logic;
    begin
        -- inicializa as variáveis temporárias
        shift_amount := to_integer(unsigned(B(4 downto 0)));  -- usa apenas 5 bits para shift
        result_temp := (others => '0');
        cond_temp := '0';
        
        -- seleciona a operação baseado no opcode
        case opcode is
            -- operações aritméticas
            when "0000" =>  -- add
                result_temp := std_logic_vector(A_signed + B_signed);
                cond_temp := '0';
                
            when "0001" =>  -- sub
                result_temp := std_logic_vector(A_signed - B_signed);
                cond_temp := '0';
                
            -- operações lógicas
            when "0010" =>  -- and
                result_temp := A and B;
                cond_temp := '0';
                
            when "0011" =>  -- or
                result_temp := A or B;
                cond_temp := '0';
                
            when "0100" =>  -- xor
                result_temp := A xor B;
                cond_temp := '0';
                
            -- operações de deslocamento
            when "0101" =>  -- sll (shift left logical)
                result_temp := std_logic_vector(shift_left(unsigned(A), shift_amount));
                cond_temp := '0';
                
            when "0110" =>  -- srl (shift right logical)
                result_temp := std_logic_vector(shift_right(unsigned(A), shift_amount));
                cond_temp := '0';
                
            when "0111" =>  -- sra (shift right arithmetic)
                result_temp := std_logic_vector(shift_right(signed(A), shift_amount));
                cond_temp := '0';
                
            -- operações de comparação
            when "1000" =>  -- slt (set less than)
                if (A_signed < B_signed) then
                    result_temp := std_logic_vector(to_unsigned(1, WSIZE));
                    cond_temp := '1';
                else
                    result_temp := (others => '0');
                    cond_temp := '0';
                end if;
                
            when "1001" =>  -- sltu (set less than unsigned)
                if (A_unsigned < B_unsigned) then
                    result_temp := std_logic_vector(to_unsigned(1, WSIZE));
                    cond_temp := '1';
                else
                    result_temp := (others => '0');
                    cond_temp := '0';
                end if;
                
            when "1010" =>  -- sge (set greater equal)
                if (A_signed >= B_signed) then
                    result_temp := std_logic_vector(to_unsigned(1, WSIZE));
                    cond_temp := '1';
                else
                    result_temp := (others => '0');
                    cond_temp := '0';
                end if;
                
            when "1011" =>  -- sgeu (set greater equal unsigned)
                if (A_unsigned >= B_unsigned) then
                    result_temp := std_logic_vector(to_unsigned(1, WSIZE));
                    cond_temp := '1';
                else
                    result_temp := (others => '0');
                    cond_temp := '0';
                end if;
                
            when "1100" =>  -- seq (set equal)
                if (A = B) then
                    result_temp := std_logic_vector(to_unsigned(1, WSIZE));
                    cond_temp := '1';
                else
                    result_temp := (others => '0');
                    cond_temp := '0';
                end if;
                
            when "1101" =>  -- sne (set not equal)
                if (A /= B) then
                    result_temp := std_logic_vector(to_unsigned(1, WSIZE));
                    cond_temp := '1';
                else
                    result_temp := (others => '0');
                    cond_temp := '0';
                end if;
                
            -- caso padrão (opcode inválido)
            when others =>
                result_temp := (others => '0');
                cond_temp := '0';
                
        end case;
        
        -- atualizador das saídas
        Z <= result_temp;
        cond <= cond_temp;
        
    end process;
    
end comportamental;
