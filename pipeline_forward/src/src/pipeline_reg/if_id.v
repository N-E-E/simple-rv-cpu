module IF_ID (
    input clk, rst, en, flush,  // TODO: flush not yet used
    input [31:0] pc_in, instr_in,
    output [31:0] pc_out, instr_out
);
    // if flush : var_in_ = 0 else : var_in_ = var_in
    wire [31:0] pc_in_, instr_in_;

    assign pc_in_ = (flush == 0) ? pc_in : 32'b0;
    assign instr_in_ = (flush == 0) ? instr_in : 32'b0;


    RegisterTmp #(.WIDTH(32)) pc_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(pc_in_), 
        .dout(pc_out)
    );

    RegisterTmp #(.WIDTH(32)) instr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(instr_in_), 
        .dout(instr_out)
    );
endmodule