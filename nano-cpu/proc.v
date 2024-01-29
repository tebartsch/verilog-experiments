`include "defs.v"

module proc (
    input clk,
    input rst,
    // TODO: For now programs are put into this memory via verilator simulation
    input reg [7:0] instruction_memory[0:1023]
);

  //===------------------------------------------------------------------===//
  // Control Signals
  //===------------------------------------------------------------------===//

  wire [ 6:0] instr_opcode = instruction[6:0];
  wire [ 4:0] instr_rd = instruction[11:7];
  wire [ 2:0] instr_funct3 = instruction[14:12];
  wire [ 4:0] instr_rs1 = instruction[19:15];
  wire [ 4:0] instr_rs2 = instruction[24:20];
  wire [ 6:0] instr_funct7 = instruction[31:25];

  wire is_i_type_instr_w = is_i_type_instr(instr_opcode, instr_funct3);
  wire is_sb_type_instr_w = is_sb_type_instr(instr_opcode, instr_funct3);
  wire is_r_type_instr_w = is_r_type_instr(instr_opcode, instr_funct3, 
                                           instr_funct7);

  wire [31:0] branch_pc = pc + sb_type_instr_immediate;
  wire branch = alu_out_valid && (
    (instr_opcode == `RV32_BEQ_OPCODE) && 
    (instr_funct3 == `RV32_BEQ_FUNCT3) &&
    (reg_rd_value == 32'h0)
  );

  wire reg_rd_write = alu_out_valid && (
    is_r_type_instr_w || 
    is_i_type_instr_w 
  );

  //===------------------------------------------------------------------===//
  // Instruction Fetch
  //===------------------------------------------------------------------===//

  reg [31:0] pc;
  reg [31:0] instruction;
  wire [31:0] next_pc = branch ? branch_pc : pc + 32'h4;

  // This wire is high if an invalid instruction is fetched.
  wire invalid_instr = !(
    is_r_type_instr_w || 
    is_i_type_instr_w ||
    is_sb_type_instr_w
  );
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      pc <= '0;
      instruction <= {
        instruction_memory[32'h3],
        instruction_memory[32'h2],
        instruction_memory[32'h1],
        instruction_memory[32'h0]
      };
      alu_in_valid <= 1'b1;
    end else begin
      if (!invalid_instr) begin
        if (alu_in_valid) begin
          alu_in_valid <= 1'b0;
        end
        if (alu_out_valid) begin
          pc <= next_pc;
          alu_in_valid <= 1'b1;
          instruction <= {
            instruction_memory[next_pc + 32'h3],
            instruction_memory[next_pc + 32'h2],
            instruction_memory[next_pc + 32'h1],
            instruction_memory[next_pc + 32'h0]
          };
        end
      end
    end
  end

  //===------------------------------------------------------------------===//
  // Register File
  //===------------------------------------------------------------------===//

  wire [31:0] reg_rd_value;
  wire [31:0] reg_rs1;
  wire [31:0] reg_rs2;
  register_file u_register_file (
      .clk(clk),
      .rst(rst),
      // destination register
      .reg_rd_valid(reg_rd_write),
      .reg_rd_select(instr_rd),
      .reg_rd(reg_rd_value),
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
  wire [31:0] sb_type_instr_immediate = {
    {20{instruction[31]}}, 
    instruction[7], instruction[30:25], 
    instruction[11:8], 1'b0
  };

  //===------------------------------------------------------------------===//
  // ALU
  //===------------------------------------------------------------------===//

  // The ALU performs its work in multiple cycles. For now we always wait
  // for it to finish before continuing with the next instruction.
  reg alu_in_valid;
  reg alu_out_valid;

  // The second input of the ALU is 
  //  -  I-type instr: the immediate value
  //  -  R-type instr: register reg_rs2 which is inverted depending on the instr
  //  - SB-type instr: inverted register reg_rs2
  wire invert_alu_input_b = instr_funct7[5];
  reg [31:0] alu_input_b;
  always @* begin
    alu_input_b = 32'h0;
    if (is_r_type_instr_w) begin
      if (invert_alu_input_b) begin
        alu_input_b = ~reg_rs2 + 1;
      end else begin
        alu_input_b = reg_rs2;
      end
    end else 
    if (is_i_type_instr_w) begin
      alu_input_b = i_type_instr_immediate;
    end else
    if (is_sb_type_instr_w) begin
      alu_input_b = ~reg_rs2 + 1;
    end
  end

  alu u_alu (
      .clk(clk),
      .rst(rst),
      .a_in(reg_rs1),
      .b_in(alu_input_b),
      .in_valid(alu_in_valid),
      .out(reg_rd_value),
      .out_valid(alu_out_valid)
  );

endmodule;
