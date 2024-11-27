#ifndef __ACESSO_MEMORIA_H__
#define __ACESSO_MEMORIA_H__

#include <stdint.h>

int32_t lb(int reg, int kte);
uint32_t lbu(int reg, int kte);
int32_t lw(int reg, int kte);
void sb(int reg, int kte, int8_t byte);
void sw(int reg, int kte, int32_t word);

#endif // __ACESSO_MEMORIA_H__
