`include "defs.v"

module proc (
    input clk,
    input rst
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

  wire is_r_type_instr_w = is_r_type_instr(instr_opcode, instr_funct3, 
                                           instr_funct7);
  wire is_i_type_instr_w = is_i_type_instr(instr_opcode, instr_funct3);
  wire is_s_type_instr_w = is_s_type_instr(instr_opcode, instr_funct3);
  wire is_sb_type_instr_w = is_sb_type_instr(instr_opcode, instr_funct3);
  wire is_u_type_instr_w = is_u_type_instr(instr_opcode);
  wire is_uj_type_instr_w = is_uj_type_instr(instr_opcode);

  wire branch = alu_out_valid && (
    ((instr_opcode == `RV32_BEQ_OPCODE) &&
      (instr_funct3 == `RV32_BEQ_FUNCT3) &&
      (reg_rd_value == 32'h0)) ||
    ((instr_opcode == `RV32_BNE_OPCODE) &&
      (instr_funct3 == `RV32_BNE_FUNCT3) &&
      (reg_rd_value != 32'h0)) ||
    ((instr_opcode == `RV32_BLT_OPCODE) &&
      (instr_funct3 == `RV32_BLT_FUNCT3) &&
      (reg_rd_value[31] == 1'b1)) ||
    (instr_opcode == `RV32_JAL_OPCODE) ||
    (instr_opcode == `RV32_JALR_OPCODE && instr_funct3 == `RV32_JALR_FUNCT3)
  );
  reg [31:0] branch_pc;
  always @* begin
    branch_pc = 32'h0;
    if (instr_opcode == `RV32_LW_OPCODE && 
        instr_funct3 == `RV32_LW_FUNCT3)
    begin
      // Read memory if instruction is load
      reg_rd_value = {
        memory[alu_out + 32'h0],
        memory[alu_out + 32'h1],
        memory[alu_out + 32'h2],
        memory[alu_out + 32'h3]
      };
    end
    else if (instr_opcode == `RV32_JALR_OPCODE && 
             instr_funct3 == `RV32_JALR_FUNCT3) 
    begin
      branch_pc = alu_out;
      reg_rd_value = pc + 32'h4;
    end else if (is_sb_type_instr_w) begin
      reg_rd_value = alu_out;
      branch_pc = pc + sb_type_instr_immediate;
    end else if (is_uj_type_instr_w) begin
      reg_rd_value = pc + 32'h4;
      branch_pc = pc + uj_type_instr_immediate;
    end else begin
      reg_rd_value = alu_out;
      branch_pc = 32'h0;
    end
  end

  assign reg_rd_write = alu_out_valid && (
    is_r_type_instr_w || 
    is_i_type_instr_w ||
    is_u_type_instr_w ||
    is_uj_type_instr_w
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
    is_s_type_instr_w ||
    is_sb_type_instr_w ||
    is_u_type_instr_w ||
    is_uj_type_instr_w
  );
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      pc <= '0;
      instruction <= {
        memory[32'h3],
        memory[32'h2],
        memory[32'h1],
        memory[32'h0]
      };
      alu_in_valid <= 1'b1;
    end else begin
      if (!invalid_instr) begin
        if (alu_in_valid) begin
          alu_in_valid <= 1'b0;
        end
        if (alu_out_valid) begin
          // Increase pc and set new instruction
          pc <= next_pc;
          instruction <= {
            memory[next_pc + 32'h3],
            memory[next_pc + 32'h2],
            memory[next_pc + 32'h1],
            memory[next_pc + 32'h0]
          };
          // Start ALU in next cycle
          alu_in_valid <= 1'b1;
          // Write memory if instruction is store
          if ((instr_opcode == `RV32_SW_OPCODE && 
               instr_funct3 == `RV32_SW_FUNCT3))
          begin
            memory[alu_out + 32'h3] <= reg_rs2[7:0];
            memory[alu_out + 32'h2] <= reg_rs2[15:8];
            memory[alu_out + 32'h1] <= reg_rs2[23:16];
            memory[alu_out + 32'h0] <= reg_rs2[31:24];
          end
        end
      end
    end
  end

  /* verilator lint_off UNUSED */
  wire [7:0] test = memory[32'h50];
  /* verilator lint_on UNUSED */

  //===------------------------------------------------------------------===//
  // Register File
  //===------------------------------------------------------------------===//

  wire reg_rd_write;
  reg [31:0] reg_rd_value;
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
  wire [31:0] s_type_instr_immediate = {
    {20{instruction[31]}}, instruction[31:25], instruction[11:7]
  };
  wire [31:0] sb_type_instr_immediate = {
    {20{instruction[31]}}, 
    instruction[7], instruction[30:25], 
    instruction[11:8], 1'b0
  };
  wire [31:0] u_type_instr_immediate = {
    instruction[31:12], 12'h0
  };
  wire [31:0] uj_type_instr_immediate = {
    {12{instruction[31]}},
    instruction[19:12],
    instruction[20],
    instruction[30:21],
    1'b0
  };

  //===------------------------------------------------------------------===//
  // ALU
  //===------------------------------------------------------------------===//

  // The ALU performs its work in multiple cycles. For now we always wait
  // for it to finish before continuing with the next instruction.
  reg alu_in_valid;
  reg alu_out_valid;
  reg [31:0] alu_out;

  // The second input of the ALU is 
  //  -  I-type instr: the immediate value
  //  -  R-type instr: register reg_rs2 which is inverted depending on the instr
  //  - SB-type instr: inverted register reg_rs2
  wire invert_alu_input_b = instr_funct7[5];
  reg [31:0] alu_input_a;
  reg [31:0] alu_input_b;
  always @* begin
    if (is_r_type_instr_w) begin
      alu_input_a = reg_rs1;
      if (invert_alu_input_b) begin
        alu_input_b = ~reg_rs2 + 1;
      end else begin
        alu_input_b = reg_rs2;
      end
    end else if (is_i_type_instr_w) begin
      alu_input_a = reg_rs1;
      alu_input_b = i_type_instr_immediate;
    end else if (is_s_type_instr_w) begin
      alu_input_a = reg_rs1;
      alu_input_b = s_type_instr_immediate;
    end else if (is_sb_type_instr_w) begin
      alu_input_a = reg_rs1;
      alu_input_b = ~reg_rs2 + 1;
    end else if (is_u_type_instr_w) begin
      alu_input_a = 32'h0;
      alu_input_b = u_type_instr_immediate;
    end else if (is_uj_type_instr_w) begin
      alu_input_a = 32'h0;
      alu_input_b = uj_type_instr_immediate;
    end else begin
      alu_input_a = 32'h0;
      alu_input_b = 32'h0;
    end
  end

  alu u_alu (
      .clk(clk),
      .rst(rst),
      .a_in(alu_input_a),
      .b_in(alu_input_b),
      .in_valid(alu_in_valid),
      .out(alu_out),
      .out_valid(alu_out_valid)
  );

  //===------------------------------------------------------------------===//
  // Memory
  //===------------------------------------------------------------------===//

  // TODO: For now programs are put into this memory via verilator simulation
  reg [7:0] memory[0:65535];

  // Export function to read memory in verilator simulation
`ifdef verilator
  task read_memory_byte;
      /* verilator public */
      // Ignore upper bytes of address
      /* verilator lint_off UNUSED */
      input [31:0] address;
      /* verilator lint_on UNUSED */
      output [7:0] data;
      data = memory[address[15:0]];
  endtask
`endif

  // Export function to write memory in verilator simulation
`ifdef verilator
  task write_memory_byte;
      /* verilator public */
      // Ignore upper bytes of address
      /* verilator lint_off UNUSED */
      input [31:0] address;
      /* verilator lint_on UNUSED */
      input [7:0] data;
      memory[address[15:0]] = data;
  endtask
`endif

endmodule;
