module proc (
    input clk,
    input rst,

    output reg [31:0] counter
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= '0;
        end else begin
            counter <= counter + '1;
        end 
    end

endmodule;
