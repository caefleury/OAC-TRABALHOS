library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity controle is
    port (
        opcode      : in std_logic_vector(6 downto 0);
	is_jump     : out std_logic;
	jalr        : out std_logic;
	is_branch   : out std_logic;
        mem_read    : out std_logic;
        mem_to_reg  : out std_logic;
        ula_op      : out std_logic_vector(1 downto 0);
        mem_write   : out std_logic;
        ula_fonte   : out std_logic;
        reg_write   : out std_logic;
        auipc_lui   : out std_logic_vector(1 downto 0));
end controle;

architecture behavioral of controle is
begin
    process(opcode)
    begin
        case opcode is
            when iRType | iIType => 
                if (opcode = iRType) then 
                    ula_fonte  <= '0';
                    ula_op   <= CONTROLE_ULA_ARIT_SHIFT_COMP;
                else
                    ula_fonte  <= '1'; 
                    ula_op   <= CONTROLE_ULA_IMEDIATOS;
                end if;
                mem_to_reg  <= '0';
                reg_write   <= '1';
                mem_read    <= '0';
                mem_write   <= '0';
                is_branch   <= '0';
                auipc_lui   <= MUX_SEL_REG1;
                is_jump     <= '0';
                jalr        <= '0';
            when iILType => 
                ula_fonte     <= '1';
                mem_to_reg  <= '1';
                reg_write   <= '1';
                mem_read    <= '1';
                mem_write   <= '0';
                is_branch   <= '0';
                ula_op      <= CONTROLE_ULA_MEM_LUI_AUIPC;
                auipc_lui   <= MUX_SEL_REG1;
                is_jump     <= '0';
                jalr        <= '0';
            when iSType => 
                ula_fonte     <= '1';
                mem_to_reg  <= '0';
                reg_write   <= '0';
                mem_read    <= '0';
                mem_write   <= '1';
                is_branch   <= '0';
                ula_op      <= CONTROLE_ULA_MEM_LUI_AUIPC;
                auipc_lui   <= MUX_SEL_REG1;
                is_jump     <= '0';
                jalr        <= '0';
            when iBType => 
                ula_fonte     <= '0';
                mem_to_reg  <= '0';
                reg_write   <= '0';
                mem_read    <= '0';
                mem_write   <= '0';
                is_branch   <= '1';
                ula_op      <= CONTROLE_ULA_BRANCH;
                auipc_lui   <= MUX_SEL_REG1;
                is_jump     <= '0';
                jalr        <= '0';
            when iLUI | iAUIPC=>
                if (opcode = iLUI) then
                    auipc_lui   <= MUX_SEL_LUI;
                else
                    auipc_lui   <= MUX_SEL_AUIPC;
                end if;
                ula_fonte   <= '1';
                mem_to_reg  <= '0';
                reg_write   <= '1';
                mem_read    <= '0';
                mem_write   <= '0';
                is_branch   <= '0';
                ula_op      <= CONTROLE_ULA_MEM_LUI_AUIPC;
                is_jump     <= '0';
                jalr        <= '0';
	    when iJAL =>
                ula_fonte   <= '1';
                mem_to_reg  <= '0';
                reg_write   <= '1';
                mem_read    <= '0';
                mem_write   <= '0';
                is_branch   <= '1';
                ula_op      <= CONTROLE_ULA_MEM_LUI_AUIPC;
                auipc_lui   <= MUX_SEL_AUIPC;
                is_jump     <= '1';
                jalr        <= '0';
            when iJALR =>
                ula_fonte     <= '1';
                mem_to_reg  <= '0';
                reg_write   <= '1';
                mem_read    <= '0';
                mem_write   <= '0';
                is_branch   <= '1';
                ula_op      <= CONTROLE_ULA_MEM_LUI_AUIPC;
                auipc_lui   <= MUX_SEL_REG1;
                is_jump     <= '1';
                jalr        <= '1';
            
            when others => null;
        end case ;
    end process;
end architecture behavioral;
