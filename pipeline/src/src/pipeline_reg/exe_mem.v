module EXE_MEM (
    input clk, rst, en, flush,  // TODO: flush not yet used
    input [31:0] pc_in, instr_in,
    input [31:0] alu_res1_in, alu_res2_in,
    input mem_to_reg_in, mem_write_in, reg_write_in,
    input [31:0] dmem_in_in,
    input [9:0] dmem_addr_in,
    input jump_in,
    input [4:0] rd_addr_in,
    // input pause_in,

    output [31:0] pc_out, instr_out,
    output [31:0] alu_res1_out, alu_res2_out,
    output mem_to_reg_out, mem_write_out, reg_write_out,
    output [31:0] dmem_in_out,
    output [9:0] dmem_addr_out,
    output jump_out,
    output [4:0] rd_addr_out
    // output pause_out
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

    RegisterTmp #(.WIDTH(32)) alu_res1_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_res1_in), 
        .dout(alu_res1_out)
    );

    RegisterTmp #(.WIDTH(32)) alu_res2_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_res2_in), 
        .dout(alu_res2_out)
    );

    RegisterTmp #(.WIDTH(1)) mem_to_reg_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(mem_to_reg_in), 
        .dout(mem_to_reg_out)
    );

    RegisterTmp #(.WIDTH(1)) mem_write_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(mem_write_in), 
        .dout(mem_write_out)
    );

    RegisterTmp #(.WIDTH(1)) reg_write_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(reg_write_in), 
        .dout(reg_write_out)
    );

    RegisterTmp #(.WIDTH(32)) dmem_in_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(dmem_in_in), 
        .dout(dmem_in_out)
    );

    RegisterTmp #(.WIDTH(10)) dmem_addr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(dmem_addr_in), 
        .dout(dmem_addr_out)
    );

    RegisterTmp #(.WIDTH(1)) jump_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(jump_in), 
        .dout(jump_out)
    );

    RegisterTmp #(.WIDTH(5)) rd_addr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(rd_addr_in), 
        .dout(rd_addr_out)
    );

    // RegisterTmp #(.WIDTH(1)) pause_reg(
    //     .clk(clk), 
    //     .rst(rst), 
    //     .en(en),
    //     .din(pause_in), 
    //     .dout(pause_out)
    // );
    
endmodule