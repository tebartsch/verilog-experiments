#include "Vproc.h"
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

#define MAX_SIM_TIME 50
#define RESET_START 2
#define RESET_END 5
#define VERIFICATION_START_TIME 10

vluint64_t sim_time = 0;

void dut_reset(Vproc *dut) { dut->rst = 1; }

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  Vproc *dut = new Vproc;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, /*levels=*/5);
  m_trace->open("proc.vcd");

  while (sim_time < MAX_SIM_TIME) {
    // Reset dut before starting tests
    if (RESET_START <= sim_time && sim_time < RESET_END)
      dut_reset(dut);
    else
      dut->rst = 0;

    // Evaluate next cycle
    dut->clk ^= 1;
    dut->eval();

    m_trace->dump(sim_time);
    sim_time++;
  }

  m_trace->close();

  return EXIT_SUCCESS;
}
