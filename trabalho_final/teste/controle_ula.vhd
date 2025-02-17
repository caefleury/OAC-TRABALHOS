library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity controle_ula is
    port (
        ula_op  : in std_logic_vector(1 downto 0);
        funct3  : in std_logic_vector(2 downto 0);
        funct7  : in std_logic;
        ula_controle : out std_logic_vector(3 downto 0));
end controle_ula;

architecture behavioral of controle_ula is
begin
    process(ula_op, funct7, funct3)
    begin
        case ula_op is
            
            when CONTROLE_ULA_BRANCH => -- Branchs
                case funct3 is
                    when iBEQ3 =>
                        ula_controle <= ULA_SEQ;
                    when iBNE3 =>
                        ula_controle <= ULA_SNE;
                    when others => null;
                end case;
            when CONTROLE_ULA_ARIT_SHIFT_COMP | CONTROLE_ULA_IMEDIATOS => -- Aritmético/Shift/Comparação
                case funct3 is
                    when iADDSUB3 =>
                        if (ula_op = CONTROLE_ULA_IMEDIATOS) then ula_controle <= ULA_ADD;
                        elsif (funct7 = '1') then ula_controle <= ULA_SUB; else ula_controle <= ULA_ADD; end if;
                    when iSLL3 =>
                        ula_controle <= ULA_SLL;
                    when iSLT3 =>
                        ula_controle <= ULA_SLT;
                    when iSLTU3 =>
                        ula_controle <= ULA_SLTU;
                    when iSRLSRA3 =>
                        if (funct7 = '1') then ula_controle <= ULA_SRA; else ula_controle <= ULA_SRL; end if;
            
                    when others => null;
                end case;
	    when CONTROLE_ULA_MEM_LUI_AUIPC => -- Memória
                ula_controle <= ULA_ADD;
            when others => null;
        end case;
    end process;
end architecture behavioral;
