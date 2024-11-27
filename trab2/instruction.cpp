#include "globals.h"
#include <iomanip>
#include "acesso_memoria.h"

string iformat_str[8] = {
    "RType", "IType", "SType", "SBType", "UType", "UJType", "NullFormat", "NOPType"
};

string instr_str[39] = {
    "add", "addi", "and", "andi", "auipc", "beq", "bge", "bgeu", "blt", "bltu", "bne",
    "jal", "jalr", "lb", "lbu", "lh", "lhu", "lui", "lw", "or", "ori", "sb", "sh",
    "sll", "slli", "slt", "slti", "sltiu", "sltu", "sra", "srai", "srl", "srli",
    "sub", "sw", "xor", "xori", "ecall", "nop"
};

INSTRUCTIONS get_instr_code(uint32_t opcode, uint32_t func3, uint32_t func7) {
    switch(opcode) {
        case RegType:
            switch(func3) {
                case ADDSUB3:
                    return (func7 == ADD7) ? I_add : I_sub;
                case AND3:
                    return I_and;
                case OR3:
                    return I_or;
                case XOR3:
                    return I_xor;
                case SLL3:
                    return I_sll;
                case SR3:
                    return (func7 == SRA7) ? I_sra : I_srl;
                case SLT3:
                    return I_slt;
                case SLTU3:
                    return I_sltu;
            }
            break;
            
        case ILAType:
            switch(func3) {
                case ADDI3:
                    return I_addi;
                case ANDI3:
                    return I_andi;
                case ORI3:
                    return I_ori;
                case XORI3:
                    return I_xori;
                case SLLI3:
                    return I_slli;
                case SRI3:
                    return (func7 == SRAI7) ? I_srai : I_srli;
                case SLTI3:
                    return I_slti;
                case SLTIU3:
                    return I_sltiu;
            }
            break;
            
        case ILType:
            switch(func3) {
                case LB3:
                    return I_lb;
                case LW3:
                    return I_lw;
                case LBU3:
                    return I_lbu;
            }
            break;
            
        case StoreType:
            switch(func3) {
                case SB3:
                    return I_sb;
                case SW3:
                    return I_sw;
            }
            break;
            
        case BType:
            switch(func3) {
                case BEQ3:
                    return I_beq;
                case BNE3:
                    return I_bne;
                case BLT3:
                    return I_blt;
                case BGE3:
                    return I_bge;
                case BLTU3:
                    return I_bltu;
                case BGEU3:
                    return I_bgeu;
            }
            break;
            
        case JAL:
            return I_jal;
        case JALR:
            return I_jalr;
        case LUI:
            return I_lui;
        case AUIPC:
            return I_auipc;
        case ECALL:
            return I_ecall;
    }
    return I_nop;
}

FORMATS get_i_format(uint32_t opcode, uint32_t func3, uint32_t func7) {
    switch(opcode) {
        case RegType: return RType;
        case ILAType: return IType;
        case StoreType: return SType;
        case BType: return SBType;
        case LUI:
        case AUIPC: return UType;
        case JAL: return UJType;
        default: return NullFormat;
    }
}

void fetch(instruction_context_st& ic) {
    ic.ir = lw(pc, 0);
    ic.pc = pc;
    pc += 4;
}

void print_instr(instruction_context_st& ic) {
    std::cout << std::hex << std::setfill('0')
              << "PC: 0x" << std::setw(8) << ic.pc
              << " IR: 0x" << std::setw(8) << ic.ir
              << " Formato: " << iformat_str[ic.ins_format]
              << " Instrução: " << instr_str[ic.ins_code]
              << std::endl;
}

