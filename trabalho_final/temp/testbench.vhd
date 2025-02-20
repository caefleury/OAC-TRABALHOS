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
                when "0110011" => -- R
                    report "R-type instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                when "0010011" | "0000011" => -- I
                    report "I-type instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31 downto 20))));
                when "0100011" => -- S
                    report "S-type instruction detected";
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31 downto 25) & instruction(11 downto 7))));
                when "1100011" => -- B
                    report "B-type instruction detected";
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  rs2: x" & integer'image(to_integer(unsigned(instruction(24 downto 20))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0')));
                when "0110111" => -- LUI
                    report "LUI instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  imm: 0x" & to_hex_string(instruction(31 downto 12) & x"000");
                when "0010111" => -- AUIPC
                    report "AUIPC instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  imm: 0x" & to_hex_string(instruction(31 downto 12) & x"000");
                when "1101111" => -- JAL
                    report "JAL instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0')));
                when "1100111" => -- JALR
                    report "JALR instruction detected";
                    report "  rd: x" & integer'image(to_integer(unsigned(instruction(11 downto 7))));
                    report "  rs1: x" & integer'image(to_integer(unsigned(instruction(19 downto 15))));
                    report "  imm: " & integer'image(to_integer(signed(instruction(31 downto 20))));
                when others =>
                    report "Unknown instruction type: " & to_hex_string(instruction);
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
        
        -- Test 1: Check first ADDI instruction (x5 = 5)
        check_instruction(x"00500293", "First ADDI Test");
        
        -- Test 2: Check second ADDI instruction (x6 = 10)
        check_instruction(x"00A00313", "Second ADDI Test");
        
        -- Test 3: Check third ADDI instruction (x7 = 15)
        check_instruction(x"00F00393", "Third ADDI Test");
        
        -- Test 4: Check fourth ADDI instruction (x8 = 20)
        check_instruction(x"01400413", "Fourth ADDI Test");
        
        -- Test 5: Check fifth ADDI instruction (x9 = 25)
        check_instruction(x"01900493", "Fifth ADDI Test");
        
        -- Test 6: Check LUI instruction
        check_instruction(x"00001537", "LUI Test");
        
        -- Test 7: Check ADD instruction
        check_instruction(x"004282B3", "ADD Test");
        
        -- Test 8: Check SUB instruction
        check_instruction(x"40730633", "SUB Test");
        
        -- Test 9: Check AND instruction
        check_instruction(x"0062F6B3", "AND Test");
        
        -- Test 10: Check OR instruction
        check_instruction(x"0064E733", "OR Test");
        
        -- Test 11: Check XOR instruction
        check_instruction(x"0065C7B3", "XOR Test");
        
        -- Test 12: Check SLT instruction
        check_instruction(x"0067A833", "SLT Test");
        
        -- Test 13: Check SLL instruction
        check_instruction(x"00532893", "SLL Test");
        
        -- Test 14: Check SRL instruction
        check_instruction(x"0053D913", "SRL Test");
        
        -- Test 15: Check SRA instruction
        check_instruction(x"4074D993", "SRA Test");
        
        -- Test 16: Check SLTU instruction
        check_instruction(x"0023AA13", "SLTU Test");
        
        -- Test 17: Check SLTI instruction
        check_instruction(x"0033BA93", "SLTI Test");
        
        -- Test 18: Check SW instruction
        check_instruction(x"00802023", "SW Test");
        
        -- Test 19: Check SB instruction
        check_instruction(x"00902223", "SB Test");
        
        -- Test 20: Check LW instruction
        check_instruction(x"00102B03", "LW Test");
        
        -- Test 21: Check LB instruction
        check_instruction(x"00101B83", "LB Test");
        
        -- Test 22: Check LBU instruction
        check_instruction(x"00101C03", "LBU Test");
        
        -- Test 23: Check AUIPC instruction
        check_instruction(x"00000597", "AUIPC Test");
        
        -- Test 24: Check JAL instruction
        check_instruction(x"008000EF", "JAL Test");
        
        -- Test 25: Check JALR instruction
        check_instruction(x"00458593", "JALR Test");
        
        -- Test 26: Check BEQ instruction
        check_instruction(x"00228463", "BEQ Test");
        
        -- Test 27: Check NOP instruction
        check_instruction(x"00000013", "NOP Test");
        
        -- Test 28: Check Return JALR instruction
        check_instruction(x"00008067", "Return JALR Test");
        
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