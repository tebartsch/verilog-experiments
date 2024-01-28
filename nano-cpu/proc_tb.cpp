#include "verilator_common.h"

#include "Vproc.h"
#include "Vproc_proc.h"

#include <fstream>
#include <iostream>
#include <iterator>
#include <verilated.h>
#include <verilated_vcd_c.h>

#define MAX_SIM_TIME 200
#define RESET_START 2
#define RESET_END 5
#define VERIFICATION_START_TIME 10

vluint64_t sim_time = 0;

std::string get_instructions_path(int &argc, char **&argv) {
  std::string instructions_path;
  for (int idx = 0; idx < argc; idx++) {
    std::string str = std::string(argv[idx]);
    std::string find_str = "--instructions=";
    auto pos = str.find(find_str);
    if (pos == 0) {
      instructions_path = str.substr(find_str.length(), std::string::npos);
    }
  }
  return instructions_path;
}

bool get_dump_final_register_state(int &argc, char **&argv) {
  for (int idx = 0; idx < argc; idx++) {
    std::string str = std::string(argv[idx]);
    if (str == "--dump-final-register-state")
      return true;
  }
  return false;
}

void dut_load_instr_mem(Vproc *dut, std::string filename) {
  FILE *file = fopen(filename.c_str(), "rb");
  if (!file)
    throw std::invalid_argument("Could not open file '" + filename + "'");

  fseek(file, 0L, SEEK_END);
  int file_size = ftell(file);
  rewind(file);

  if (file_size % 4 != 0)
    throw std::invalid_argument("Instructions File '" + filename +
                                "' does not contain a multiple of 4 bytes");

  uint32_t word = 0;
  for (int i = 0; i < file_size / 4; i += 1) {
    fread(&word, sizeof(uint32_t), 1, file);
    dut->instruction_memory[i] = word;
  }

  for (int i = file_size; i < 1024; i++)
    dut->instruction_memory[i] = 0;
}

int main(int argc, char **argv, char **env) {
  std::string vcd_path = get_vcd_path(argc, argv);
  bool dump_vcd = vcd_path != "";
  std::string instructions_path = get_instructions_path(argc, argv);
  bool dump_final_register_state = get_dump_final_register_state(argc, argv);

  Verilated::commandArgs(argc, argv);
  Vproc *dut = new Vproc;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  if (dump_vcd) {
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open(vcd_path.c_str());
  }

  if (instructions_path != "none")
    dut_load_instr_mem(dut, instructions_path);

  while (sim_time < MAX_SIM_TIME) {
    // Reset dut before starting tests
    if (RESET_START <= sim_time && sim_time < RESET_END)
      dut->rst = 1;
    else
      dut->rst = 0;

    // Evaluate next cycle
    dut->clk ^= 1;
    dut->eval();

    if (dump_vcd)
      m_trace->dump(sim_time);
    sim_time++;
  }

  if (dump_vcd)
    m_trace->close();

  if (dump_final_register_state) {
    VlWide<31> registers;
    dut->proc->get_registers(registers);
    std::cout << std::hex;
    std::cout << "ra = 0x" << registers.at(0) << "\n";
    std::cout << "sp = 0x" << registers.at(1) << "\n";
    std::cout << "gp = 0x" << registers.at(2) << "\n";
    std::cout << "tp = 0x" << registers.at(3) << "\n";
    std::cout << "t0 = 0x" << registers.at(4) << "\n";
    std::cout << "t1 = 0x" << registers.at(5) << "\n";
    std::cout << "t2 = 0x" << registers.at(6) << "\n";
    std::cout << "s0 = 0x" << registers.at(7) << "\n";
    std::cout << "s1 = 0x" << registers.at(8) << "\n";
    std::cout << "a0 = 0x" << registers.at(9) << "\n";
    std::cout << "a1 = 0x" << registers.at(10) << "\n";
    std::cout << "a2 = 0x" << registers.at(11) << "\n";
    std::cout << "a3 = 0x" << registers.at(12) << "\n";
    std::cout << "a4 = 0x" << registers.at(13) << "\n";
    std::cout << "a5 = 0x" << registers.at(14) << "\n";
    std::cout << "a6 = 0x" << registers.at(15) << "\n";
    std::cout << "a7 = 0x" << registers.at(16) << "\n";
    std::cout << "s2 = 0x" << registers.at(17) << "\n";
    std::cout << "s3 = 0x" << registers.at(18) << "\n";
    std::cout << "s4 = 0x" << registers.at(19) << "\n";
    std::cout << "s5 = 0x" << registers.at(20) << "\n";
    std::cout << "s6 = 0x" << registers.at(21) << "\n";
    std::cout << "s7 = 0x" << registers.at(22) << "\n";
    std::cout << "s8 = 0x" << registers.at(23) << "\n";
    std::cout << "s9 = 0x" << registers.at(24) << "\n";
    std::cout << "s10 = 0x" << registers.at(25) << "\n";
    std::cout << "s11 = 0x" << registers.at(26) << "\n";
    std::cout << "t3 = 0x" << registers.at(27) << "\n";
    std::cout << "t4 = 0x" << registers.at(28) << "\n";
    std::cout << "t5 = 0x" << registers.at(29) << "\n";
    std::cout << "t6 = 0x" << registers.at(30) << "\n";
    std::cout << std::dec;
  }

  return EXIT_SUCCESS;
}
