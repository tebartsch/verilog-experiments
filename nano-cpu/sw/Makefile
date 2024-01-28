# Disable implicit rules
.SUFFIXES:

RISCV := $(abspath riscv-tools)

SOURCES = $(wildcard *.S)

# Waveform files are always regnerated when needed)
WAVES := $(addprefix waves/, $(SOURCES:.S=.vcd))
PROGRAM_ELFS := $(addprefix build/, $(SOURCES:.S=.elf))
PROGRAM_IMGS := $(addprefix build/, $(SOURCES:.S=.img))

all: $(PROGRAM_ELFS) $(PROGRAM_IMGS) $(WAVES)

test: $(SOURCES:.S=-test)

vcd-files: $(SOURCES:.S=-waves)

build/%.elf: %.S
	@mkdir -p build
	$(RISCV)/bin/riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o $@ $< 

build/%.img: build/%.elf
	$(RISCV)/bin/riscv32-unknown-elf-objcopy -O binary $< $@

waves/%.vcd: build/%.img proc-run
	@mkdir -p waves
	./proc-run \
	  --vcd-path=waves/$*.vcd \
	  --instructions=build/$*.img

%-run: build/%.img proc-run
	./proc-run \
	  --instructions=build/$*.img \
	  --dump-final-register-state

%-test: build/%.img proc-run
	./proc-run \
	  --instructions=build/$*.img \
	  --dump-final-register-state \
	  | FileCheck $*.S

%-waves: waves/%.vcd
	surfer --command-file surfer_commands $<

proc-run:
	$(error The 'proc-run' binary is provided by the top-level Makefile)

.PHONY: clean
clean:
	rm -rf *.elf *.img waves build
