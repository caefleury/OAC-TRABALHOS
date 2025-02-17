library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity genImm32 is
    port (
        instr: in std_logic_vector(WORD_SIZE-1 downto 0);
        imm32: out std_logic_vector(WORD_SIZE-1 downto 0));
end entity genImm32;

architecture arch of genImm32 is
begin
    process(instr)
    begin
        case instr(6 downto 0) is	-- OPCODE
            when iRType => --R-type
                imm32 <= (others => '0');
            when iILType | iIType | iJALR => --I-type
                if ((instr(6 downto 0) = iIType and instr(14 downto 12) = iSLL3) or (instr(6 downto 0) = iIType and instr(14 downto 12) = iSRLSRA3)) then
                    imm32 <= std_logic_vector(resize(signed(instr(24 downto 20)), imm32'length));
                else
                    imm32 <= std_logic_vector(resize(signed(instr(31 downto 20)), imm32'length));
                end if;
            when iSType => --S-type
                imm32 <= std_logic_vector(resize(signed(instr(31 downto 25) & instr(11 downto 7)), imm32'length));
            when iBType => --SB-type
                imm32 <= std_logic_vector(resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), imm32'length));
            when iJAL => --UJ-type
                imm32 <= std_logic_vector(resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), imm32'length));
            when iLUI | iAUIPC => --U-type
                imm32 <= std_logic_vector(signed(instr(31 downto 12) & X"000"));
            when others =>
                null;
        end case;
    end process;
end architecture arch;
