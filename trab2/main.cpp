#include <iostream>
#include <cstdint>
#include <cstdlib>
#include <string>
#include "globals.h"
#include "acesso_memoria.h"

// Global variables (defined in globals.h as extern)
extern uint32_t pc;      // Program Counter
extern uint32_t ri;      // Instruction Register
extern uint32_t sp;      // Stack Pointer
extern uint32_t gp;      // Global Pointer
extern instruction_context_st instr_info;

// Function declarations
void print_menu();

int main() {
    // Initialize registers
    init_registers();

    // Initialize other components
    init();

    // Load program and data into memory
    if (load_mem("code.bin", 0) != 0) {
        std::cerr << "Erro ao carregar code.bin" << std::endl;
        return 1;
    }
    if (load_mem("data.bin", 0x2000) != 0) {
        std::cerr << "Erro ao carregar data.bin" << std::endl;
        return 1;
    }

    std::cout << "Simulador RV32I" << std::endl;
    std::cout << "---------------" << std::endl;

    char choice;
    bool running = true;
    while (running) {
        print_menu();
        std::cin >> choice;
        
        switch (choice) {
            case 's':
            case 'S':
                step();
                break;
            case 'r':
            case 'R':
                run();
                break;
            case 'q':
            case 'Q':
                running = false;
                break;
            default:
                std::cout << "Opção inválida!" << std::endl;
        }
    }

    return 0;
}

void print_menu() {
    std::cout << "\nComandos:" << std::endl;
    std::cout << "s - Passo (executa uma instrução)" << std::endl;
    std::cout << "r - Executar (executa até terminar)" << std::endl;
    std::cout << "q - Sair" << std::endl;
    std::cout << "Escolha: ";
}