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
        variable calc_result : std_logic_vector(WSIZE-1 downto 0);
    begin
        -- Initialize result to prevent metavalues
        calc_result := (others => '0');
        
        -- Check for valid inputs (no metavalues)
        if not (is_x(A) or is_x(B) or is_x(opcode)) then
            
            -- Calculate the result
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
                
                -- Default
                when others =>
                    calc_result := (31 downto 0 => '0');
            end case;

            -- For memory operations, adjust the address if needed
            if is_mem_op = '1' then
                full_addr := unsigned(calc_result);
                if full_addr >= x"2000" and full_addr < x"3000" then
                    -- Map data segment addresses (0x2000-0x2FFF) to 12-bit space
                    result <= (31 downto 12 => '0') & std_logic_vector(full_addr(11 downto 0));
                else
                    -- For other addresses, keep only lower 12 bits
                    result <= (31 downto 12 => '0') & std_logic_vector(full_addr(11 downto 0));
                end if;
            else
                -- For non-memory operations, use the calculated result directly
                result <= calc_result;
            end if;
            
            -- Set zero flag
            if unsigned(calc_result) = 0 then
                zero <= '1';
            else
                zero <= '0';
            end if;
        end if;
    end process;
    
    -- Output assignment
    Z <= result;
    
end comportamental;