void execute(instruction_context_st& ic) {
    switch(ic.ins_code) {
        case I_add:
            breg[ic.rd] = breg[ic.rs1] + breg[ic.rs2];
            break;
        case I_sub:
            breg[ic.rd] = breg[ic.rs1] - breg[ic.rs2];
            break;
        case I_and:
            breg[ic.rd] = breg[ic.rs1] & breg[ic.rs2];
            break;
        case I_or:
            breg[ic.rd] = breg[ic.rs1] | breg[ic.rs2];
            break;
        case I_xor:
            breg[ic.rd] = breg[ic.rs1] ^ breg[ic.rs2];
            break;
        case I_sll:
            breg[ic.rd] = breg[ic.rs1] << breg[ic.rs2];
            break;
        case I_srl:
            breg[ic.rd] = (uint32_t)breg[ic.rs1] >> breg[ic.rs2];
            break;
        case I_sra:
            breg[ic.rd] = breg[ic.rs1] >> breg[ic.rs2];
            break;
        case I_slt:
            breg[ic.rd] = (breg[ic.rs1] < breg[ic.rs2]) ? 1 : 0;
            break;
        case I_sltu:
            breg[ic.rd] = ((uint32_t)breg[ic.rs1] < (uint32_t)breg[ic.rs2]) ? 1 : 0;
            break;
            
        case I_addi:
            breg[ic.rd] = breg[ic.rs1] + ic.imm12_i;
            break;
        case I_andi:
            breg[ic.rd] = breg[ic.rs1] & ic.imm12_i;
            break;
        case I_ori:
            breg[ic.rd] = breg[ic.rs1] | ic.imm12_i;
            break;
        case I_xori:
            breg[ic.rd] = breg[ic.rs1] ^ ic.imm12_i;
            break;
        case I_slli:
            breg[ic.rd] = breg[ic.rs1] << ic.shamt;
            break;
        case I_srli:
            breg[ic.rd] = (uint32_t)breg[ic.rs1] >> ic.shamt;
            break;
        case I_srai:
            breg[ic.rd] = breg[ic.rs1] >> ic.shamt;
            break;
        case I_slti:
            breg[ic.rd] = (breg[ic.rs1] < ic.imm12_i) ? 1 : 0;
            break;
        case I_sltiu:
            breg[ic.rd] = ((uint32_t)breg[ic.rs1] < (uint32_t)ic.imm12_i) ? 1 : 0;
            break;
            
        case I_lb:
            breg[ic.rd] = lb(breg[ic.rs1], ic.imm12_i);
            break;
        case I_lw:
            breg[ic.rd] = lw(breg[ic.rs1], ic.imm12_i);
            break;
        case I_lbu:
            breg[ic.rd] = lbu(breg[ic.rs1], ic.imm12_i);
            break;
            
        case I_sb:
            sb(breg[ic.rs1], ic.imm12_s, breg[ic.rs2]);
            break;
        case I_sw:
            sw(breg[ic.rs1], ic.imm12_s, breg[ic.rs2]);
            break;
            
        case I_beq:
            if (breg[ic.rs1] == breg[ic.rs2]) pc = ic.pc + ic.imm13;
            break;
        case I_bne:
            if (breg[ic.rs1] != breg[ic.rs2]) pc = ic.pc + ic.imm13;
            break;
        case I_blt:
            if (breg[ic.rs1] < breg[ic.rs2]) pc = ic.pc + ic.imm13;
            break;
        case I_bge:
            if (breg[ic.rs1] >= breg[ic.rs2]) pc = ic.pc + ic.imm13;
            break;
        case I_bltu:
            if ((uint32_t)breg[ic.rs1] < (uint32_t)breg[ic.rs2]) pc = ic.pc + ic.imm13;
            break;
        case I_bgeu:
            if ((uint32_t)breg[ic.rs1] >= (uint32_t)breg[ic.rs2]) pc = ic.pc + ic.imm13;
            break;
            
        case I_jal:
            breg[ic.rd] = pc;
            pc = ic.pc + ic.imm21;
            break;
        case I_jalr:
            breg[ic.rd] = pc;
            pc = (breg[ic.rs1] + ic.imm12_i) & ~1;
            break;
            
        case I_lui:
            breg[ic.rd] = ic.imm20_u << 12;
            break;
        case I_auipc:
            breg[ic.rd] = ic.pc + (ic.imm20_u << 12);
            break;
            
        case I_ecall:
            exit(0);
            break;
            
        default:
            std::cerr << "Instrução não implementada: " << instr_str[ic.ins_code] << std::endl;
            break;
    }
}
