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

  wire [31:0] register_write_back_wire;
  wire [31:0] reg_rs1;
  wire [31:0] reg_rs2;
  register_file u_register_file (
      .clk(clk),
      .rst(rst),
      // destination register
      .reg_rd_valid(alu_out_valid),
      .reg_rd_select(instr_rd),
      .reg_rd(register_write_back_wire),
      // source register 1
      .reg_rs1_select(instr_rs1),
      .reg_rs1(reg_rs1),
      // source register 2
      .reg_rs2_select(instr_rs2),
      .reg_rs2(reg_rs2)
  );

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

  // The second input of the ALU is 
  //  - an immediate value for I-type instructions
  //  - the value of register reg_rs2 for R-type instructions which
  //    optionally can be inverted
  wire invert_alu_input_b = instr_funct7[5];
  wire [31:0] reg_rs2_inverted = ~reg_rs2 + 1;
  wire [31:0] reg_rs2_maybe_inverted = 
    invert_alu_input_b ? reg_rs2_inverted : reg_rs2;
  wire [31:0] alu_input_b = alu_input_b_is_immediate 
      ? i_type_instr_immediate
      : reg_rs2_maybe_inverted;

  alu u_alu (
      .clk(clk),
      .rst(rst),
      .a_in(reg_rs1),
      .b_in(alu_input_b),
      .in_valid(alu_in_valid),
      .out(register_write_back_wire),
      .out_valid(alu_out_valid)
  );

endmodule;
