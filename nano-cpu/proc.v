`include "defs.v"

module proc (
    input clk,
    input rst,
    // TODO: For now programs are put into this memory via verilator simulation
    input reg [31:0] instruction_memory[0:1023]
);
  //===------------------------------------------------------------------===//
  // Instruction Fetch
  //===------------------------------------------------------------------===//

  reg [31:0] pc;
  reg [31:0] instruction;

  wire [ 6:0] instr_opcode = instruction[6:0];
  wire [ 4:0] instr_rd = instruction[11:7];
  wire [ 2:0] instr_funct3 = instruction[14:12];
  wire [ 4:0] instr_rs1 = instruction[19:15];
  wire [ 4:0] instr_rs2 = instruction[24:20];
  wire [ 6:0] instr_funct7 = instruction[31:25];

  wire is_i_type_instr_w = is_i_type_instr(instr_opcode, instr_funct3);

  // This wire is high if an invalid instruction is fetched.
  wire invalid_instr = !(
    is_r_type_instr(instr_opcode, instr_funct3, instr_funct7) || 
    is_i_type_instr_w
  );
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      pc <= '0;
      instruction <= instruction_memory[32'h0];
      alu_in_valid <= 1'b1;
    end else begin
      if (!invalid_instr) begin
        if (alu_in_valid) begin
          alu_in_valid <= !alu_in_valid;
        end
        if (alu_out_valid) begin
          pc <= pc + 32'h1;
          alu_in_valid <= 1'b1;
          instruction <= instruction_memory[pc + 32'h1];
        end
      end
    end
  end

  //===------------------------------------------------------------------===//
  // Control Signals
  //===------------------------------------------------------------------===//
  // This wire is hight if the second input to the ALU is an immediate value.
  wire alu_input_b_is_immediate = is_i_type_instr_w;

  //===------------------------------------------------------------------===//
  // Register File
  //===------------------------------------------------------------------===//

  reg  [31:0] reg0_zero = 32'h00000000;
  reg  [31:0] reg1_ra = 32'h00000000;
  reg  [31:0] reg2_sp = 32'h00000000;
  reg  [31:0] reg3_gp = 32'h00000000;
  reg  [31:0] reg4_tp = 32'h00000000;
  reg  [31:0] reg5_t0 = 32'h00000000;
  reg  [31:0] reg6_t1 = 32'h00000000;
  reg  [31:0] reg7_t2 = 32'h00000000;
  reg  [31:0] reg8_s0 = 32'h00000000;
  reg  [31:0] reg9_s1 = 32'h00000000;
  reg  [31:0] reg10_a0 = 32'h00000000;
  reg  [31:0] reg11_a1 = 32'h00000000;
  reg  [31:0] reg12_a2 = 32'h00000000;
  reg  [31:0] reg13_a3 = 32'h00000000;
  reg  [31:0] reg14_a4 = 32'h00000000;
  reg  [31:0] reg15_a5 = 32'h00000000;
  reg  [31:0] reg16_a6 = 32'h00000000;
  reg  [31:0] reg17_a7 = 32'h00000000;
  reg  [31:0] reg18_s2 = 32'h00000000;
  reg  [31:0] reg19_s3 = 32'h00000000;
  reg  [31:0] reg20_s4 = 32'h00000000;
  reg  [31:0] reg21_s5 = 32'h00000000;
  reg  [31:0] reg22_s6 = 32'h00000000;
  reg  [31:0] reg23_s7 = 32'h00000000;
  reg  [31:0] reg24_s8 = 32'h00000000;
  reg  [31:0] reg25_s9 = 32'h00000000;
  reg  [31:0] reg26_s10 = 32'h00000000;
  reg  [31:0] reg27_s11 = 32'h00000000;
  reg  [31:0] reg28_t3 = 32'h00000000;
  reg  [31:0] reg29_t4 = 32'h00000000;
  reg  [31:0] reg30_t5 = 32'h00000000;
  reg  [31:0] reg31_t6 = 32'h00000000;

  reg  [31:0] reg_rs1;
  always @* begin
    case (instr_rs1)
      5'd0: reg_rs1 = reg0_zero;
      5'd1: reg_rs1 = reg1_ra;
      5'd2: reg_rs1 = reg2_sp;
      5'd3: reg_rs1 = reg3_gp;
      5'd4: reg_rs1 = reg4_tp;
      5'd5: reg_rs1 = reg5_t0;
      5'd6: reg_rs1 = reg6_t1;
      5'd7: reg_rs1 = reg7_t2;
      5'd8: reg_rs1 = reg8_s0;
      5'd9: reg_rs1 = reg9_s1;
      5'd10: reg_rs1 = reg10_a0;
      5'd11: reg_rs1 = reg11_a1;
      5'd12: reg_rs1 = reg12_a2;
      5'd13: reg_rs1 = reg13_a3;
      5'd14: reg_rs1 = reg14_a4;
      5'd15: reg_rs1 = reg15_a5;
      5'd16: reg_rs1 = reg16_a6;
      5'd17: reg_rs1 = reg17_a7;
      5'd18: reg_rs1 = reg18_s2;
      5'd19: reg_rs1 = reg19_s3;
      5'd20: reg_rs1 = reg20_s4;
      5'd21: reg_rs1 = reg21_s5;
      5'd22: reg_rs1 = reg22_s6;
      5'd23: reg_rs1 = reg23_s7;
      5'd24: reg_rs1 = reg24_s8;
      5'd25: reg_rs1 = reg25_s9;
      5'd26: reg_rs1 = reg26_s10;
      5'd27: reg_rs1 = reg27_s11;
      5'd28: reg_rs1 = reg28_t3;
      5'd29: reg_rs1 = reg29_t4;
      5'd30: reg_rs1 = reg30_t5;
      5'd31: reg_rs1 = reg31_t6;
      default: reg_rs1 = 32'h00000000;
    endcase
  end

  reg  [31:0] reg_rs2;
  always @* begin
    case (instr_rs2)
      5'd0: reg_rs2 = reg0_zero;
      5'd1: reg_rs2 = reg1_ra;
      5'd2: reg_rs2 = reg2_sp;
      5'd3: reg_rs2 = reg3_gp;
      5'd4: reg_rs2 = reg4_tp;
      5'd5: reg_rs2 = reg5_t0;
      5'd6: reg_rs2 = reg6_t1;
      5'd7: reg_rs2 = reg7_t2;
      5'd8: reg_rs2 = reg8_s0;
      5'd9: reg_rs2 = reg9_s1;
      5'd10: reg_rs2 = reg10_a0;
      5'd11: reg_rs2 = reg11_a1;
      5'd12: reg_rs2 = reg12_a2;
      5'd13: reg_rs2 = reg13_a3;
      5'd14: reg_rs2 = reg14_a4;
      5'd15: reg_rs2 = reg15_a5;
      5'd16: reg_rs2 = reg16_a6;
      5'd17: reg_rs2 = reg17_a7;
      5'd18: reg_rs2 = reg18_s2;
      5'd19: reg_rs2 = reg19_s3;
      5'd20: reg_rs2 = reg20_s4;
      5'd21: reg_rs2 = reg21_s5;
      5'd22: reg_rs2 = reg22_s6;
      5'd23: reg_rs2 = reg23_s7;
      5'd24: reg_rs2 = reg24_s8;
      5'd25: reg_rs2 = reg25_s9;
      5'd26: reg_rs2 = reg26_s10;
      5'd27: reg_rs2 = reg27_s11;
      5'd28: reg_rs2 = reg28_t3;
      5'd29: reg_rs2 = reg29_t4;
      5'd30: reg_rs2 = reg30_t5;
      5'd31: reg_rs2 = reg31_t6;
      default: reg_rs2 = 32'h00000000;
    endcase
  end

  wire [31:0] reg_rd;
  wire reg_rd_valid = alu_out_valid;
  always @ (posedge clk) begin
    if (reg_rd_valid) begin
      case (instr_rd)
        5'd1: reg1_ra <= reg_rd;
        5'd2: reg2_sp <= reg_rd;
        5'd3: reg3_gp <= reg_rd;
        5'd4: reg4_tp <= reg_rd;
        5'd5: reg5_t0 <= reg_rd;
        5'd6: reg6_t1 <= reg_rd;
        5'd7: reg7_t2 <= reg_rd;
        5'd8: reg8_s0 <= reg_rd;
        5'd9: reg9_s1 <= reg_rd;
        5'd10: reg10_a0 <= reg_rd;
        5'd11: reg11_a1 <= reg_rd;
        5'd12: reg12_a2 <= reg_rd;
        5'd13: reg13_a3 <= reg_rd;
        5'd14: reg14_a4 <= reg_rd;
        5'd15: reg15_a5 <= reg_rd;
        5'd16: reg16_a6 <= reg_rd;
        5'd17: reg17_a7 <= reg_rd;
        5'd18: reg18_s2 <= reg_rd;
        5'd19: reg19_s3 <= reg_rd;
        5'd20: reg20_s4 <= reg_rd;
        5'd21: reg21_s5 <= reg_rd;
        5'd22: reg22_s6 <= reg_rd;
        5'd23: reg23_s7 <= reg_rd;
        5'd24: reg24_s8 <= reg_rd;
        5'd25: reg25_s9 <= reg_rd;
        5'd26: reg26_s10 <= reg_rd;
        5'd27: reg27_s11 <= reg_rd;
        5'd28: reg28_t3 <= reg_rd;
        5'd29: reg29_t4 <= reg_rd;
        5'd30: reg30_t5 <= reg_rd;
        5'd31: reg31_t6 <= reg_rd;
        default: ;
      endcase
    end
  end

  // Export function to read register values in verilator simulation
`ifdef verilator
  wire [31:0][30:0] registers;
  assign registers = {reg31_t6, reg30_t5, reg29_t4, reg28_t3, reg27_s11,
                      reg26_s10, reg25_s9, reg24_s8, reg23_s7, reg22_s6,
                      reg21_s5, reg20_s4, reg19_s3, reg18_s2, reg17_a7,
                      reg16_a6, reg15_a5, reg14_a4, reg13_a3, reg12_a2,
                      reg11_a1, reg10_a0, reg9_s1, reg8_s0, reg7_t2,
                      reg6_t1, reg5_t0, reg4_tp, reg3_gp, reg2_sp, reg1_ra};
  task get_registers;
    /* verilator public */
    output [31:0][30:0] _registers = registers;
  endtask
`endif

  //===------------------------------------------------------------------===//
  // Immediate Generation
  //===------------------------------------------------------------------===//

  wire [31:0] i_type_instr_immediate = {
    {20{instruction[31]}}, instruction[31:20]
  };

  //===------------------------------------------------------------------===//
  // ALU
  //===------------------------------------------------------------------===//

  // The ALU performs its work in multiple cycles. For now we always wait
  // for it to finish before continuing with the next instruction.
  reg alu_in_valid;
  reg alu_out_valid;

  wire [31:0] alu_input_b = 
    alu_input_b_is_immediate ? i_type_instr_immediate : reg_rs2;

  alu u_alu (
      .clk(clk),
      .rst(rst),
      .a_in(reg_rs1),
      .b_in(alu_input_b),
      .in_valid(alu_in_valid),
      .out(reg_rd),
      .out_valid(alu_out_valid)
  );

endmodule;
