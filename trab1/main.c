#include <stdio.h>
#include <stdint.h>

#define MEM_SIZE 16384
int8_t mem[MEM_SIZE];


int32_t lb(int reg, int kte) {
    int8_t byte = mem[reg + kte];
    return (int32_t)byte; 
}

uint32_t lbu(int reg, int kte) {
    return (uint32_t)(mem[reg + kte] & 0xFF);
}

int32_t lw(int reg, int kte) {
    int32_t value = 0;
    for (int i = 0; i < 4; i++) {
        value |= ((uint32_t)(mem[reg + kte + i] & 0xFF) << (i * 8));
    }
    return value;
}

void sb(int reg, int kte, int8_t byte) {
    mem[reg + kte] = byte;
}

void sw(int reg, int kte, int32_t word) {
    for (int i = 0; i < 4; i++) {
        mem[reg + kte + i] = (int8_t)((word >> (i * 8)) & 0xFF);
    }
}

int main() {
    sw(0, 0, 0xABACADEF);
    sb(4, 0, 1);
    sb(4, 1, 2);
    sb(4, 2, 3);
    sb(4, 3, 4);
    
    printf("Respostas: \n\n");
    printf("a. 0x%08x\n", lw(0, 0));
    printf("b. 0x%08x\n", lb(0, 0));
    printf("c. 0x%08x\n", lb(0, 1));
    printf("d. 0x%08x\n", lb(0, 2));
    printf("e. 0x%08x\n", lb(0, 3));
    printf("f. 0x%02x\n", lbu(0, 0));
    printf("g. 0x%02x\n", lbu(0, 1));
    printf("h. 0x%02x\n", lbu(0, 2));
    printf("i. 0x%02x\n", lbu(0, 3));
    
    
    return 0;
}
