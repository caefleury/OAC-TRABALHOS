#include "globals.h"

// Global variables
uint32_t pc;      // Program Counter
uint32_t ri;      // Instruction Register
uint32_t sp;      // Stack Pointer
uint32_t gp;      // Global Pointer
int32_t breg[32]; // Bank of 32 registers

// Decode stage globals
uint32_t opcode, rs2, rs1, rd;
uint32_t shamt, funct3, funct7;
int32_t imm12_i, imm12_s, imm13, imm20_u, imm21;

// Register strings
string reg_str[32] = {
    "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void init_registers() {
    pc = 0x00000000;
    sp = 0x00003ffc;
    gp = 0x00001800;
    ri = 0x00000000;
    
    // Initialize all registers to 0
    for(int i = 0; i < 32; i++) {
        breg[i] = 0;
    }
    
    // Set special registers
    breg[2] = sp;  // sp
    breg[3] = gp;  // gp
}
