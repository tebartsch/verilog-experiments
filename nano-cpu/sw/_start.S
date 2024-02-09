.section .text._start, "ax", @progbits
.globl _start
_start:
  li sp, 0x1fff0
  j main

# CHECK-NOT: NOTHING
