module ID_EXE (
    input clk, rst, en, flush,  // TODO: flush not yet used
    input [31:0] pc_in, instr_in,
    input jal_in, jalr_in, beq_in, bne_in, bge_in,  // have to use these signals because branch/jump signal hasn't generated until execution
    input mem_to_reg_in, mem_write_in, reg_write_in, ecall_in, alu_src_in,
    input [3:0] alu_op_in,
    input [31:0] r1_in, r2_in,  // srcB is selected in exe
    input [31:0] imm_I_S_in,
    input [31:0] imm_B_in, imm_J_in,
    input [4:0] rd_addr_in,
    input [1:0] r1_forward_in, r2_forward_in,
    input half_in,
    input predict_jump_in,

    output [31:0] pc_out, instr_out,
    output jal_out, jalr_out, beq_out, bne_out, bge_out,
    output mem_to_reg_out, mem_write_out, reg_write_out, ecall_out, alu_src_out,
    output [3:0] alu_op_out,
    output [31:0] r1_out, r2_out, 
    output [31:0] imm_I_S_out,
    output [31:0] imm_B_out, imm_J_out,  // imm is extended but not shifted 
    output [4:0] rd_addr_out,
    output [1:0] r1_forward_out, r2_forward_out,
    output half_out,
    output predict_jump_out
);
    // if flush : var_in_ = 0 else : var_in_ = var_in
    wire [31:0] pc_in_, instr_in_;
    wire jal_in_, jalr_in_, beq_in_, bne_in_, bge_in_;  // have to use these signals because branch/jump signal hasn't generated until execution
    wire mem_to_reg_in_, mem_write_in_, reg_write_in_, ecall_in_, alu_src_in_;
    wire [3:0] alu_op_in_;
    wire [31:0] r1_in_, r2_in_;  // srcB is selected in exe
    wire [31:0] imm_I_S_in_;
    wire [31:0] imm_B_in_, imm_J_in_;
    wire [4:0] rd_addr_in_;
    wire [31:0] dmem_in_in_;
    wire [1:0] r1_forward_in_, r2_forward_in_;
    wire half_in_;
    wire predict_jump_in_;

    assign pc_in_ = (flush == 0) ? pc_in : 32'b0;
    assign instr_in_ = (flush == 0) ? instr_in : 32'b0;
    assign jal_in_ = (flush == 0) ? jal_in : 'b0;
    assign jalr_in_ = (flush == 0) ? jalr_in : 'b0;
    assign beq_in_ = (flush == 0) ? beq_in : 'b0;
    assign bne_in_ = (flush == 0) ? bne_in : 'b0;
    assign bge_in_ = (flush == 0) ? bge_in : 'b0;
    assign mem_to_reg_in_ = (flush == 0) ? mem_to_reg_in : 'b0;
    assign mem_write_in_ = (flush == 0) ? mem_write_in : 'b0;
    assign reg_write_in_ = (flush == 0) ? reg_write_in : 'b0;
    assign ecall_in_ = (flush == 0) ? ecall_in : 'b0;
    assign alu_src_in_ = (flush == 0) ? alu_src_in : 'b0;
    assign alu_op_in_ = (flush == 0) ? alu_op_in : 4'b0;
    assign r1_in_ = (flush == 0) ? r1_in : 32'b0;
    assign r2_in_ = (flush == 0) ? r2_in : 32'b0;
    assign imm_I_S_in_ = (flush == 0) ? imm_I_S_in : 32'b0;
    assign imm_B_in_ = (flush == 0) ? imm_B_in : 32'b0;
    assign imm_J_in_ = (flush == 0) ? imm_J_in : 32'b0;
    assign rd_addr_in_ = (flush == 0) ? rd_addr_in : 5'b0;
    // assign dmem_in_in_ = (flush == 0) ? dmem_in_in : 32'b0;
    assign r1_forward_in_ = (flush == 0) ? r1_forward_in : 2'b0;
    assign r2_forward_in_ = (flush == 0) ? r2_forward_in : 2'b0;
    assign half_in_ = (flush == 0) ? half_in : 1'b0;
    assign predict_jump_in_ = (flush == 0) ? predict_jump_in : 32'b0;

    
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

    RegisterTmp #(.WIDTH(1)) jal_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(jal_in_), 
        .dout(jal_out)
    );

    RegisterTmp #(.WIDTH(1)) jalr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(jalr_in_), 
        .dout(jalr_out)
    );

    RegisterTmp #(.WIDTH(1)) beq_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(beq_in_), 
        .dout(beq_out)
    );

    RegisterTmp #(.WIDTH(1)) bne_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(bne_in_), 
        .dout(bne_out)
    );

    RegisterTmp #(.WIDTH(1)) bge_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(bge_in_), 
        .dout(bge_out)
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

    RegisterTmp #(.WIDTH(1)) ecall_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(ecall_in_), 
        .dout(ecall_out)
    );

    RegisterTmp #(.WIDTH(1)) alu_src_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_src_in_), 
        .dout(alu_src_out)
    );

    RegisterTmp #(.WIDTH(4)) alu_op_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(alu_op_in_), 
        .dout(alu_op_out)
    );

    RegisterTmp #(.WIDTH(32)) r1_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(r1_in_), 
        .dout(r1_out)
    );

    RegisterTmp #(.WIDTH(32)) r2_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(r2_in_), 
        .dout(r2_out)
    );

    RegisterTmp #(.WIDTH(32)) imm_I_S_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(imm_I_S_in_), 
        .dout(imm_I_S_out)
    );

    RegisterTmp #(.WIDTH(32)) imm_B_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(imm_B_in_), 
        .dout(imm_B_out)
    );

    RegisterTmp #(.WIDTH(32)) imm_J_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(imm_J_in_), 
        .dout(imm_J_out)
    );

    RegisterTmp #(.WIDTH(5)) rd_addr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(rd_addr_in_), 
        .dout(rd_addr_out)
    );

    // RegisterTmp #(.WIDTH(32)) dmem_in_reg(
    //     .clk(clk), 
    //     .rst(rst), 
    //     .en(en),
    //     .din(dmem_in_in_), 
    //     .dout(dmem_in_out)
    // );

    RegisterTmp #(.WIDTH(2)) r1_forward_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(r1_forward_in_), 
        .dout(r1_forward_out)
    );

    RegisterTmp #(.WIDTH(2)) r2_forward_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(r2_forward_in_), 
        .dout(r2_forward_out)
    );

    RegisterTmp #(.WIDTH(1)) half_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(half_in_), 
        .dout(half_out)
    );

    RegisterTmp #(.WIDTH(1)) predict_jump_reg(
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .din(predict_jump_in_), 
        .dout(predict_jump_out)
    );


endmodule