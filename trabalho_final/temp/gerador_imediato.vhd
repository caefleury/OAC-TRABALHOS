library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.riscv_pkg.all;

-- módulo que gera o valor imediato baseado na instrução risc-v
entity gerador_imediato is
    port (
        -- entrada: instrução de 32 bits
        instr : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        -- saída: valor imediato de 32 bits
        imm   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end gerador_imediato;

architecture geradorDeImediato of gerador_imediato is
begin
    -- esse processo roda sempre que a instrução muda
    process(instr)
        -- guarda os 7 bits do opcode pra ficar mais fácil de usar
        variable opcode : std_logic_vector(6 downto 0);
        variable imm_temp : signed(31 downto 0);
    begin
        -- pega o opcode da instrução (bits 6 até 0)
        opcode := instr(6 downto 0);
        
        -- decide o que fazer baseado no opcode
        case opcode is
            -- instrução tipo r (tipo add, sub, etc)
            -- não tem imediato, então retorna 0
            when "0110011" =>  -- 0x33
                imm_temp := to_signed(0, 32);
            
            -- instrução tipo i (tipo addi, lw, etc)
            -- imediato está nos bits 31-20
            when "0010011" | "0000011" | "1100111" =>  -- 0x13, 0x03, 0x67
                imm_temp := signed(resize(signed(instr(31 downto 20)), 32));
            
            -- instrução tipo s (tipo sw, etc)
            -- imediato está nos bits 31-25 e 11-7
            when "0100011" =>  -- 0x23
                imm_temp := signed(resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32));
            
            -- instrução tipo b (tipo beq, bne, etc)
            -- imediato está nos bits 31,7,30-25,11-8
            when "1100011" =>  -- 0x63
                imm_temp := signed(resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32));
            
            -- instrução tipo u (lui, auipc)
            -- imediato está nos bits 31-12
            when "0110111" | "0010111" =>  -- 0x37, 0x17
                imm_temp := signed(resize(signed(instr(31 downto 12) & x"000"), 32));
            
            -- instrução tipo j (jal)
            -- imediato está nos bits 31,19-12,20,30-21
            when "1101111" =>  -- 0x6f
                imm_temp := signed(resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32));
            
            -- caso contrário retorna 0
            when others =>
                imm_temp := to_signed(0, 32);
        end case;
        
        -- converte o resultado para std_logic_vector
        imm <= std_logic_vector(imm_temp);
    end process;
end geradorDeImediato;
