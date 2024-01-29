// originally based on
// https://github.com/n-kremeris/verilator_basics/blob/main/tb_alu.cpp (MIT
// License)

#include "verilator_common.h"

#include "Valu.h"
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

#define MAX_SIM_TIME 50
#define RESET_START 2
#define RESET_END 5
#define VERIFICATION_START_TIME 10

vluint64_t sim_time = 0;

//===----------------------------------------------------------------------===//
// Transactions
//===----------------------------------------------------------------------===//

struct AluInTx {
  bool r_i_s_instr_types;
  uint32_t funct3;
  uint32_t a;
  uint32_t b;
};

struct AluOutTx {
  uint32_t out;
};

//===----------------------------------------------------------------------===//
// Scoreboard
//===----------------------------------------------------------------------===//

class AluScb {
private:
  std::deque<AluInTx *> in_q;
  int error_count = 0;

public:
  int get_error_count() { return error_count; }

  void writeIn(AluInTx *tx) { in_q.push_back(tx); }

  void writeOut(AluOutTx *tx) {
    if (in_q.empty()) {
      std::cerr << "Fatal Error in AluScb: empty AluInTx queue" << std::endl;
      exit(1);
    }

    AluInTx *in;
    in = in_q.front();
    in_q.pop_front();

    if (in->r_i_s_instr_types) {
      switch (in->funct3) {
      case 0b001:
        if (in->a << in->b != tx->out) {
          std::cerr << std::endl;
          std::cerr << "AluScb: << mismatch" << std::endl;
          std::cerr << "  Expected: " << (in->a & in->b)
                    << "  Actual: " << tx->out << std::endl;
          std::cerr << "  Simtime: " << sim_time << std::endl;
          error_count++;
        }
      case 0b111:
        if (in->a & in->b != tx->out) {
          std::cerr << std::endl;
          std::cerr << "AluScb: & mismatch" << std::endl;
          std::cerr << "  Expected: " << (in->a & in->b)
                    << "  Actual: " << tx->out << std::endl;
          std::cerr << "  Simtime: " << sim_time << std::endl;
          error_count++;
        }
      default:
        if (in->a + in->b != tx->out) {
          std::cerr << std::endl;
          std::cerr << "AluScb: add mismatch" << std::endl;
          std::cerr << "  Expected: " << in->a + in->b
                    << "  Actual: " << tx->out << std::endl;
          std::cerr << "  Simtime: " << sim_time << std::endl;
          error_count++;
        }
      }
    } else {
      if (in->a + in->b != tx->out) {
        std::cerr << std::endl;
        std::cerr << "AluScb: default op (add) mismatch" << std::endl;
        std::cerr << "  Expected: " << in->a + in->b << "  Actual: " << tx->out
                  << std::endl;
        std::cerr << "  Simtime: " << sim_time << std::endl;
        error_count++;
      }
    }

    delete in;
    delete tx;
  }
};

//===----------------------------------------------------------------------===//
// Drivers
//===----------------------------------------------------------------------===//

class AluInDrv {
private:
  Valu *dut;

public:
  AluInDrv(Valu *dut) : dut(dut) {}

  void drive(AluInTx *tx) {
    dut->in_valid = 0;
    if (tx != NULL) {
      dut->in_valid = 1;
      dut->a_in = tx->a;
      dut->b_in = tx->b;
      delete tx;
    }
  }
};

//===----------------------------------------------------------------------===//
// Monitors
//===----------------------------------------------------------------------===//

class AluInMon {
private:
  Valu *dut;
  AluScb *scb;

public:
  AluInMon(Valu *dut, AluScb *scb) : dut(dut), scb(scb) {}

  void monitor() {
    if (dut->in_valid == 1) {
      AluInTx *tx = new AluInTx{.r_i_s_instr_types =
                                    static_cast<bool>(dut->r_i_s_instr_types),
                                .funct3 = dut->funct3,
                                .a = dut->a_in,
                                .b = dut->b_in};
      scb->writeIn(tx);
    }
  }
};

class AluOutMon {
private:
  Valu *dut;
  AluScb *scb;

public:
  AluOutMon(Valu *dut, AluScb *scb) : dut(dut), scb(scb) {}

  void monitor() {
    if (dut->out_valid == 1) {
      AluOutTx *tx = new AluOutTx();
      tx->out = dut->out;
      scb->writeOut(tx);
    }
  }
};

//===----------------------------------------------------------------------===//
// Random Input transaction generation
//===----------------------------------------------------------------------===//

AluInTx *rndAluInTx() {
  // 20% chance of generating a transaction
  if (rand() % 5 == 0) {
    AluInTx *tx = new AluInTx();
    tx->a = rand() % 11 + 10; // generate a in range 10-20
    tx->b = rand() % 6;       // generate b in range 0-5
    return tx;
  } else {
    return NULL;
  }
}

void dut_reset(Valu *dut) {
  dut->rst = 1;
  dut->a_in = 0;
  dut->b_in = 0;
  dut->in_valid = 0;
}

int main(int argc, char **argv, char **env) {
  std::string vcd_path = get_vcd_path(argc, argv);
  bool dump_vcd = vcd_path != "";

  Verilated::commandArgs(argc, argv);
  Valu *dut = new Valu;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  if (dump_vcd) {
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open(vcd_path.c_str());
  }

  AluInDrv *drv = new AluInDrv(dut);
  AluScb *scb = new AluScb();
  AluInMon *inMon = new AluInMon(dut, scb);
  AluOutMon *outMon = new AluOutMon(dut, scb);

  while (sim_time < MAX_SIM_TIME) {
    // Reset dut before starting tests
    if (RESET_START <= sim_time && sim_time < RESET_END)
      dut_reset(dut);
    else
      dut->rst = 0;

    // Evaluate next cycle
    dut->clk ^= 1;
    dut->eval();

    // UVM-style verification
    if (dut->clk == 1 && sim_time >= VERIFICATION_START_TIME) {
      AluInTx *tx = rndAluInTx();
      drv->drive(tx);
      inMon->monitor();
      outMon->monitor();
    }

    if (dump_vcd)
      m_trace->dump(sim_time);
    sim_time++;
  }

  int error_count = scb->get_error_count();

  if (dump_vcd)
    m_trace->close();

  delete dut;
  delete outMon;
  delete inMon;
  delete scb;
  delete drv;

  return error_count > 0 ? EXIT_FAILURE : EXIT_SUCCESS;
}
