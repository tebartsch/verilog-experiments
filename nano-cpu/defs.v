// R-type instructions:
//   
//   31     24  19  14  12 11 6    0
//   funct7 rs2 rs1 funct3 rd opcode

`define RV32_ADD_OPCODE 7'b0110011
`define RV32_ADD_FUNCT3 3'b000
`define RV32_ADD_FUNCT7 7'b0000000

// I-type instructions:
//   
//   31    20   19  14  12 11 6    0
//   imm[11:0]  rs1 funct3 rd opcode

`define RV32_ADDI_OPCODE 7'b0010011
`define RV32_ADDI_FUNCT3 3'b000

// Helper functions

function is_r_type_instr;
  input [ 6:0] opcode;
  input [ 2:0] funct3;
  input [ 6:0] funct7;
  begin
    is_r_type_instr = 
      (opcode == `RV32_ADD_OPCODE 
       && funct3 == `RV32_ADD_FUNCT3
       && funct7 == `RV32_ADD_FUNCT7);
  end
endfunction

function is_i_type_instr;
  input [ 6:0] opcode;
  input [ 2:0] funct3;
  begin
    is_i_type_instr =
      (opcode == `RV32_ADDI_OPCODE && funct3 == `RV32_ADDI_FUNCT3);
  end
endfunction
