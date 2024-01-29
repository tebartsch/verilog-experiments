
# setup registers t0, t1, t2  
  addi t0, zero, 0x5
  addi t1, zero, 0x5
  addi t2, zero, 0x4

# beq with rs1 == rs2
  beq t0, t1, 1f
  addi a1, zero, 0x1
1:
  addi a2, zero, 0x1

# beq with rs1 != rs2
  beq t0, t2, 2f
  addi a4, zero, 0x1
2:
  addi a5, zero, 0x1

# CHECK: ra = 0x0
# CHECK: sp = 0x0
# CHECK: gp = 0x0
# CHECK: tp = 0x0
# CHECK: t0 = 0x5
# CHECK: t1 = 0x5
# CHECK: t2 = 0x4
# CHECK: s0 = 0x0
# CHECK: s1 = 0x0
# CHECK: a0 = 0x0
# CHECK: a1 = 0x0
# CHECK: a2 = 0x1
# CHECK: a3 = 0x0
# CHECK: a4 = 0x1
# CHECK: a5 = 0x1
# CHECK: a6 = 0x0
# CHECK: a7 = 0x0
# CHECK: s2 = 0x0
# CHECK: s3 = 0x0
# CHECK: s4 = 0x0
# CHECK: s5 = 0x0
# CHECK: s6 = 0x0
# CHECK: s7 = 0x0
# CHECK: s8 = 0x0
# CHECK: s9 = 0x0
# CHECK: s10 = 0x0
# CHECK: s11 = 0x0
# CHECK: t3 = 0x0
# CHECK: t4 = 0x0
# CHECK: t5 = 0x0
# CHECK: t6 = 0x0
