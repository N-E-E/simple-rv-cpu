module LRUCounter (
    input clk, rst, en,
    input hit,
    output reg [4:0] counter
);
    initial begin counter <= 0; end

    always @(posedge clk) begin  // 同步清零
        if (rst) counter <= 5'b0;
        else if (en) begin
            if (hit) counter = 5'b0;
            else counter = counter + 1;
        end
        else counter <= counter;
    end
endmodule