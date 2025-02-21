library ieee;
use ieee.std_logic_1164.all;
use work.riscv_pkg.all;

entity controle_ula is
    port (
        aluop  : in std_logic_vector(1 downto 0);  
        funct7 : in std_logic_vector(6 downto 0);  
        funct3 : in std_logic_vector(2 downto 0);  
        alu_operation : out alu_op_type;  
        is_mem_op : out std_logic  
    );
end entity;

architecture rtl of controle_ula is
begin
    process(aluop, funct3, funct7)
    begin
        alu_operation <= ALU_ADD;  
        is_mem_op <= '0';         
        
        case aluop is
            when "00" =>
                alu_operation <= ALU_ADD;
                is_mem_op <= '1';
            when "01" =>
                case funct3 is
                    when "000" =>  -- BEQ 
                        alu_operation <= ALU_SUB;
                    when "001" =>  -- BNE 
                        alu_operation <= ALU_SUB;
                    when "100" =>  -- BLT 
                        alu_operation <= ALU_SLT;
                    when "101" =>  -- BGE 
                        alu_operation <= ALU_SLT;
                    when "110" =>  -- BLTU 
                        alu_operation <= ALU_SLTU;
                    when "111" =>  -- BGEU 
                        alu_operation <= ALU_SLTU;
                    when others =>
                        alu_operation <= ALU_ADD;
                end case;
                
            when "10" =>
                -- Operações tipo R 
                case funct3 is
                    when "000" =>  
                        if funct7(5) = '1' then
                            alu_operation <= ALU_SUB;  -- SUB
                        else
                            alu_operation <= ALU_ADD;  -- ADD
                        end if;
                    when "001" =>  -- SLL 
                        alu_operation <= ALU_SLL;
                    when "010" =>  -- SLT 
                        alu_operation <= ALU_SLT;
                    when "011" =>  -- SLTU 
                        alu_operation <= ALU_SLTU;
                    when "100" =>  -- XOR
                        alu_operation <= ALU_XOR;
                    when "101" =>  -- SRL/SRA
                        if funct7(5) = '1' then
                            alu_operation <= ALU_SRA;  -- SRA
                        else
                            alu_operation <= ALU_SRL;  -- SRL
                        end if;
                    when "110" =>  -- OR
                        alu_operation <= ALU_OR;
                    when "111" =>  -- AND
                        alu_operation <= ALU_AND;
                    when others =>
                        alu_operation <= ALU_ADD;
                end case;
                
            when others =>
                alu_operation <= ALU_ADD;
        end case;
    end process;
end architecture;