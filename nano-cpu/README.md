# nano-cpu

(Very) simple and unoptimized CPU written in Verilog.

Sources:

 - [verilator_basics](https://github.com/n-kremeris/verilator_basics/tree/main)
   Verilog tutorial by [Nikos Kremeris](http://itsembedded.com/) including
   template for UVM style verification.

 - [hdlbits verilog tutorial](https://hdlbits.01xz.net/wiki/Main_Page)
 
 - [build cpu notes](https://github.com/hughperkins/cpu-tutorial)

 - [ataradov/riscv](https://github.com/ataradov/riscv) very simple RISC-V CPU
   core in Verilog

 - [ultraembedded/riscv](https://github.com/ultraembedded/riscv)
   complex RISC-V CPU core in Verilog

 - [RISC-V Reference Data Card ("Green Card")](https://inst.eecs.berkeley.edu/~cs61c/fa17/img/riscvcard.pdf)

 - Patterson and Hennessy, Computer Organization and Design: The Hardware/Software Interface RISC-V Edition

## Packages

Fedora/RHEL:

```bash
dnf install verilator
dnf install llvm # Provides FileCheck tool
```

## Build

```bash
# This builds the verilator simulation executable of the processor as well as
# a riscv toolchain used to compile test programs.
make --jobs=<jobs>
# Run all tests
make test
```
