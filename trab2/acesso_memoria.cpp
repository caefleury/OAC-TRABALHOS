#include <cstdio>
#include <cstdint>
#include <stdexcept>
#include "acesso_memoria.h"

#define MEM_SIZE 16384
int8_t mem[MEM_SIZE];

inline void check_bounds(int address, int size) {
    if (address < 0 || address + size > MEM_SIZE) {
        throw std::out_of_range("Acesso à memória fora dos limites");
    }
}

int32_t lb(int reg, int kte) {
    check_bounds(reg + kte, 1);
    int8_t byte = mem[reg + kte];
    return static_cast<int32_t>(byte); 
}

uint32_t lbu(int reg, int kte) {
    check_bounds(reg + kte, 1);
    return static_cast<uint32_t>(mem[reg + kte] & 0xFF);
}

int32_t lw(int reg, int kte) {
    check_bounds(reg + kte, 4);
    int32_t value = 0;
    for (int i = 0; i < 4; i++) {
        value |= static_cast<uint32_t>(mem[reg + kte + i] & 0xFF) << (i * 8);
    }
    return value;
}

void sb(int reg, int kte, int8_t byte) {
    check_bounds(reg + kte, 1);
    mem[reg + kte] = byte;
}

void sw(int reg, int kte, int32_t word) {
    check_bounds(reg + kte, 4);
    for (int i = 0; i < 4; i++) {
        mem[reg + kte + i] = static_cast<int8_t>((word >> (i * 8)) & 0xFF);
    }
}

int load_mem(const char* filename, int start) {
    FILE* fp = std::fopen(filename, "rb");
    if (!fp) return -1;

    std::fseek(fp, 0, SEEK_END);
    long size = std::ftell(fp);
    std::fseek(fp, 0, SEEK_SET);

    if (start < 0 || start + size > MEM_SIZE) {
        std::fclose(fp);
        return -1;
    }

    size_t read = std::fread(&mem[start], 1, size, fp);
    std::fclose(fp);

    return (read == static_cast<size_t>(size)) ? 0 : -1;
}