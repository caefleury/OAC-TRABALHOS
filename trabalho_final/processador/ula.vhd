library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Unidade Lógica e Aritmética (ULA) do processador RISC-V
-- Realiza operações aritméticas e lógicas entre dois operandos
entity ula is
    generic (
        WSIZE : natural := 32  
    );
    port (
        opcode : in std_logic_vector(3 downto 0);     
        A, B : in std_logic_vector(WSIZE-1 downto 0);  
        Z : out std_logic_vector(WSIZE-1 downto 0);    
        zero : out std_logic;                         
        is_mem_op : in std_logic                       
    );
end ula;

architecture comportamental of ula is
    -- Sinais intermediários para cálculos
    signal A_signed : signed(WSIZE-1 downto 0);
    signal B_signed : signed(WSIZE-1 downto 0);
    signal A_unsigned : unsigned(WSIZE-1 downto 0);
    signal B_unsigned : unsigned(WSIZE-1 downto 0);
    signal result : std_logic_vector(WSIZE-1 downto 0);
    
begin
    -- Converte entradas para signed e unsigned
    A_signed <= signed(A);
    B_signed <= signed(B);
    A_unsigned <= unsigned(A);
    B_unsigned <= unsigned(B);
    
    -- Processo principal da ULA
    process(opcode, A, B, A_signed, B_signed, A_unsigned, B_unsigned, is_mem_op)
        -- Variáveis temporárias para cálculos
        variable full_addr : unsigned(WSIZE-1 downto 0);
        variable calc_result : std_logic_vector(WSIZE-1 downto 0);
    begin
        calc_result := (others => '0');
        if not (is_x(A) or is_x(B) or is_x(opcode)) then
            
            case opcode is
                -- ADD
                when "0000" =>
                    calc_result := std_logic_vector(A_signed + B_signed);
                
                -- SUB
                when "0001" =>
                    calc_result := std_logic_vector(A_signed - B_signed);
                
                -- AND
                when "0010" =>
                    calc_result := A and B;
                
                -- OR
                when "0011" =>
                    calc_result := A or B;
                
                -- XOR
                when "0100" =>
                    calc_result := A xor B;
                
                -- SLL
                when "0101" =>
                    calc_result := std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                
                -- SRL
                when "0110" =>
                    calc_result := std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                
                -- SRA
                when "0111" =>
                    calc_result := std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
                
                -- SLT
                when "1000" =>
                    if A_signed < B_signed then
                        calc_result := (31 downto 1 => '0') & '1';
                    else
                        calc_result := (31 downto 0 => '0');
                    end if;
                
                -- SLTU
                when "1001" =>
                    if A_unsigned < B_unsigned then
                        calc_result := (31 downto 1 => '0') & '1';
                    else
                        calc_result := (31 downto 0 => '0');
                    end if;
                
                when others =>
                    calc_result := (31 downto 0 => '0');
            end case;

            -- para operações de memoria
            if is_mem_op = '1' then
                full_addr := unsigned(calc_result);
                if full_addr >= x"2000" and full_addr < x"3000" then
                    result <= (31 downto 12 => '0') & std_logic_vector(full_addr(11 downto 0));
                else
                    result <= (31 downto 12 => '0') & std_logic_vector(full_addr(11 downto 0));
                end if;
            else
                result <= calc_result;
            end if;
            
            -- flag de zero
            if unsigned(calc_result) = 0 then
                zero <= '1';
            else
                zero <= '0';
            end if;
        end if;
    end process;
    
    Z <= result;
    
end comportamental;
