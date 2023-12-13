module ID_EXE (
    input clk, rst, en, flush,  // TODO: flush not yet used
    input [31:0] pc_in, instr_in,
    input jal_in, jalr_in, beq_in, bne_in,  // have to use these signals because branch/jump signal hasn't generated until execution
    input mem_to_reg_in, mem_write_in, reg_write_in, ecall_in, alu_src_in,
    input [3:0] alu_op_in,
    input [31:0] r1_in, r2_in,  // srcB is selected in exe
    input [31:0] imm_I_S_in,
    input [31:0] imm_B_in, imm_J_in,
    input [4:0] rd_addr_in,
    input [31:0] dmem_in_in,

    output [31:0] pc_out, instr_out,
    output jal_out, jalr_out, beq_out, bne_out,
    output mem_to_reg_out, mem_write_out, reg_write_out, ecall_out, alu_src_out,
    output [3:0] alu_op_out,
    output [31:0] r1_out, r2_out, 
    output [31:0] imm_I_S_out,
    output [31:0] imm_B_out, imm_J_out,  // imm is extended but not shifted 
    output [4:0] rd_addr_out,
    output [31:0] dmem_in_out
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

    RegisterTmp #(.WIDTH(1)) jal_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(jal_in), 
        .dout(jal_out)
    );

    RegisterTmp #(.WIDTH(1)) jalr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(jalr_in), 
        .dout(jalr_out)
    );

    RegisterTmp #(.WIDTH(1)) beq_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(beq_in), 
        .dout(beq_out)
    );

    RegisterTmp #(.WIDTH(1)) bne_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(bne_in), 
        .dout(bne_out)
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

    RegisterTmp #(.WIDTH(1)) ecall_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(ecall_in), 
        .dout(ecall_out)
    );

    RegisterTmp #(.WIDTH(1)) alu_src_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_src_in), 
        .dout(alu_src_out)
    );

    RegisterTmp #(.WIDTH(4)) alu_op_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_op_in), 
        .dout(alu_op_out)
    );

    RegisterTmp #(.WIDTH(32)) r1_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(r1_in), 
        .dout(r1_out)
    );

    RegisterTmp #(.WIDTH(32)) r2_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(r2_in), 
        .dout(r2_out)
    );

    RegisterTmp #(.WIDTH(32)) imm_I_S_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(imm_I_S_in), 
        .dout(imm_I_S_out)
    );

    RegisterTmp #(.WIDTH(32)) imm_B_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(imm_B_in), 
        .dout(imm_B_out)
    );

    RegisterTmp #(.WIDTH(32)) imm_J_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(imm_J_in), 
        .dout(imm_J_out)
    );

    RegisterTmp #(.WIDTH(5)) rd_addr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(rd_addr_in), 
        .dout(rd_addr_out)
    );

    RegisterTmp #(.WIDTH(5)) dmem_in_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(dmem_in_in), 
        .dout(dmem_in_out)
    );


endmodule