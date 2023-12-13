module Counter(
    input clk, pause, rst,
    output reg [31:0] out
);           
    initial out = 0;
	always @(posedge clk) begin
	    if (rst) out <= 0;
        else if (out < 32'hffffffff) begin
            if (~pause) out <= out + 1'b1;
            else out <= out;
        end
        else begin
            out <= 0;
        end
	end                           
endmodule