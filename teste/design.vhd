library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.riscv_pkg.all;

entity riscv is
    port (
        clk	: in std_logic;
        rst	: in std_logic := '0';
        data  	: out std_logic_vector(WORD_SIZE - 1 downto 0));
end riscv;

architecture rtl of riscv is
-- Sinais
    signal pcin         	: std_logic_vector(WORD_SIZE - 1 downto 0) := (others => '0');	-- Entrada do PC
    signal pcout        	: std_logic_vector(WORD_SIZE - 1 downto 0) := (others => '0');	-- Saida do PC
    signal nextpc       	: std_logic_vector(WORD_SIZE - 1 downto 0);	-- Proximo pc (pc+4)
    signal pccond       	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal pcbranch     	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal regdata      	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal rd_data      	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal jump_somador		: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal memoria_dados_saida  : std_logic_vector(WORD_SIZE - 1 downto 0);
    signal regA         	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal regB         	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal ulaA         	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal ulaB         	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal ula_resultado	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal instr        	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal imm32        	: std_logic_vector(WORD_SIZE - 1 downto 0);
    signal reg_destino      	: std_logic;
    signal is_branch    	: std_logic;
    signal is_jump      	: std_logic;
    signal mem_reg      	: std_logic;
    signal mem_write    	: std_logic;
    signal ula_fonte      	: std_logic;
    signal reg_write    	: std_logic;
    signal mem_read     	: std_logic;
    signal mem_to_reg   	: std_logic;
    signal jalr         	: std_logic;
    signal ula_controle      	: std_logic_vector(3 downto 0);
    signal ula_op       	: std_logic_vector(1 downto 0);
    signal auipc_lui    	: std_logic_vector(1 downto 0);
    signal branch       	: std_logic;
    alias funct3   		: std_logic_vector(02 downto 0) is instr(14 downto 12);
    alias funct7   		: std_logic_vector(06 downto 0) is instr(31 downto 25);
    alias rs1     		: std_logic_vector(04 downto 0) is instr(19 downto 15);
    alias rs2   		: std_logic_vector(04 downto 0) is instr(24 downto 20);
    alias rd     		: std_logic_vector(04 downto 0) is instr(11 downto 07);
    alias opcode  		: std_logic_vector(06 downto 0) is instr(06 downto 00);
    alias endereco_memoria  	: std_logic_vector(MEM_ADDR - 1 downto 0) is pcout(11 downto 02);
    alias add_memoria_dados   	: std_logic_vector(MEM_ADDR - 1 downto 0) is ula_resultado(11 downto 02);
    alias funct7_5 		: std_logic is instr(30);

begin

    data <= pcout;

    pc_i: pc port map (clk, '1', rst, pcin, pcout);

    somar4comPC_i: somador port map (pcout, INC_PC, nextpc);

    memoria_instrucoes_i: memoria_instrucoes port map (endereco_memoria, instr);

    controle_i: controle port map (
        opcode,
	is_jump,
	jalr,
        is_branch,
        mem_read,
        mem_to_reg,
	ula_op,
        mem_write,
        ula_fonte,
        reg_write,
        auipc_lui
    );

    rd_mux_i:  mux2 port map (regdata, nextpc, is_jump, rd_data);

    xreg_i: xreg port map (
        clk,
        reg_write,
        rs1,
        rs2,
        rd,
        rd_data,
        regA,
        regB
    );

    genImm32_i: genImm32 port map (instr, imm32);

    mux3_i: mux3 port map (pcout, ZERO, regA, auipc_lui, ulaA);

    jump_mux2_i:  mux2 port map (pcout, regA, jalr, jump_somador);

    ula_mux_i:  mux2 port map (regB, imm32, ula_fonte, ulaB);

    controle_ula_i: controle_ula port map (ula_op, funct3, funct7_5, ula_controle);

    ula_i: ula port map (ula_controle, ulaA, ulaB, ula_resultado);

    somador_jump_i: somador port map (jump_somador, imm32, pccond);

    branch <= (is_branch and ula_resultado(0)) or is_jump;

    memoria_dados_i: memoria_dados port map (add_memoria_dados, clk, regB, mem_write, mem_read, memoria_dados_saida);

    memoria_reg_mux_i: mux2 port map (ula_resultado, memoria_dados_saida, mem_to_reg, regdata);

    incrementa_pc_I: mux2 port map (nextpc, pccond, branch, pcin);

end architecture rtl;
