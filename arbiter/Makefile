.PHONY: default
default: arbiter.vcd

.stamp: arbiter.v arbiter_tb.cpp
	verilator -Wall --trace \
	  --language 1364-2001 \
	  --cc arbiter.v --exe arbiter_tb.cpp
	touch .stamp

./obj_dir/Varbiter: .stamp
	$(MAKE) -C obj_dir -f Varbiter.mk Varbiter

arbiter.vcd: ./obj_dir/Varbiter
	./obj_dir/Varbiter

.PHONY: clean
clean:
	rm -rf obj_dir arbiter.vcd .stamp
