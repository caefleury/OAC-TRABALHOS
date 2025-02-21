library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity testbench is
end entity;

architecture tb of testbench is
    function to_hex_string(slv : std_logic_vector) return string is
        variable l : line;
    begin
        hwrite(l, slv);
        return l.all;
    end function;

    component riscv_processor is
        generic (
            WSIZE : natural := 32
        );
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;  
            debug_pc    : out std_logic_vector(31 downto 0);
            debug_inst  : out std_logic_vector(31 downto 0);
            debug_reg_write : out std_logic_vector(31 downto 0);
            debug_branch    : out std_logic;
            debug_memread   : out std_logic;
            debug_memtoreg  : out std_logic;
            debug_aluop     : out std_logic_vector(1 downto 0);
            debug_memwrite  : out std_logic;
            debug_alusrc    : out std_logic;
            debug_regwrite  : out std_logic;
            debug_jump      : out std_logic;
            debug_alu_result: out std_logic_vector(31 downto 0);
            debug_mem_rdata : out std_logic_vector(31 downto 0);
            debug_mem_wdata : out std_logic_vector(31 downto 0);
            debug_next_pc   : out std_logic_vector(31 downto 0);
            debug_rs1_data  : out std_logic_vector(31 downto 0);
            debug_rs2_data  : out std_logic_vector(31 downto 0);
            debug_imm_value : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Constantes de temporização
    constant PERIODO     : time := 20 ns;  -- Período do clock
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET     : time := 5 ns;
    
    -- Sinais de teste
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';  
    signal stop_clock : boolean := false;
    
    -- Sinais de depuração
    signal debug_pc : std_logic_vector(31 downto 0);
    signal debug_inst : std_logic_vector(31 downto 0);
    signal debug_reg_write : std_logic_vector(31 downto 0);
    signal debug_branch    : std_logic;
    signal debug_memread   : std_logic;
    signal debug_memtoreg  : std_logic;
    signal debug_aluop     : std_logic_vector(1 downto 0);
    signal debug_memwrite  : std_logic;
    signal debug_alusrc    : std_logic;
    signal debug_regwrite  : std_logic;
    signal debug_jump      : std_logic;
    signal debug_alu_result: std_logic_vector(31 downto 0);
    signal debug_mem_rdata : std_logic_vector(31 downto 0);
    signal debug_mem_wdata : std_logic_vector(31 downto 0);
    signal debug_next_pc   : std_logic_vector(31 downto 0);
    signal debug_rs1_data  : std_logic_vector(31 downto 0);
    signal debug_rs2_data  : std_logic_vector(31 downto 0);
    signal debug_imm_value : std_logic_vector(31 downto 0);
    
    -- Status do teste
    signal test_status : boolean := true;
    
