# Disable implicit rules
.SUFFIXES:

RISCV := $(abspath riscv-tools)

ASSEMBLY_SOURCES = $(wildcard *.S)
C_SOURCES = $(wildcard *.c)

SOURCES = $(ASSEMBLY_SOURCES) $(C_SOURCES)

# Waveform files are always regnerated when needed)
WAVES := $(addprefix waves/, $(addsuffix .vcd, $(SOURCES)))
PROGRAM_ELFS := $(addprefix build/, $(addsuffix .elf, $(SOURCES)))
PROGRAM_IMGS := $(addprefix build/, $(addsuffix .img, $(SOURCES)))

all: $(PROGRAM_ELFS) $(PROGRAM_IMGS) $(WAVES)

test: $(addsuffix -test, $(SOURCES))

vcd-files: $(addsuffix -waves, $(SOURCES))

build/%.c.elf: %.c
	@mkdir -p build
	$(RISCV)/bin/riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -o $@ \
	  -nostartfiles -Tlinker.ld \
	   $< _start.S

build/%.S.elf: %.S
	@mkdir -p build
	$(RISCV)/bin/riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o $@ $< \
	  --defsym main=0x4

build/%.c.img: build/%.c.elf
	$(RISCV)/bin/riscv32-unknown-elf-objcopy -O binary $< $@

build/%.S.img: build/%.S.elf
	$(RISCV)/bin/riscv32-unknown-elf-objcopy -O binary $< $@

waves/%.vcd: build/%.img proc-run
	@mkdir -p waves
	./proc-run \
	  --vcd-path=waves/$*.vcd \
	  --instructions=build/$*.img

%-run: build/%.img proc-run
	./proc-run \
	  --instructions=build/$*.img \
	  --log-instructions=build/$*.log.tmp \
	  --dump-final-register-state
	cat build/$*.log.tmp | $(RISCV)/bin/spike-dasm > build/$*.log
	rm build/$*.log.tmp

%-run-spike: build/%.elf
	$(RISCV)/bin/spike -l --log=build/$*.spike.log \
	  --isa=rv32i -m0x10000:0x20000 $<

%-test: build/%.img proc-run FORCE
	./proc-run \
	  --instructions=build/$*.img \
	  --dump-final-register-state \
	  --log-instructions=build/$*.log.tmp \
	  | FileCheck $*
	cat build/$*.log.tmp | $(RISCV)/bin/spike-dasm > build/$*.log
	rm build/$*.log.tmp

%-waves: waves/%.vcd
	surfer --command-file surfer_commands $<

proc-run:
	$(error The 'proc-run' binary is provided by the top-level Makefile)

.PHONY: clean
clean:
	rm -rf *.elf *.img waves build

FORCE:
