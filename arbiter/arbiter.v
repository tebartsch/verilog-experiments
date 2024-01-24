module arbiter (
  input clock, 
  input reset, 
  input request_0,
  input request_1, 
  output reg grant_0, 
  output reg grant_1
);

  always @ (posedge clock or posedge reset)
  if (reset) begin
  grant_0 <= 0;
  grant_1 <= 0;
  end else if (request_0) begin
    grant_0 <= 1;
    grant_1 <= 0;
  end else if (request_1) begin
    grant_0 <= 0;
    grant_1 <= 1;
  end

endmodule
