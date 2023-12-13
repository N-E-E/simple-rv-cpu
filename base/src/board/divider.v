module Divider #(
    parameter N = 5000_0000
)(
    input clk, 
    output reg clk_N
);
    reg [31:0]      counter;

    initial begin
        counter <= 32'h0;
        clk_N <= 1'b0;
    end

    always @(posedge clk)  begin
        if(counter == N) begin
            clk_N <= ~clk_N;
            counter <= 32'h0;
        end
        else counter <= counter + 1;
    end
endmodule