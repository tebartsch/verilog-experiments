#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Varbiter.h"

#define MAX_SIM_TIME 25
#define TESTBENCH_START_TIME 2

vluint64_t sim_time = 0;

void testbench(Varbiter *dut, vluint64_t sim_time) {
  if (sim_time < TESTBENCH_START_TIME)
    return;

  vluint64_t step = sim_time - TESTBENCH_START_TIME;

  if (step <= 1) {
    dut->request_0 = 1;
    dut->request_1 = 1;
  }
  else if (step <= 5) {
    dut->request_0 = 0;
    dut->request_1 = 1;
  }
  else if (step <= 9) {
    dut->request_0 = 1;
    dut->request_1 = 1;
  } 
  else if (step <= 12) {
    dut->request_0 = 1;
    dut->request_1 = 0;
  }
  else if (step <= 16) {
    dut->reset = 1;
  }
  else if (step <= 23) {
    dut->reset = 0;
  }

}

int main(int argc, char** argv, char** env)  {
  Verilated::commandArgs(argc, argv);
  Varbiter *dut = new Varbiter;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, /*levels=*/5);
  m_trace->open("arbiter.vcd");

  while (sim_time < MAX_SIM_TIME) {
    dut->clock ^= 1;

    dut->eval();
    testbench(dut, sim_time);
    m_trace->dump(sim_time);

    sim_time++;
  }

  m_trace->close();
  delete dut;
  exit(EXIT_SUCCESS);
}