begin
    -- Instanciação do processador
    UUT: riscv_processor
        generic map (
            WSIZE => 32
        )
        port map (
            clk => clk,
            rst => rst,  
            debug_pc => debug_pc,
            debug_inst => debug_inst,
            debug_reg_write => debug_reg_write,
            debug_branch => debug_branch,
            debug_memread => debug_memread,
            debug_memtoreg => debug_memtoreg,
            debug_aluop => debug_aluop,
            debug_memwrite => debug_memwrite,
            debug_alusrc => debug_alusrc,
            debug_regwrite => debug_regwrite,
            debug_jump => debug_jump,
            debug_alu_result => debug_alu_result,
            debug_mem_rdata => debug_mem_rdata,
            debug_mem_wdata => debug_mem_wdata,
            debug_next_pc => debug_next_pc,
            debug_rs1_data => debug_rs1_data,
            debug_rs2_data => debug_rs2_data,
            debug_imm_value => debug_imm_value
        );
    
    -- Geração do clock
    clock_gen: process
    begin
        while not stop_clock loop
            wait for (PERIODO - (PERIODO * DUTY_CYCLE));
            clk <= not clk;
        end loop;
        wait;
    end process;
    
    stimulus: process
        -- Procedimentos auxiliares
        procedure print_status(
            constant test_name : in string;
            constant success : in boolean;
            constant actual_value : in std_logic_vector(31 downto 0);
            constant expected_value : in std_logic_vector(31 downto 0)
        ) is
            variable l : line;
        begin
            write(l, test_name);
            write(l, string'(": "));
            if success then
                write(l, string'("PASS"));
            else
                write(l, string'("FAIL"));
                write(l, string'(" - Valor esperado: 0x"));
                hwrite(l, expected_value);
                write(l, string'(" Valor obtido: 0x"));
                hwrite(l, actual_value);
                test_status <= false;
            end if;
            writeline(output, l);
            
            -- Imprime o PC e a instrução atual para debug
            write(l, string'("PC atual: 0x"));
            hwrite(l, debug_pc);
            write(l, string'(" Instrução: 0x"));
            hwrite(l, debug_inst);
            writeline(output, l);
            
            -- Se houver escrita de registrador, exibe o valor
            if unsigned(debug_reg_write) /= 0 then
                write(l, string'("Valor de escrita de registrador: 0x"));
                hwrite(l, debug_reg_write);
                writeline(output, l);
            end if;
            
            write(l, string'("--------------------------"));
            writeline(output, l);
        end procedure;
        
        procedure check_instruction(
            instruction : in std_logic_vector(31 downto 0);
            test_name   : in string
        ) is
        begin
            report "----------------------------------------";
            report "Iniciando teste: " & test_name;
            report "Instrução: 0x" & to_hex_string(instruction);
            
            -- Primeiro, relata o estado atual antes da borda de clock
            -- Relata sinais de controle
            report "Sinais de controle:";
            report "  Branch: " & std_logic'image(debug_branch);
            report "  MemRead: " & std_logic'image(debug_memread);
            report "  MemToReg: " & std_logic'image(debug_memtoreg);
            report "  ALUOp: " & integer'image(to_integer(unsigned(debug_aluop)));
            report "  MemWrite: " & std_logic'image(debug_memwrite);
            report "  ALUSrc: " & std_logic'image(debug_alusrc);
            report "  RegWrite: " & std_logic'image(debug_regwrite);
            report "  Jump: " & std_logic'image(debug_jump);
            
            -- Relata valores de registrador
            report "Valores de registrador:";
            report "  rs1 data: 0x" & to_hex_string(debug_rs1_data);
            report "  rs2 data: 0x" & to_hex_string(debug_rs2_data);
            report "  Valor imediato: 0x" & to_hex_string(debug_imm_value);
            
            -- Relata PC e próximo PC
            report "PC: 0x" & to_hex_string(debug_pc);
            report "Próximo PC: 0x" & to_hex_string(debug_next_pc);
            
            -- Relata resultado da ULA
            report "Resultado da ULA: 0x" & to_hex_string(debug_alu_result);
            
            -- Relata dados de memória
            report "Dado lido da memória: 0x" & to_hex_string(debug_mem_rdata);
            report "Valor de MemToReg: '" & std_logic'image(debug_memtoreg) & "'";

            
            case instruction(6 downto 0) is
                when "0110011" => -- R
                    report "Instrução R-type detectada";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                when "0010011" | "0000011" => -- I
                    report "Instrução I-type detectada";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imediato: " & integer'image(to_integer(signed(instruction(31 downto 20))));
                when "0100011" => -- S
                    report "Instrução S-type detectada";
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imediato: " & integer'image(to_integer(signed(instruction(31 downto 25) & instruction(11 downto 7))));
                when "1100011" => -- B
                    report "Instrução B-type detectada";
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                    report "  imediato: " & integer'image(to_integer(signed(instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0')));
                when "0110111" => -- LUI
                    report "Instrução LUI detectada";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  imediato: 0x" & to_hex_string(instruction(31 downto 12) & x"000");
                when "0010111" => -- AUIPC
                    report "Instrução AUIPC detectada";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  imediato: 0x" & to_hex_string(instruction(31 downto 12) & x"000");
                when "1101111" => -- JAL
                    report "Instrução JAL detectada";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  imediato: " & integer'image(to_integer(signed(instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0')));
                when "1100111" => -- JALR
                    report "Instrução JALR detectada";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imediato: " & integer'image(to_integer(signed(instruction(31 downto 20))));
                when others =>
                    report "Tipo de instrução desconhecido: " & to_hex_string(instruction);
            end case;
            
            -- Agora avança para o próximo ciclo de clock
            wait until rising_edge(clk);
            wait for 1 ns;  -- Aguarda os sinais se estabilizarem
            
            report "Teste concluído: " & test_name;
            report "----------------------------------------";
        end procedure;
        
    begin
        -- Imprime cabeçalho do teste
        report "Iniciando testes do processador RISC-V";
        
        -- Assert reset por alguns ciclos
        wait for PERIODO * 2;
        rst <= '0';  
        
        -- Inicia testes de instrução
        wait for PERIODO;  -- Aguarda um ciclo para estabilizar os sinais
        
        -- Teste 1: Carrega x1 com 5
        check_instruction(x"00500093", "Carrega x1 com 5");
        
        -- Teste 2: Carrega x2 com 12
        check_instruction(x"00C00113", "Carrega x2 com 12");
        
        -- Teste 3: Carrega x3 com 12
        check_instruction(x"00C00193", "Carrega x3 com 12");
        
        -- Teste 4: Carrega x31 com -4
        check_instruction(x"FFC00F93", "Carrega x31 com -4");
        
        -- Teste 5: Soma x4 = x2 + x0
        check_instruction(x"00208233", "Soma x4 = x2 + x0");
        
        -- Teste 6: Subtração x5 = x3 - x2
        check_instruction(x"402182B3", "Subtração x5 = x3 - x2");
        
        -- Teste 7: Carrega imediato superior x6 = 1
        check_instruction(x"00001337", "Carrega imediato superior x6 = 1");
        
        -- Teste 8: AND x7 = x2 & x3
        check_instruction(x"003173B3", "AND x7 = x2 & x3");
        
        -- Teste 9: OR x8 = x2 | x0
        check_instruction(x"0020A433", "OR x8 = x2 | x0");
        
        -- Teste 10: XOR x9 = x3 ^ x0
        check_instruction(x"0031E4B3", "XOR x9 = x3 ^ x0");
        
        -- Teste 11: Deslocamento à esquerda x10 = x2 << x0
        check_instruction(x"0020C533", "Deslocamento à esquerda x10 = x2 << x0");
        
        -- Teste 12: Deslocamento à direita x11 = x2 >> 1
        check_instruction(x"00111593", "Deslocamento à direita x11 = x2 >> 1");
        
        -- Teste 13: Deslocamento à esquerda x12 = x2 << 1
        check_instruction(x"00115613", "Deslocamento à esquerda x12 = x2 << 1");
        
        -- Teste 14: Deslocamento aritmético à direita x13 = x2 >> 1
        check_instruction(x"40115693", "Deslocamento aritmético à direita x13 = x2 >> 1");
        
        -- Teste 15: Comparação menor que x14 = (x2 < x0)
        check_instruction(x"0020A733", "Comparação menor que x14 = (x2 < x0)");
        
        -- Teste 16: Comparação menor que sem sinal x15 = (x2 < x0)
        check_instruction(x"0020B7B3", "Comparação menor que sem sinal x15 = (x2 < x0)");
        
        -- Teste 17: Armazena palavra mem[1] = x2
        check_instruction(x"00100123", "Armazena palavra mem[1] = x2");
        
        -- Teste 18: Armazena palavra mem[2] = x2
        check_instruction(x"00200223", "Armazena palavra mem[2] = x2");
        
        -- Teste 19: Carrega palavra x4 = mem[2]
        check_instruction(x"00102223", "Carrega palavra x4 = mem[2]");
        
        -- Teste 20: Armazena palavra mem[4] = x2
        check_instruction(x"00202423", "Armazena palavra mem[4] = x2");
        
        -- Teste 21: Carrega palavra x16 = mem[8]
        check_instruction(x"00102823", "Carrega palavra x16 = mem[8]");
        
        -- Teste 22: Carrega palavra x17 = mem[2]
        check_instruction(x"00200883", "Carrega palavra x17 = mem[2]");
        
        -- Teste 23: Carrega x18 com 31
        check_instruction(x"01F00903", "Carrega x18 com 31");
        
        -- Teste 24: Desvio se igual x3,x2,8
        check_instruction(x"00218463", "Desvio se igual x3,x2,8");
        
        -- Teste 25: Nenhuma operação
        check_instruction(x"00000013", "Nenhuma operação");
        
        -- Teste 26: Desvio se diferente x3,x2,8
        check_instruction(x"00219463", "Desvio se diferente x3,x2,8");
        
        -- Teste 27: Salto e liga x19,8
        check_instruction(x"00800973", "Salto e liga x19,8");
        
        -- Teste 28: Salto e liga registrador x20,x6,0
        check_instruction(x"000300A7", "Salto e liga registrador x20,x6,0");
        
        -- Aguarda alguns ciclos para finalizar a execução
        wait for PERIODO*10;
        
        -- Finalização da simulação
        wait for PERIODO * 2;
        stop_clock <= true;
        
        -- Relata status final do teste
        if test_status then
            report "Todos os testes passaram" severity note;
        else
            report "Alguns testes falharam" severity error;
        end if;
        
        wait;
    end process;
    
end architecture;