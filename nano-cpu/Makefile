# based on: https://github.com/n-kremeris/verilator_basics/blob/main/Makefile (MIT License)

MODULES := proc alu

WAVEFORMS = $(addprefix waves/, $(addsuffix .vcd, $(MODULES)))

.PHONY:test
test: $(WAVEFORMS)

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
waves/%.vcd: obj_dir/stamp.sim_compile-% programs
	cd waves && ./../obj_dir/$*/V$* +verilator+rand+reset+2

.PRECIOUS: obj_dir/stamp.sim_compile-%
obj_dir/stamp.sim_compile-%: obj_dir/stamp.verilate-%
	make -C obj_dir/$* -f V$*.mk V$*
	@mkdir -p waves
	cd waves && ./../obj_dir/$*/V$* +verilator+rand+reset+2
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

.PHONY: programs
programs:
	$(MAKE) -C programs

.PHONY: clean
clean:
	rm -rf obj_dir
	rm -rf waves
	$(MAKE) -C programs clean
