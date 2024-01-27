// I-type instructions:
//   
//   31    25   24  14  12 11 6    0
//   imm[11:0]  rs1 funct3 rd opcode
`define RV32_ADDI      32'b000_00000_0010011
`define RV32_ADDI_MASK 32'b111_00000_1111111

module proc (
    input clk,
    input rst,
    // TODO: For now programs are put into this memory via verilator simulation
    input reg [31:0] instruction_memory [0:1023],
    output reg [31:0] result
);

    // Registers
    /* verilator lint_off UNUSED */
    reg [31:0] reg0_zero = 32'h00000000;
    reg [31:0] reg1_ra = 32'h00000000;
    reg [31:0] reg2_sp = 32'h00000000;
    reg [31:0] reg3_gp = 32'h00000000;
    reg [31:0] reg4_tp = 32'h00000000;
    reg [31:0] reg5_t0 = 32'h00000000;
    reg [31:0] reg6_t1 = 32'h00000000;
    reg [31:0] reg7_t2 = 32'h00000000;
    reg [31:0] reg8_s0 = 32'h00000000;
    reg [31:0] reg9_s1 = 32'h00000000;
    reg [31:0] reg10_a0 = 32'h00000000;
    reg [31:0] reg11_a1 = 32'h00000000;
    reg [31:0] reg12_a2 = 32'h00000000;
    reg [31:0] reg13_a3 = 32'h00000000;
    reg [31:0] reg14_a4 = 32'h00000000;
    reg [31:0] reg15_a5 = 32'h00000000;
    reg [31:0] reg16_a6 = 32'h00000000;
    reg [31:0] reg17_a7 = 32'h00000000;
    reg [31:0] reg18_s2 = 32'h00000000;
    reg [31:0] reg19_s3 = 32'h00000000;
    reg [31:0] reg20_s4 = 32'h00000000;
    reg [31:0] reg21_s5 = 32'h00000000;
    reg [31:0] reg22_s6 = 32'h00000000;
    reg [31:0] reg23_s7 = 32'h00000000;
    reg [31:0] reg24_s8 = 32'h00000000;
    reg [31:0] reg25_s9 = 32'h00000000;
    reg [31:0] reg26_s10 = 32'h00000000;
    reg [31:0] reg27_s11 = 32'h00000000;
    reg [31:0] reg28_t3 = 32'h00000000;
    reg [31:0] reg29_t4 = 32'h00000000;
    reg [31:0] reg30_t5 = 32'h00000000;
    reg [31:0] reg31_t6 = 32'h00000000;
    /* verilator lint_on UNUSED */

    reg [4:0] reg_select;
    reg [31:0] reg_val;
    always @ * begin
        case (reg_select)
            5'd1: reg_val = reg1_ra;
            5'd2: reg_val = reg2_sp;
            5'd3: reg_val = reg3_gp;
            5'd4: reg_val = reg4_tp;
            5'd5: reg_val = reg5_t0;
            5'd6: reg_val = reg6_t1;
            5'd7: reg_val = reg7_t2;
            5'd8: reg_val = reg8_s0;
            5'd9: reg_val = reg9_s1;
            5'd10: reg_val = reg10_a0;
            5'd11: reg_val = reg11_a1;
            5'd12: reg_val = reg12_a2;
            5'd13: reg_val = reg13_a3;
            5'd14: reg_val = reg14_a4;
            5'd15: reg_val = reg15_a5;
            5'd16: reg_val = reg16_a6;
            5'd17: reg_val = reg17_a7;
            5'd18: reg_val = reg18_s2;
            5'd19: reg_val = reg19_s3;
            5'd20: reg_val = reg20_s4;
            5'd21: reg_val = reg21_s5;
            5'd22: reg_val = reg22_s6;
            5'd23: reg_val = reg23_s7;
            5'd24: reg_val = reg24_s8;
            5'd25: reg_val = reg25_s9;
            5'd26: reg_val = reg26_s10;
            5'd27: reg_val = reg27_s11;
            5'd28: reg_val = reg28_t3;
            5'd29: reg_val = reg29_t4;
            5'd30: reg_val = reg30_t5;
            5'd31: reg_val = reg31_t6;
            default : reg_val = 32'h00000000;
        endcase
    end

    // Regsiters to communicate with ALU
    reg [31:0] alu_input_a;
    reg [31:0] alu_input_b;
    reg alu_in_valid;
    reg alu_out_valid;

    // Get next instruction on every second cycle
    reg [31:0] counter;
    reg phase;
    reg [31:0] instruction;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= '0;
            phase <= '0;
        end else begin
            if (phase == 1'b0) begin
                phase <= 1'b1;
            end
            if (phase == 1'b1 && alu_out_valid) begin
                counter <= counter + 32'h1;
                phase <= 1'b0;
            end
        end 
        instruction <= instruction_memory[counter];
    end

    // Instruction type dependent signals
    reg [31:0] i_type_instr_immediate;
    wire [4:0] i_type_instr_rs1 = instruction[19:15];
    always @ * begin
        i_type_instr_immediate = {{20{instruction[31]}}, instruction[31:20]};

        reg_select = 5'b0;
        alu_in_valid = 1'b0;
        alu_input_a = 32'h00000000;
        alu_input_b = 32'h00000000;

        // Forward to ALU
        if (!rst) begin
            if ((instruction & `RV32_ADDI_MASK) == `RV32_ADDI) begin
                reg_select = i_type_instr_rs1;
                alu_input_a = reg_val;
                alu_input_b = i_type_instr_immediate;
                if (phase == 1'b1) begin
                    alu_in_valid = 1'b1;
                end
            end
        end
    end

    alu u_alu(
        .clk(clk),
        .rst(rst),
        .a_in(alu_input_a),
        .b_in(alu_input_b),
        .in_valid(alu_in_valid),
        .out(result),
        .out_valid(alu_out_valid)
    );

endmodule;
