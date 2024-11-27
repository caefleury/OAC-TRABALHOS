#include "globals.h"
#include <iomanip>

void init() {
    init_registers();
}

void step() {
    fetch(instr_info);
    decode(instr_info);
    execute(instr_info);
    
    std::cout << std::hex << std::setfill('0')
              << "PC: 0x" << std::setw(8) << pc
              << " IR: 0x" << std::setw(8) << ri << std::endl;
    print_instr(instr_info);
}

void run() {
    while (true) {
        step();
        
        if (pc >= DATA_SEGMENT_START) {
            std::cout << "Contador de programa excedeu o segmento de código" << std::endl;
            break;
        }
    }
}
