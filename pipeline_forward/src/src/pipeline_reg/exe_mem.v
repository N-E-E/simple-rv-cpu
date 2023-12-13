module EXE_MEM (
    input clk, rst, en, flush,  // TODO: flush not yet used
    input [31:0] pc_in, instr_in,
    input [31:0] alu_res1_in, alu_res2_in,
    input mem_to_reg_in, mem_write_in, reg_write_in,
    input [31:0] dmem_in_in,
    input [9:0] dmem_addr_in,
    input jump_in,
    input [4:0] rd_addr_in,
    input pause_in,
    input half_in,

    output [31:0] pc_out, instr_out,
    output [31:0] alu_res1_out, alu_res2_out,
    output mem_to_reg_out, mem_write_out, reg_write_out,
    output [31:0] dmem_in_out,
    output [9:0] dmem_addr_out,
    output jump_out,
    output [4:0] rd_addr_out,
    output pause_out,
    output half_out
);
    // if flush : var_in_ = 0 else : var_in_ = var_in
    wire [31:0] pc_in_, instr_in_;
    wire [31:0] alu_res1_in_, alu_res2_in_;
    wire mem_to_reg_in_, mem_write_in_, reg_write_in_;
    wire [31:0] dmem_in_in_;
    wire [9:0] dmem_addr_in_;
    wire jump_in_;
    wire [4:0] rd_addr_in_;
    wire half_in_;
    
    assign pc_in_ = (flush == 0) ? pc_in : 32'b0;
    assign instr_in_ = (flush == 0) ? instr_in : 32'b0;
    assign alu_res1_in_ = (flush == 0) ? alu_res1_in : 32'b0;
    assign alu_res2_in_ = (flush == 0) ? alu_res2_in : 32'b0;
    assign mem_to_reg_in_ = (flush == 0) ? mem_to_reg_in : 1'b0;
    assign mem_write_in_ = (flush == 0) ? mem_write_in : 1'b0;
    assign reg_write_in_ = (flush == 0) ? reg_write_in : 1'b0;
    assign dmem_in_in_ = (flush == 0) ? dmem_in_in : 32'b0;
    assign dmem_addr_in_ = (flush == 0) ? dmem_addr_in : 10'b0;
    assign jump_in_ = (flush == 0) ? jump_in : 1'b0;
    assign rd_addr_in_ = (flush == 0) ? rd_addr_in : 5'b0;
    assign half_in_ = (flush == 0) ? half_in : 'b0;
    

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

    RegisterTmp #(.WIDTH(32)) alu_res1_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_res1_in_), 
        .dout(alu_res1_out)
    );

    RegisterTmp #(.WIDTH(32)) alu_res2_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_res2_in_), 
        .dout(alu_res2_out)
    );

    RegisterTmp #(.WIDTH(1)) mem_to_reg_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(mem_to_reg_in_), 
        .dout(mem_to_reg_out)
    );

    RegisterTmp #(.WIDTH(1)) mem_write_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(mem_write_in_), 
        .dout(mem_write_out)
    );

    RegisterTmp #(.WIDTH(1)) reg_write_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(reg_write_in_), 
        .dout(reg_write_out)
    );

    RegisterTmp #(.WIDTH(32)) dmem_in_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(dmem_in_in_), 
        .dout(dmem_in_out)
    );

    RegisterTmp #(.WIDTH(10)) dmem_addr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(dmem_addr_in_), 
        .dout(dmem_addr_out)
    );

    RegisterTmp #(.WIDTH(1)) jump_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(jump_in_), 
        .dout(jump_out)
    );

    RegisterTmp #(.WIDTH(5)) rd_addr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(rd_addr_in_), 
        .dout(rd_addr_out)
    );

    RegisterTmp #(.WIDTH(1)) pause_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(pause_in), 
        .dout(pause_out)
    );

    RegisterTmp #(.WIDTH(1)) half_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(half_in_), 
        .dout(half_out)
    );
    
endmodule