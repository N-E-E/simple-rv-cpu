module IF_ID (
    input clk, rst, en, flush,  // TODO: flush not yet used
    input [31:0] pc_in, instr_in,
    output [31:0] pc_out, instr_out
);

    RegisterTmp #(.WIDTH(32)) pc_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(pc_in), 
        .dout(pc_out)
    );

    RegisterTmp #(.WIDTH(32)) instr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(instr_in), 
        .dout(instr_out)
    );
endmodule