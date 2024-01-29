# nano-cpu

(Very) simple and unoptimized CPU written in Verilog.

Sources:

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

## Development

```bash
# Run program
make sw/<testname>-run
# Run program while dumping waveforms and open waveform viewer
make sw/<testname>-waves
# Run program and check output
make sw/<testname>
```

where `<testname>` is the name of the program in the `sw` directory, 
i.e. `addi`.
