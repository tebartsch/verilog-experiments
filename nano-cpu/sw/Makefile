RISCV := $(abspath riscv-tools)

SOURCES = $(wildcard *.S)

all: $(SOURCES:.S=.img)

test: $(SOURCES:.S=-test)

vcd-files: $(SOURCES:.S=-waves)

%.elf: %.S
	$(RISCV)/bin/riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o $@ $< 

%.img: %.elf
	$(RISCV)/bin/riscv32-unknown-elf-objcopy -O binary $< $@

waves/%.vcd: %.img
	@mkdir -p waves
	./proc-run \
	  --vcd-path=waves/$*.vcd \
	  --instructions=$*.img

%-test: %.img
	./proc-run \
	  --instructions=$*.img \
	  --dump-final-register-state \
	  | FileCheck $*.S

%-waves: waves/%.vcd
	surfer $<

.PHONY: clean
clean:
	rm -rf *.elf *.img waves
