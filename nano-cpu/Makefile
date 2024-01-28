# based on: https://github.com/n-kremeris/verilator_basics/blob/main/Makefile (MIT License)

MODULES := proc alu

RISCV_GNU_TOOLCHAIN_VERSION := 8c969a9efe68a811cf524174d25255632029f3d3

RISCV := $(abspath sw/riscv-tools)
MKFILE_ABSDIR := $(abspath .)

WAVEFORMS = $(addprefix waves/, $(addsuffix .vcd, $(MODULES)))

default: riscv-tools sw sw/proc-run 

.PHONY:test
test: $(WAVEFORMS) sw-test

.PHONY: verilate
verilate: $(addprefix obj_dir/stamp.verilate-, $(MODULES))

.PHONY: waves
waves: $(WAVEFORMS)

.PHONY: lint
lint: $(addprefix lint-, $(MODULES))

.PHONY: waves-%
waves-%: waves/%.vcd
    # Waveform viewer: https://gitlab.com/surfer-project/surfer-project.org
	surfer $<

.PHONY: waves/%.vcd
waves/%.vcd: obj_dir/stamp.sim_compile-%
	@mkdir -p waves
	./obj_dir/$*/V$* +verilator+rand+reset+2 \
	  --instructions=none \
	  --vcd-path=waves/$*.vcd 

.PRECIOUS: obj_dir/stamp.sim_compile-%
obj_dir/stamp.sim_compile-%: obj_dir/stamp.verilate-%
	make -C obj_dir/$* -f V$*.mk V$*
	@touch obj_dir/stamp.sim_compile-$*

.PRECIOUS: obj_dir/stamp.verilate-%
obj_dir/stamp.verilate-%: %.v %_tb.cpp
	@mkdir -p obj_dir
	verilator \
	  -Mdir obj_dir/$* \
	  -Wall --trace \
	  --language 1364-2001 \
	  --x-assign unique \
	  --x-initial unique \
	  --cc $*.v \
	  --exe ../../$*_tb.cpp
	@touch obj_dir/stamp.verilate-$*

.PHONY: lint-%
lint-%: %.v
	verilator --lint-only $<

# Provide simulation binary in directory `sw`
sw/proc-run: obj_dir/stamp.sim_compile-proc
	ln -sf $(MKFILE_ABSDIR)/obj_dir/proc/Vproc sw/proc-run

.PHONY: sw
sw: riscv-tools sw/proc-run
	$(MAKE) -C sw

.PHONY: sw-test
sw-test: sw/proc-run sw
	$(MAKE) -C sw test

# Run a program in directory `sw`
sw/%-run: sw/proc-run
	$(MAKE) -C sw $*-run

# View waveforms for a program in directory `sw`
sw/%-waves: sw/proc-run
    # Remove existing waveform file since the processor simulator binary
    # could have changed
	if [ -f sw/waves/$*.vcd ]; then \
	  rm sw/waves/$*.vcd; \
	fi
	$(MAKE) -C sw $*-waves

# Run a test in directory `sw`
sw/%-test: sw/proc-run
	$(MAKE) -C sw $*-test

.PHONY: riscv-tools
riscv-tools:
	if [ -d sw/riscv-gnu-toolchain ]; then \
	  git -C sw/riscv-gnu-toolchain fetch; \
	else \
	  git clone https://github.com/riscv-collab/riscv-gnu-toolchain \
	    sw/riscv-gnu-toolchain; \
	fi
	git -C sw/riscv-gnu-toolchain checkout $(RISCV_GNU_TOOLCHAIN_VERSION)
	mkdir -p sw/riscv-gnu-toolchain/build
	cd sw/riscv-gnu-toolchain/build && \
	  ../configure --prefix=$(RISCV) \
	    --with-arch=rv32i --with-abi=ilp32 \
	    --disable-linux
	$(MAKE) -C sw/riscv-gnu-toolchain/build

.PHONY: clean
clean:
	rm -rf obj_dir
	rm -rf waves
	rm -f sw/proc-run
	$(MAKE) -C sw clean
