// originally based on: https://github.com/n-kremeris/verilator_basics/blob/main/alu.sv (MIT License)

module alu (
    input clk,
    input rst,

    // High if r, i or s instruction is handled
    input        r_i_s_instr_types,
    input  [2:0] funct3,

    input  [31:0]  a_in,
    input  [31:0]  b_in,
    input          in_valid,

    output reg [31:0] out,
    output reg        out_valid
);

    reg  [31:0]  a_in_r;
    reg  [31:0]  b_in_r;
    reg          in_valid_r;
    reg  [31:0]  result;

    // Register all inputs
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            a_in_r      <= 32'h0;
            b_in_r      <= 32'h0;
            in_valid_r  <= 1'b0;
        end else begin
            a_in_r     <= a_in;
            b_in_r     <= b_in;
            in_valid_r <= in_valid;
        end 
    end

    // Compute the result
    always @* begin
        result = 32'h0;
        if (in_valid_r) begin
            if (r_i_s_instr_types) begin 
              case (funct3)
                3'b001:
                  result = a_in_r << b_in_r;
                3'b101:
                  result = a_in_r >> b_in_r;
                3'b111:
                  result = a_in_r & b_in_r;
                default: 
                  result = a_in_r + b_in_r;
              endcase
            end else begin
              result = a_in_r + b_in_r;
            end
        end
    end

    // Register outputs
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            out       <= 32'h0;
            out_valid <= 1'b0;
        end else begin
            out       <= result;
            out_valid <= in_valid_r;
        end
    end

endmodule;
