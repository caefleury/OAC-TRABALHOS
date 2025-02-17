library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- módulo que gera o valor imediato baseado na instrução risc-v
entity genImm32 is
    port (
        -- entrada: instrução de 32 bits
        instr : in std_logic_vector(31 downto 0);
        -- saída: valor imediato de 32 bits (com sinal)
        imm32 : out signed(31 downto 0)
    );
end genImm32;

architecture geradorDeImediato of genImm32 is
begin
    -- esse process roda sempre que a instrução muda
    process(instr)
        -- guarda os 7 bits do opcode pra ficar mais fácil de usar
        variable opcode : std_logic_vector(6 downto 0);
    begin
        -- pega o opcode da instrução (bits 6 até 0)
        opcode := instr(6 downto 0);
        
        -- decide o que fazer baseado no opcode
        case opcode is
            -- instrução tipo r (tipo add, sub, etc)
            -- não tem imediato, então retorna 0
            when "0110011" =>  -- 0x33
                imm32 <= to_signed(0, 32);
            
            -- instruções tipo i (load, addi, jalr)
            when "0000011" | "0010011" | "1100111" =>  -- 0x03, 0x13, 0x67
                -- caso especial: srai (shift right arithmetic immediate)
                if opcode = "0010011" and instr(14 downto 12) = "101" and instr(30) = '1' then
                    -- pega só os 5 bits do shamt e completa com zeros
                    imm32 <= resize(signed("000000000000000000000000000" & instr(24 downto 20)), 32);
                else
                    -- pega os 12 bits do imediato e faz extensão de sinal
                    imm32 <= resize(signed(instr(31 downto 20)), 32);
                end if;
            
            -- instrução tipo s (store)
            when "0100011" =>  -- 0x23
                -- junta os pedaços do imediato e faz extensão de sinal
                -- o imediato tá espalhado na instrução: bits 31-25 e 11-7
                imm32 <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);
            
            -- instrução tipo sb (branch)
            when "1100011" =>  -- 0x63
                -- junta os pedaços do imediato e coloca um 0 no final (multiplica por 2)
                -- o imediato tá todo bagunçado: bit 31, bit 7, bits 30-25, bits 11-8
                imm32 <= resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32);
            
            -- instrução tipo u (lui)
            when "0110111" =>  -- 0x37
                -- pega os 20 bits mais significativos e completa com 12 zeros
                imm32 <= signed(instr(31 downto 12) & "000000000000");
            
            -- instrução tipo uj (jal)
            when "1101111" =>  -- 0x6f
                -- junta os pedaços do imediato e coloca um 0 no final
                -- outra bagunça: bit 31, bits 19-12, bit 20, bits 30-21
                imm32 <= resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32);
            
            -- se não for nenhum desses opcodes, retorna 0
            when others =>
                imm32 <= to_signed(0, 32);
                
        end case;
    end process;
end geradorDeImediato;
