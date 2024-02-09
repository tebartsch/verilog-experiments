# verilog-experiments

## Dependecnies

- `verilator`

  Install on MacOS using homebrew
  ```bash
  brew install verilator
  ```

  Install on Fedora/RHEL with
  ```bash
  dnf install verilator
  ```

- `surfer`
   
  A waveform viewer that can be installed with
  ```bash
  # Install rust on MacOS using homebrew
  brew install rust
  # On Linux install with rustup (https://rustup.rs/)
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # Install surfer using cargo
  cargo install \
  --git https://gitlab.com/surfer-project/surfer \
  --rev bfa7b6d603e6d8b160859dd4fdf668742371f4c8 \
  surfer
  ```

## Interesting links

 - [verilog-reg-verilog-wire-systemverilog-logic](https://www.verilogpro.com/verilog-reg-verilog-wire-systemverilog-logic/)

 - [verilator_basics](https://github.com/n-kremeris/verilator_basics/tree/main)
   Verilog tutorial by [Nikos Kremeris](http://itsembedded.com/) including
   template for UVM style verification.

 - [hdlbits verilog tutorial](https://hdlbits.01xz.net/wiki/Main_Page)
 