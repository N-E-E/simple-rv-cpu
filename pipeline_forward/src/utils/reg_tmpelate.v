module RegisterTmp #(
    parameter WIDTH = 32
) (
    input clk, rst, en,
    input [WIDTH - 1 : 0] din, 
    output reg [WIDTH - 1 : 0] dout
);
    initial dout = 'b0;
	always @(posedge clk) begin
        if (rst) dout <= 0;
        else if (en) dout <= din;
        else dout <= dout;
	end
endmodule