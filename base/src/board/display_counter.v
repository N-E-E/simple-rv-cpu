module DisplayCounter(
    input clk, 
    output reg [2:0] out
);
	initial out <= 0;
    always @(posedge clk)  begin
        if(out < 7) begin
            out <= out + 1'b1;
        end
        else begin
            out <= 0;
        end
	end                           
endmodule