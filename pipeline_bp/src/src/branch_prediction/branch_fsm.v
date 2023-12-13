module BranchFSM (
    input clk, rst,
    input update,
    input jump,
    output reg [1:0] cur_state 
);
    parameter state_0 = 2'b00;
    parameter state_1 = 2'b01;
    parameter state_2 = 2'b10;
    parameter state_3 = 2'b11;
    
    initial begin
        cur_state <= state_0;
    end

    always @(posedge clk) begin  // 同步清零
        if (rst) cur_state <= state_0;
        else if (update) begin
            case (cur_state)
                state_0: begin
                    if (jump == 0) cur_state <= cur_state;
                    else cur_state <= state_1;
                end

                state_1: begin
                    if (jump == 0) cur_state <= state_0;
                    else cur_state <= state_2;
                end

                state_2: begin
                    if (jump == 0) cur_state <= state_3;
                    else cur_state <= cur_state;
                end

                state_3: begin
                    if (jump == 0) cur_state <= state_0;
                    else cur_state <= state_2;
                end
            endcase
        end
        else cur_state <= cur_state;
    end
endmodule