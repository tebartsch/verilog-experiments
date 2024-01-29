// R-type instructions:
//   
//   31     24  19  14  12 11 6    0
//   funct7 rs2 rs1 funct3 rd opcode

`define RV32_ADD_OPCODE 7'b0110011
`define RV32_ADD_FUNCT3 3'b000
`define RV32_ADD_FUNCT7 7'b0000000

`define RV32_SUB_OPCODE 7'b0110011
`define RV32_SUB_FUNCT3 3'b000
`define RV32_SUB_FUNCT7 7'b0100000

// I-type instructions:
//   
//   31    20   19  14  12 11 6    0
//   imm[11:0]  rs1 funct3 rd opcode

`define RV32_ADDI_OPCODE 7'b0010011
`define RV32_ADDI_FUNCT3 3'b000

`define RV32_ANDI_OPCODE 7'b0010011
`define RV32_ANDI_FUNCT3 3'b111

`define RV32_LW_OPCODE 7'b0000011
`define RV32_LW_FUNCT3 3'b010

`define RV32_JALR_OPCODE 7'b1100111
`define RV32_JALR_FUNCT3 3'b000

// S-type instructions:
//   
//   31     25 24  19  14  12 11     7 6    0
//   imm[11:5] rs2 rs1 funct3 imm[4:0] opcode

`define RV32_SW_OPCODE 7'b0100011
`define RV32_SW_FUNCT3 3'b010

// SB-type instructions:
//
//   31        25 24  19  14  12 11       7  6    0
//   imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode

`define RV32_BEQ_OPCODE 7'b1100011
`define RV32_BEQ_FUNCT3 3'b000

`define RV32_BNE_OPCODE 7'b1100011
`define RV32_BNE_FUNCT3 3'b001

`define RV32_BLT_OPCODE 7'b1100011
`define RV32_BLT_FUNCT3 3'b100

// U-type instructions:
//
//   31      12 11 6    0
//   imm[31:12] rd opcode

`define RV32_LUI_OPCODE 7'b0110111

// UJ-type instructions:
//
//   31                 12 11 6    0
//   imm[20|10:1|11|19:12] rd opcode

`define RV32_JAL_OPCODE 7'b1101111

// Helper functions checking for the type of a instruction

function is_r_type_instr;
  input [ 6:0] opcode;
  input [ 2:0] funct3;
  input [ 6:0] funct7;
  begin
    is_r_type_instr = 
      (opcode == `RV32_ADD_OPCODE 
       && funct3 == `RV32_ADD_FUNCT3
       && funct7 == `RV32_ADD_FUNCT7) ||
      (opcode == `RV32_SUB_OPCODE
       && funct3 == `RV32_SUB_FUNCT3
       && funct7 == `RV32_SUB_FUNCT7);
  end
endfunction

function is_s_type_instr;
  input [ 6:0] opcode;
  input [ 2:0] funct3;
  begin
    is_s_type_instr =
      (opcode == `RV32_SW_OPCODE && funct3 == `RV32_SW_FUNCT3);
  end
endfunction

function is_i_type_instr;
  input [ 6:0] opcode;
  input [ 2:0] funct3;
  begin
    is_i_type_instr =
      (opcode == `RV32_ADDI_OPCODE && funct3 == `RV32_ADDI_FUNCT3) ||
      (opcode == `RV32_LW_OPCODE && funct3 == `RV32_LW_FUNCT3) ||
      (opcode == `RV32_JALR_OPCODE && funct3 == `RV32_JALR_FUNCT3) ||
      (opcode == `RV32_ANDI_OPCODE && funct3 == `RV32_ANDI_FUNCT3);
  end
endfunction

function is_sb_type_instr;
  input [ 6:0] opcode;
  input [ 2:0] funct3;
  begin
    is_sb_type_instr =
      (opcode == `RV32_BEQ_OPCODE && funct3 == `RV32_BEQ_FUNCT3) ||
      (opcode == `RV32_BLT_OPCODE && funct3 == `RV32_BLT_FUNCT3) ||
      (opcode == `RV32_BNE_OPCODE && funct3 == `RV32_BNE_FUNCT3);
  end
endfunction

function is_u_type_instr;
  input [ 6:0] opcode;
  begin
    is_u_type_instr =
      (opcode == `RV32_LUI_OPCODE);
  end
endfunction

function is_uj_type_instr;
  input [ 6:0] opcode;
  begin
    is_uj_type_instr =
      (opcode == `RV32_JAL_OPCODE);
  end
endfunction
