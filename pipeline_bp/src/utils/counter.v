module Counter(
    input clk, pause, rst, go,
    output reg [31:0] out
);           
    initial out = 0;
	always @(posedge clk) begin
	    if (rst) out <= 0;
        else if (out < 32'hffffffff) begin
            if (~pause || go) out <= out + 1'b1;
            else out <= out;
        end
        else begin
            out <= 0;
        end
	end                           
endmodule