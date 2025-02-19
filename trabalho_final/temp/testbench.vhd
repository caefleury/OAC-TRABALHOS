library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity testbench is
end entity;

architecture tb of testbench is
    -- Helper function for hex conversion
    function to_hex_string(slv : std_logic_vector) return string is
        variable l : line;
    begin
        hwrite(l, slv);
        return l.all;
    end function;

    -- Component declaration
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
            -- Debug outputs
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
    
    -- Clock period definitions
    constant PERIOD     : time := 20 ns;  -- Increased from 10ns to 20ns
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET     : time := 5 ns;
    
    -- Testbench signals
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';  
    signal stop_clock : boolean := false;
    
    -- Debug signals
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
    
    -- Test status
    signal test_status : boolean := true;
    
begin
    -- Instantiate the processor
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
    
    -- Clock generation
    clock_gen: process
    begin
        while not stop_clock loop
            wait for (PERIOD - (PERIOD * DUTY_CYCLE));
            clk <= not clk;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stimulus: process
        -- Helper procedures
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
                write(l, string'(" - Expected: 0x"));
                hwrite(l, expected_value);
                write(l, string'(" Got: 0x"));
                hwrite(l, actual_value);
                test_status <= false;
            end if;
            writeline(output, l);
            
            -- Print current PC and instruction for debugging
            write(l, string'("Current PC: 0x"));
            hwrite(l, debug_pc);
            write(l, string'(" Instruction: 0x"));
            hwrite(l, debug_inst);
            writeline(output, l);
            
            -- If there's a register write, show it
            if unsigned(debug_reg_write) /= 0 then
                write(l, string'("Register write value: 0x"));
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
            report "Starting Test: " & test_name;
            report "Instruction: 0x" & to_hex_string(instruction);
            
            -- First report current state before clock edge
            -- Report control signals
            report "Control Signals:";
            report "  Branch: " & std_logic'image(debug_branch);
            report "  MemRead: " & std_logic'image(debug_memread);
            report "  MemToReg: " & std_logic'image(debug_memtoreg);
            report "  ALUOp: " & integer'image(to_integer(unsigned(debug_aluop)));
            report "  MemWrite: " & std_logic'image(debug_memwrite);
            report "  ALUSrc: " & std_logic'image(debug_alusrc);
            report "  RegWrite: " & std_logic'image(debug_regwrite);
            report "  Jump: " & std_logic'image(debug_jump);
            
            -- Report register values
            report "Register Values:";
            report "  rs1 data: 0x" & to_hex_string(debug_rs1_data);
            report "  rs2 data: 0x" & to_hex_string(debug_rs2_data);
            report "  Immediate: 0x" & to_hex_string(debug_imm_value);
            
            -- Report PC and next PC
            report "PC: 0x" & to_hex_string(debug_pc);
            report "Next PC: 0x" & to_hex_string(debug_next_pc);
            
            -- Report ALU result
            report "ALU Result: 0x" & to_hex_string(debug_alu_result);
            
            -- Report Memory Data
            report "Memory Read Data: 0x" & to_hex_string(debug_mem_rdata);
            report "MemToReg Value: '" & std_logic'image(debug_memtoreg) & "'";

            
            -- Additional verification for specific instruction types
            case instruction(6 downto 0) is
                when "0110011" => -- R-type
                    report "R-type instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                when "0010011" | "0000011" => -- I-type (including load)
                    report "I-type instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31 downto 20))));
                when "0100011" => -- S-type
                    report "S-type instruction detected";
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31 downto 25) & instruction(11 downto 7))));
                when others =>
                    report "Other instruction type";
            end case;
            
            -- Now advance to next clock cycle
            wait until rising_edge(clk);
            wait for 1 ns;  -- Wait for signals to settle
            
            report "Test Complete: " & test_name;
            report "----------------------------------------";
        end procedure;
        
    begin
        -- Print test header
        report "Starting RISC-V Processor Tests";
        
        -- Assert reset for a few cycles
        wait for PERIOD * 2;
        rst <= '0';  
        
        -- Start testing instructions
        wait for PERIOD;  -- Wait one cycle to let signals stabilize
        
        -- Test 1: Check if PC starts at 0
        print_status("PC Initial Value Test", debug_pc = x"00000000", debug_pc, x"00000000");
        
        -- Test 2: Check first instruction (addi x2, x0, 5)
        check_instruction(x"00500113", "First ADDI Instruction Test");
        
        -- Test 3: Check second instruction (addi x3, x0, 3)
        check_instruction(x"00300193", "Second ADDI Instruction Test");
        
        -- Test 4: Check add instruction (add x3, x1, x2)
        check_instruction(x"002081b3", "ADD Instruction Test");
        
        -- Test 5: Check store instruction (sw x3, 4(x0))
        check_instruction(x"00302223", "Store Instruction Test");
        
        -- Test 6: Check load instruction (lw x6, 1(x0))
        check_instruction(x"00102303", "Load Instruction Test");
        
        -- Test 7: Check immediate for logical ops
        check_instruction(x"00800293", "ADDI for Logical Test");

        -- Test 8: Check AND instruction
        check_instruction(x"0062f333", "AND Instruction Test");

        -- Test 9: Check OR instruction
        check_instruction(x"0062e3b3", "OR Instruction Test");

        -- Test 10: Check XOR instruction
        check_instruction(x"0063c433", "XOR Instruction Test");

        -- Test 11: Check SLTI instruction
        check_instruction(x"0032a513", "SLTI Instruction Test");

        -- Test 12: Check store word instruction
        check_instruction(x"00402223", "Store Word Test");
        
        -- Test 13: Check load word instruction
        check_instruction(x"00008303", "Load Word Test");

        -- Test 14: Check SUB instruction
        check_instruction(x"40418133", "SUB Instruction Test");
        
        -- Test 15: Check SLT instruction
        check_instruction(x"0041a233", "SLT Instruction Test");
        
        -- Test 16: Check LUI instruction (lui x5, 1)
        check_instruction(x"000012b7", "LUI Instruction Test");
        
        -- Test 17: Check shift immediate (addi after lui)
        check_instruction(x"01428293", "ADDI after LUI Test");
        
        -- Test 18: Check AUIPC instruction (auipc x6, 1)
        check_instruction(x"00001337", "AUIPC Instruction Test");
        
        -- Test 19: Check add immediate after AUIPC
        check_instruction(x"00830313", "ADDI after AUIPC Test");
        
        -- Test 20: Check SLL instruction (sll x5, x5, x1)
        check_instruction(x"00129293", "SLL Instruction Test");
        
        -- Test 21: Check SRL instruction (srl x6, x6, x2)
        check_instruction(x"00235313", "SRL Instruction Test");
        
        -- Test 22: Check SRA immediate (srai x7, x6, 2)
        check_instruction(x"00231393", "SRAI Instruction Test");
        
        -- Test 23: Check SRA instruction (sra x7, x7, x2)
        check_instruction(x"402383b3", "SRA Instruction Test");
        
        -- Test 24: Check SLTU instruction (sltu x8, x7, x1)
        check_instruction(x"00139413", "SLTU Instruction Test");
        
        -- Test 25: Check SRL instruction (srl x9, x6, x2)
        check_instruction(x"00235493", "SRL Instruction Test");
        
        -- Test 26: Check SB instruction (sb x5, 0(x0))
        check_instruction(x"00502023", "SB Instruction Test");
        
        -- Test 27: Check LBU instruction (lbu x10, 4(x1))
        check_instruction(x"00408503", "LBU Instruction Test");
        
        -- Test 28: Check BEQ instruction (beq x2, x2, 2)
        check_instruction(x"00208263", "BEQ Instruction Test");
        
        -- Test 29: Check JAL instruction (jal x0, 0)
        check_instruction(x"0000006f", "JAL Instruction Test");
        
        -- Test 30: Check JALR instruction (jalr x0, x1, 0)
        check_instruction(x"00008067", "JALR Instruction Test");
        
        -- Allow some cycles for execution
        wait for PERIOD*10;
        
        -- End simulation
        wait for PERIOD * 2;
        stop_clock <= true;
        
        -- Report final test status
        if test_status then
            report "All tests passed!" severity note;
        else
            report "Some tests failed!" severity error;
        end if;
        
        wait;
    end process;
    
end architecture;