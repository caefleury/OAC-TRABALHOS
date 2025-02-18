library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- módulo da ula (unidade lógica aritmética) do risc-v
entity ula is
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
        -- flag de zero - usado em comparações
        zero : out std_logic;
        -- indica se é uma operação de memória
        is_mem_op : in std_logic
    );
end ula;

architecture comportamental of ula is
    -- sinais auxiliares para manipulação dos operandos
    signal A_signed : signed(WSIZE-1 downto 0);
    signal B_signed : signed(WSIZE-1 downto 0);
    signal A_unsigned : unsigned(WSIZE-1 downto 0);
    signal B_unsigned : unsigned(WSIZE-1 downto 0);
    signal result : std_logic_vector(WSIZE-1 downto 0);
    
begin
    -- Conversão dos operandos para os tipos signed e unsigned
    A_signed <= signed(A);
    B_signed <= signed(B);
    A_unsigned <= unsigned(A);
    B_unsigned <= unsigned(B);
    
    -- Processo principal da ULA
    process(opcode, A, B, A_signed, B_signed, A_unsigned, B_unsigned, is_mem_op)
        variable full_addr : unsigned(WSIZE-1 downto 0);
    begin
        case opcode is
            -- ADD
            when "0000" =>
                full_addr := unsigned(A_signed + B_signed);
                if is_mem_op = '1' then
                    -- Se for operação de memória, ajusta o endereço
                    if full_addr >= x"2000" and full_addr < x"3000" then
                        -- Endereços do segmento de dados (0x2000-0x2FFF)
                        -- Mapeia para 0x200-0xFFF no espaço de 12 bits
                        result <= (31 downto 12 => '0') & std_logic_vector(full_addr(11 downto 0));
                    else
                        -- Para outros endereços, mantém apenas os 12 bits menos significativos
                        result <= (31 downto 12 => '0') & std_logic_vector(full_addr(11 downto 0));
                    end if;
                else
                    -- Se não for operação de memória, mantém o resultado normal
                    result <= std_logic_vector(full_addr);
                end if;
            
            -- SUB
            when "0001" =>
                result <= std_logic_vector(A_signed - B_signed);
            
            -- AND
            when "0010" =>
                result <= A and B;
            
            -- OR
            when "0011" =>
                result <= A or B;
            
            -- XOR
            when "0100" =>
                result <= A xor B;
            
            -- SLL (Shift Left Logical)
            when "0101" =>
                result <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
            
            -- SRL (Shift Right Logical)
            when "0110" =>
                result <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
            
            -- SRA (Shift Right Arithmetic)
            when "0111" =>
                result <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
            
            -- SLT (Set Less Than)
            when "1000" =>
                if (A_signed < B_signed) then
                    result <= (0 => '1', 31 downto 1 => '0');
                else
                    result <= (31 downto 0 => '0');
                end if;
            
            -- SLTU (Set Less Than Unsigned)
            when "1001" =>
                if (A_unsigned < B_unsigned) then
                    result <= (0 => '1', 31 downto 1 => '0');
                else
                    result <= (31 downto 0 => '0');
                end if;
            
            -- Operação não definida
            when others =>
                result <= (31 downto 0 => '0');
        end case;
    end process;
    
    -- Atualiza as saídas
    Z <= result;
    zero <= '1' when result = (result'range => '0') else '0';
    
end comportamental;
