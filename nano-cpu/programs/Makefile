RISCV := $(abspath riscv-tools)
RISCV_GNU_TOOLCHAIN_VERSION := 8c969a9efe68a811cf524174d25255632029f3d3

SOURCES = $(wildcard *.S)

all: riscv-tools $(SOURCES:.S=.img)

%.elf: %.S
	$(RISCV)/bin/riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o $@ $< 

%.img: %.elf
	$(RISCV)/bin/riscv32-unknown-elf-objcopy -O binary $< $@

.PHONY: riscv-tools
riscv-tools:
	if [ -d riscv-gnu-toolchain ]; then \
	  git -C riscv-gnu-toolchain fetch; \
	else \
	  git clone https://github.com/riscv-collab/riscv-gnu-toolchain; \
	fi
	git -C riscv-gnu-toolchain checkout $(RISCV_GNU_TOOLCHAIN_VERSION)
	mkdir -p riscv-gnu-toolchain/build
	cd riscv-gnu-toolchain/build && \
	  ../configure --prefix=$(RISCV) \
	    --with-arch=rv32i --with-abi=ilp32 \
	    --disable-linux
	$(MAKE) -C riscv-gnu-toolchain/build

.PHONY: clean
clean:
	rm -rf *.elf *.img