module register_file (
    input clk,
    input rst,

    // destination register
    input reg_rd_valid,
    input [ 4:0] reg_rd_select,
    input [31:0] reg_rd,

    // source register 1
    input  [ 4:0] reg_rs1_select,
    output [31:0] reg_rs1,

    // source register 2
    input  [ 4:0] reg_rs2_select,
    output [31:0] reg_rs2
);  
  // Registers containing the values of the registers selected by
  // `reg_rs1_select` and `reg_rs2_select`.
  reg [31:0] reg_rs1_value;
  reg [31:0] reg_rs2_value;

  assign reg_rs1 = reg_rs1_value;
  assign reg_rs2 = reg_rs2_value;

  // Registers
  reg  [31:0] reg0_zero;
  reg  [31:0] reg1_ra;
  reg  [31:0] reg2_sp;
  reg  [31:0] reg3_gp;
  reg  [31:0] reg4_tp;
  reg  [31:0] reg5_t0;
  reg  [31:0] reg6_t1;
  reg  [31:0] reg7_t2;
  reg  [31:0] reg8_s0;
  reg  [31:0] reg9_s1;
  reg  [31:0] reg10_a0;
  reg  [31:0] reg11_a1;
  reg  [31:0] reg12_a2;
  reg  [31:0] reg13_a3;
  reg  [31:0] reg14_a4;
  reg  [31:0] reg15_a5;
  reg  [31:0] reg16_a6;
  reg  [31:0] reg17_a7;
  reg  [31:0] reg18_s2;
  reg  [31:0] reg19_s3;
  reg  [31:0] reg20_s4;
  reg  [31:0] reg21_s5;
  reg  [31:0] reg22_s6;
  reg  [31:0] reg23_s7;
  reg  [31:0] reg24_s8;
  reg  [31:0] reg25_s9;
  reg  [31:0] reg26_s10;
  reg  [31:0] reg27_s11;
  reg  [31:0] reg28_t3;
  reg  [31:0] reg29_t4;
  reg  [31:0] reg30_t5;
  reg  [31:0] reg31_t6;

  // Read source register 1
  always @* begin
    case (reg_rs1_select)
      5'd0: reg_rs1_value = reg0_zero;
      5'd1: reg_rs1_value = reg1_ra;
      5'd2: reg_rs1_value = reg2_sp;
      5'd3: reg_rs1_value = reg3_gp;
      5'd4: reg_rs1_value = reg4_tp;
      5'd5: reg_rs1_value = reg5_t0;
      5'd6: reg_rs1_value = reg6_t1;
      5'd7: reg_rs1_value = reg7_t2;
      5'd8: reg_rs1_value = reg8_s0;
      5'd9: reg_rs1_value = reg9_s1;
      5'd10: reg_rs1_value = reg10_a0;
      5'd11: reg_rs1_value = reg11_a1;
      5'd12: reg_rs1_value = reg12_a2;
      5'd13: reg_rs1_value = reg13_a3;
      5'd14: reg_rs1_value = reg14_a4;
      5'd15: reg_rs1_value = reg15_a5;
      5'd16: reg_rs1_value = reg16_a6;
      5'd17: reg_rs1_value = reg17_a7;
      5'd18: reg_rs1_value = reg18_s2;
      5'd19: reg_rs1_value = reg19_s3;
      5'd20: reg_rs1_value = reg20_s4;
      5'd21: reg_rs1_value = reg21_s5;
      5'd22: reg_rs1_value = reg22_s6;
      5'd23: reg_rs1_value = reg23_s7;
      5'd24: reg_rs1_value = reg24_s8;
      5'd25: reg_rs1_value = reg25_s9;
      5'd26: reg_rs1_value = reg26_s10;
      5'd27: reg_rs1_value = reg27_s11;
      5'd28: reg_rs1_value = reg28_t3;
      5'd29: reg_rs1_value = reg29_t4;
      5'd30: reg_rs1_value = reg30_t5;
      5'd31: reg_rs1_value = reg31_t6;
      default: reg_rs1_value = 32'h00000000;
    endcase
  end

  // Read source register 2
  always @* begin
    case (reg_rs2_select)
      5'd0: reg_rs2_value = reg0_zero;
      5'd1: reg_rs2_value = reg1_ra;
      5'd2: reg_rs2_value = reg2_sp;
      5'd3: reg_rs2_value = reg3_gp;
      5'd4: reg_rs2_value = reg4_tp;
      5'd5: reg_rs2_value = reg5_t0;
      5'd6: reg_rs2_value = reg6_t1;
      5'd7: reg_rs2_value = reg7_t2;
      5'd8: reg_rs2_value = reg8_s0;
      5'd9: reg_rs2_value = reg9_s1;
      5'd10: reg_rs2_value = reg10_a0;
      5'd11: reg_rs2_value = reg11_a1;
      5'd12: reg_rs2_value = reg12_a2;
      5'd13: reg_rs2_value = reg13_a3;
      5'd14: reg_rs2_value = reg14_a4;
      5'd15: reg_rs2_value = reg15_a5;
      5'd16: reg_rs2_value = reg16_a6;
      5'd17: reg_rs2_value = reg17_a7;
      5'd18: reg_rs2_value = reg18_s2;
      5'd19: reg_rs2_value = reg19_s3;
      5'd20: reg_rs2_value = reg20_s4;
      5'd21: reg_rs2_value = reg21_s5;
      5'd22: reg_rs2_value = reg22_s6;
      5'd23: reg_rs2_value = reg23_s7;
      5'd24: reg_rs2_value = reg24_s8;
      5'd25: reg_rs2_value = reg25_s9;
      5'd26: reg_rs2_value = reg26_s10;
      5'd27: reg_rs2_value = reg27_s11;
      5'd28: reg_rs2_value = reg28_t3;
      5'd29: reg_rs2_value = reg29_t4;
      5'd30: reg_rs2_value = reg30_t5;
      5'd31: reg_rs2_value = reg31_t6;
      default: reg_rs2_value = 32'h00000000;
    endcase
  end

  // Write destionation register
  always @ (posedge clk) begin
    if (rst) begin
      reg0_zero <= 32'h00000000;
      reg1_ra   <= 32'h00000000;
      reg2_sp   <= 32'h00000000;
      reg3_gp   <= 32'h00000000;
      reg4_tp   <= 32'h00000000;
      reg5_t0   <= 32'h00000000;
      reg6_t1   <= 32'h00000000;
      reg7_t2   <= 32'h00000000;
      reg8_s0   <= 32'h00000000;
      reg9_s1   <= 32'h00000000;
      reg10_a0  <= 32'h00000000;
      reg11_a1  <= 32'h00000000;
      reg12_a2  <= 32'h00000000;
      reg13_a3  <= 32'h00000000;
      reg14_a4  <= 32'h00000000;
      reg15_a5  <= 32'h00000000;
      reg16_a6  <= 32'h00000000;
      reg17_a7  <= 32'h00000000;
      reg18_s2  <= 32'h00000000;
      reg19_s3  <= 32'h00000000;
      reg20_s4  <= 32'h00000000;
      reg21_s5  <= 32'h00000000;
      reg22_s6  <= 32'h00000000;
      reg23_s7  <= 32'h00000000;
      reg24_s8  <= 32'h00000000;
      reg25_s9  <= 32'h00000000;
      reg26_s10 <= 32'h00000000;
      reg27_s11 <= 32'h00000000;
      reg28_t3  <= 32'h00000000;
      reg29_t4  <= 32'h00000000;
      reg30_t5  <= 32'h00000000;
      reg31_t6  <= 32'h00000000;
    end else begin
      if (reg_rd_valid) begin
        case (reg_rd_select)
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
endmodule
