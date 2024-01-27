# based on: https://github.com/n-kremeris/verilator_basics/blob/main/Makefile (MIT License)

MODULE := alu

.PHONY:sim
sim: waves/$(MODULE).vcd

.PHONY:verilate
verilate: .stamp.verilate

.PHONY:build
build: obj_dir/V$(MODULE)

.PHONY:waves
waves: waves/$(MODULE).vcd
    # Waveform viewer: https://gitlab.com/surfer-project/surfer-project.org
	surfer waves/$(MODULE).vcd

waves/$(MODULE).vcd: ./obj_dir/V$(MODULE)
	mkdir -p waves
	cd waves && ./../obj_dir/V$(MODULE) +verilator+rand+reset+2

./obj_dir/V$(MODULE): .stamp.verilate
	make -C obj_dir -f V$(MODULE).mk V$(MODULE)

.stamp.verilate: $(MODULE).v tb_$(MODULE).cpp
	verilator -Wall --trace \
	  --language 1364-2001 \
	  --x-assign unique \
	  --x-initial unique \
	  -cc $(MODULE).v \
	  --exe tb_$(MODULE).cpp
	@touch .stamp.verilate

.PHONY:lint
lint: $(MODULE).v
	verilator --lint-only $(MODULE).v

.PHONY: clean
clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd
