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

MacOS:
```bash
# Use recent version of clang and provide FileCheck tool
brew install llvm
# riscv-gnu-toolchain dependencies
brew install python3 gawk gnu-sed flock texinfo gmp isl libmpc mpfr zstd
# Install gnu tools
brew install coreutils make
```

Fedora/RHEL:
```bash
dnf install llvm # Provides FileCheck tool
# riscv-gnu-toolchain dependencies
dnf install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

## Build

On MacOS:
```bash
# Provide FileCheck
export PATH="$PATH:/opt/homebrew/opt/llvm/bin"
```

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
