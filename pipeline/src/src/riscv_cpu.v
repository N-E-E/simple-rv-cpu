module RiscvCPU (
    input clk, rst, pause,
    output [31:0] led_data_o
);
    wire [31:0] pc_cur_if, pc_cur_id, pc_cur_exe, pc_cur_mem, pc_cur_wb;
    wire [31:0] pc_next;
    wire [31:0] pc_next_0_if, pc_next_1_exe, pc_next_2_exe, pc_next_3_exe;  // (pc_next_0 must appear in if)
    wire [31:0] instr_if, instr_id, instr_exe, instr_mem, instr_wb;  // instruction
    wire [9:0] instr_addr_if;

    // // force the pipeline to pause the circuit in wb process.(or the last ecall will be stall in the exe)
    // wire pause_mem, pause_wb;  //NOTE: when met last ecall, the pipeline stall in exe.

    // controller input signals, signals splited from IR
    wire [6:0] funct7_id;
    wire [2:0] funct3_id;
    wire [4:0] op_code_id;

    // signals splited from IR
    wire [4:0] r1_addr_id_, r2_addr_id_, r1_addr_id, r2_addr_id;
    wire [4:0] rd_addr_id, rd_addr_exe, rd_addr_mem, rd_addr_wb;  // (rd_addr appear in id, used in wb)
    wire [11:0] imm_I_id, imm_S_id, imm_B_id_;
    wire [19:0] imm_J_id_;
    // after extend
    wire [31:0] imm_B_id, imm_B_exe;
    wire [31:0] imm_J_id, imm_J_exe;

    // controller related signals
    wire [3:0] alu_op_id, alu_op_exe;                                           // alu_op 
    wire mem_to_reg_id, mem_to_reg_exe, mem_to_reg_mem, mem_to_reg_wb;          // mem_to_reg
    wire mem_write_id, mem_write_exe, mem_write_mem;                            // mem_write
    wire alu_src_id, alu_src_exe;                                                            // alu_src
    wire reg_write_id, reg_write_exe, reg_write_mem, reg_write_wb;              // reg_write
    wire ecall_id, ecall_exe;                                                   // ecall
    wire s_type_id;                                                             // s_type
    wire beq_id, beq_exe, bne_id, bne_exe, jal_id, jal_exe, jalr_id, jalr_exe;  // branch & jump related

    // helper vars
    wire [31:0] r1_id, r1_exe;  // r1/r2 will be used in exe
    wire [31:0] r2_id, r2_exe;
    wire [31:0] rd_in_wb;  // data that write into reg rd
    wire [11:0] Imm_I_S_id_;                // imm_I_id/imm_S_id before extended
    wire [31:0] Imm_I_S_id, imm_I_S_exe;    // possible src_B of the ALU(extended)

    // alu related wire
    wire [31:0] srcA_exe;  // srcA_exe = r1_exe in id
    wire [31:0] srcB_exe;  // srcB_exe is selected(r2_exe/imm_I_S_exe) in exe.
    wire [31:0] alu_res1_exe, alu_res1_mem, alu_res1_wb, alu_res2_exe, alu_res2_mem, alu_res2_wb;  // alu_res1/alu_res2      will be used in wb.
    wire alu_eq_exe, alu_greater_eq_exe, alu_lesser_exe;

    // DMem related signals
    wire [9:0] dmem_addr_exe, dmem_addr_mem;  // dmem_addr = alu_res[11:2]     (appear in exe, used in mem)
    wire [31:0] dmem_in_id, dmem_in_exe, dmem_in_mem;  // dmem_in = r2  (appear in id, used in mem)
    wire [31:0] dmem_out_mem, dmem_out_wb;  // (appear in mem, used in wb)

    // write back process related
    wire [31:0] wb_data_wb_, wb_data_wb;

    // branch/jump signal
    wire branch_exe;
    wire jump_exe, jump_mem, jump_wb;

    // led related signals
    wire if_led_exe;
    wire [31:0] led_data_exe;


    // ###################################################### //
    // ##################  logic begin   #################### //
    // ###################################################### //
    
    // assign pause_exe = pause;

    assign instr_addr_if = pc_cur_if[11:2];

    // split from instr
    assign funct7_id = instr_id[31:25];
    assign funct3_id = instr_id[14:12];
    assign op_code_id = instr_id[6:2];
    assign r1_addr_id_ = instr_id[19:15];
    assign r2_addr_id_ = instr_id[24:20];
    assign rd_addr_id = instr_id[11:7];
    assign imm_I_id = instr_id[31:20];
    assign imm_S_id = {instr_id[31:25], instr_id[11:7]};
    assign imm_B_id_ = {instr_id[31], instr_id[7], instr_id[30:25], instr_id[11:8]};
    assign imm_J_id_ = {instr_id[31], instr_id[19:12], instr_id[20], instr_id[30:21]};

    // alu input    srcB_exe has been assigned in module
    assign srcA_exe = r1_exe;

    // dmem related signals
    assign dmem_addr_exe = alu_res1_exe[11:2]; 
    assign dmem_in_id = r2_id;
    
    // branch & jump signal
    assign branch_exe = beq_exe && alu_eq_exe || bne_exe && (!alu_eq_exe);  // only used in exe
    assign jump_exe = jal_exe || jalr_exe;  // will be used in wb

    // write back data
    assign rd_in_wb = wb_data_wb;

    // jalr pc destination cal
    assign pc_next_3_exe = alu_res1_exe & 32'hffff_fffe;
    // pc = pc + 4
    assign pc_next_0_if = pc_cur_if + 'd4;

    // led logic
    assign if_led_exe = (srcA_exe == 32'h0000_0022) && ecall_exe;  // srcA_exe = r1_id
    assign pause = ~(srcA_exe == 32'h0000_0022) && ecall_exe;      // srcA_exe = r1_id

    // led display
    assign led_data_o = led_data_exe;

    // ###################################################### //
    // ##################   logic end    #################### //
    // ###################################################### //


    // ###################################################### //
    // #########     pipeline register begin    ############ //
    // ###################################################### //

    IF_ID if_id_reg(
        .clk                    (clk), 
        .rst                    (rst), 
        .en                     (~pause),
        .flush                  (1'b0),  // TODO: flush not yet used
        .pc_in                  (pc_cur_if), 
        .instr_in               (instr_if),
        .pc_out                 (pc_cur_id), 
        .instr_out              (instr_id)
    );

    ID_EXE id_exe_reg(
        .clk                                (clk), 
        .rst                                (rst),
        .en                                 (~pause), 
        .flush                              (1'b0),  // TODO: flush not yet used
        .pc_in                              (pc_cur_id), 
        .instr_in                           (instr_id),
        .jal_in                             (jal_id), 
        .jalr_in                            (jalr_id), 
        .beq_in                             (beq_id), 
        .bne_in                             (bne_id),  // have to use these signals because branch/jump signal hasn't generated until execution
        .mem_to_reg_in                      (mem_to_reg_id), 
        .mem_write_in                       (mem_write_id), 
        .reg_write_in                       (reg_write_id), 
        .ecall_in                           (ecall_id),
        .alu_src_in                         (alu_src_id),
        .alu_op_in                          (alu_op_id),
        .r1_in                              (r1_id), 
        .r2_in                              (r2_id),  // srcB is selected in exe
        .imm_I_S_in                         (Imm_I_S_id),
        .imm_B_in                           (imm_B_id), 
        .imm_J_in                           (imm_J_id),
        .rd_addr_in                         (rd_addr_id),
        .dmem_in_in                         (dmem_in_id),

        .pc_out                             (pc_cur_exe), 
        .instr_out                          (instr_exe),
        .jal_out                            (jal_exe), 
        .jalr_out                           (jalr_exe), 
        .beq_out                            (beq_exe), 
        .bne_out                            (bne_exe),
        .mem_to_reg_out                     (mem_to_reg_exe), 
        .mem_write_out                      (mem_write_exe), 
        .reg_write_out                      (reg_write_exe), 
        .ecall_out                          (ecall_exe),
        .alu_src_out                        (alu_src_exe),
        .alu_op_out                         (alu_op_exe),
        .r1_out                             (r1_exe), 
        .r2_out                             (r2_exe), 
        .imm_I_S_out                        (imm_I_S_exe),
        .imm_B_out                          (imm_B_exe), 
        .imm_J_out                          (imm_J_exe),  // imm is extended but not shifted 
        .rd_addr_out                        (rd_addr_exe),
        .dmem_in_out                        (dmem_in_exe)
    );

    EXE_MEM exe_mem_reg(
        .clk                                    (clk), 
        .rst                                    (rst), 
        .en                                     (~pause), 
        .flush                                  (1'b0),  // TODO: flush not yet used
        .pc_in                                  (pc_cur_exe), 
        .instr_in                               (instr_exe),
        .alu_res1_in                            (alu_res1_exe), 
        .alu_res2_in                            (alu_res2_exe),
        .mem_to_reg_in                          (mem_to_reg_exe), 
        .mem_write_in                           (mem_write_exe), 
        .reg_write_in                           (reg_write_exe),
        .dmem_in_in                             (dmem_in_exe),
        .dmem_addr_in                           (dmem_addr_exe),
        .jump_in                                (jump_exe),
        .rd_addr_in                             (rd_addr_exe),

        .pc_out                                 (pc_cur_mem), 
        .instr_out                              (instr_mem),
        .alu_res1_out                           (alu_res1_mem), 
        .alu_res2_out                           (alu_res2_mem),
        .mem_to_reg_out                         (mem_to_reg_mem), 
        .mem_write_out                          (mem_write_mem), 
        .reg_write_out                          (reg_write_mem),
        .dmem_in_out                            (dmem_in_mem),
        .dmem_addr_out                          (dmem_addr_mem),
        .jump_out                               (jump_mem),
        .rd_addr_out                            (rd_addr_mem)
    );

    MEM_WB mem_wb_reg(
        .clk                                (clk), 
        .rst                                (rst), 
        .en                                 (~pause), 
        .flush                              (1'b0),  // TODO: flush not yet used
        .pc_in                              (pc_cur_mem), 
        .instr_in                           (instr_mem),
        .mem_to_reg_in                      (mem_to_reg_mem), 
        .reg_write_in                       (reg_write_mem),
        .rd_addr_in                         (rd_addr_mem),
        .alu_res1_in                        (alu_res1_mem), 
        .alu_res2_in                        (alu_res2_mem),
        .dmem_out_in                        (dmem_out_mem),
        .jump_in                            (jump_mem),

        .pc_out                             (pc_cur_wb), 
        .instr_out                          (instr_wb),
        .mem_to_reg_out                     (mem_to_reg_wb), 
        .reg_write_out                      (reg_write_wb),
        .rd_addr_out                        (rd_addr_wb),
        .alu_res1_out                       (alu_res1_wb), 
        .alu_res2_out                       (alu_res2_wb),
        .dmem_out_out                       (dmem_out_wb),
        .jump_out                           (jump_wb)
    );

    // ###################################################### //
    // #########     pipeline register end      ############ //
    // ###################################################### //


    // ###################################################### //
    // #########          instance begin         ############ //
    // ###################################################### //

    // update pc  (appear in if)
    PC pc_updater(
        .pc_in      (pc_next),
        .clk        (clk), 
        .rst        (rst), 
        .pause      (pause),
        .pc_out     (pc_cur_if)
    );

    // next_pc selector (used in exe)
    PCSelector pc_selector(
        .jal            (jal_exe), 
        .jalr           (jalr_exe),
        .branch         (branch_exe),
        .pc_next_0      (pc_next_0_if), 
        .pc_next_1      (pc_next_1_exe), 
        .pc_next_2      (pc_next_2_exe),  
        .pc_next_3      (pc_next_3_exe),
        .pc_next        (pc_next)
    );

    // instruction mem (appear in if)
    Imem instr_memory(
        .addr   (instr_addr_if), 
        .instr  (instr_if)
    );
    
    // hard wired controller
    Controller controller(
        .funct7         (funct7_id),
        .funct3         (funct3_id),
        .op_code        (op_code_id),
        .op             (alu_op_id),
        .mem_to_reg     (mem_to_reg_id),
        .mem_write      (mem_write_id),
        .alu_src        (alu_src_id),
        .reg_write      (reg_write_id),
        .ecall          (ecall_id),
        .s_type         (s_type_id),
        .beq            (beq_id),
        .bne            (bne_id),
        .jal            (jal_id),
        .jalr           (jalr_id)
    );
    
    // r1/r2 selector   (used in id)
    Mux_1_2 #(.WIDTH(5)) r1_selector(
        .in1    (r1_addr_id_),
        .in2    (5'h11),
        .sel    (ecall),
        .out    (r1_addr_id)
    );
    Mux_1_2 #(.WIDTH(5)) r2_selector(
        .in1    (r2_addr_id_),
        .in2    (5'h0a),
        .sel    (ecall),
        .out    (r2_addr_id)
    );

    // RegFile  (used in id & wb)
    RegFile regfile(
        .din            (rd_in_wb),
        .r1_addr        (r1_addr_id),
        .r2_addr        (r2_addr_id),
        .w_addr         (rd_addr_wb),
        .clk            (clk),
        .write_en       (reg_write_wb),
        .r1             (r1_id),
        .r2             (r2_id)
    );

    // I/S imm selector (used in id)
    Mux_1_2 #(.WIDTH(12)) i_s_imm_selector(
        .in1    (imm_I_id),
        .in2    (imm_S_id),
        .sel    (s_type),
        .out    (Imm_I_S_id_)
    );

    // I/S imm sign extender    (used in id)
    ExtenderSign #(.INPUT_WIDTH(12), .OUTPUT_WIDTH(32)) i_s_extender(
        .in     (Imm_I_S_id_),
        .out    (Imm_I_S_id)
    );

    // branch imm sign extender (used in id)
    ExtenderSign #(.INPUT_WIDTH(12), .OUTPUT_WIDTH(32)) branch_extender(
        .in     (imm_B_id_),
        .out    (imm_B_id)
    );

    // jal imm sign extender    (used in id)
    ExtenderSign #(.INPUT_WIDTH(20), .OUTPUT_WIDTH(32)) jal_extender(
        .in     (imm_J_id_),
        .out    (imm_J_id)
    );

    // branch destination calculator    (used in exe)
    BranchDestCalculator branch_dest_calculator(
        .imm_B_32   (imm_B_exe),
        .cur_pc     (pc_cur_exe),
        .next_pc    (pc_next_1_exe)
    );

    // jal destination calculator   (used in exe)
    JalDestCalculator jal_dest_calculator(
        .imm_J_32   (imm_J_exe),
        .cur_pc     (pc_cur_exe),
        .next_pc    (pc_next_2_exe)
    );

    // Alu srcB selector    (used in exe)
    Mux_1_2 #(.WIDTH(32)) srcB_selector(
        .in1    (r2_exe),
        .in2    (imm_I_S_exe),
        .sel    (alu_src_exe),
        .out    (srcB_exe)
    );

    // ALU
    Alu alu(
        .a              (srcA_exe),
        .b              (srcB_exe),
        .op             (alu_op_exe),
        .result1        (alu_res1_exe),
        .result2        (alu_res2_exe),
        .eq             (alu_eq_exe), 
        .greater_eq     (alu_greater_eq_exe),
        .lesser         (alu_lesser_exe)
    );

    // DMem
    DMem data_memory(
        .addr   (dmem_addr_mem),
        .mem_in  (dmem_in_mem),
        .store  (mem_write_mem), 
        .load   (mem_to_reg_mem), 
        .clr    (rst), 
        .clk    (clk),
        .dout   (dmem_out_mem)
    );

    // wb_data selector1    if mem_to_reg, than mem_data will be wrote back (used in wb)
    Mux_1_2 #(.WIDTH(32)) wb_data_selector1(
        .in1    (alu_res1_wb),
        .in2    (dmem_out_wb),
        .sel    (mem_to_reg_wb),
        .out    (wb_data_wb_)
    );

    // wb_data selector2    if jal(r), than PC + 4 will be wrote back (used in wb)
    Mux_1_2 #(.WIDTH(32)) wb_data_selector2(
        .in1    (wb_data_wb_),
        .in2    (pc_cur_wb + 'd4),
        .sel    (jump_wb),
        .out    (wb_data_wb)
    );

    // led data latch   (used in exe)
    LedLatch led_latch(
        .if_led     (if_led_exe), 
        .clk        (clk), 
        .rst        (rst),
        .data_in    (r2_exe),
        .data_out   (led_data_exe)
    );

    // ###################################################### //
    // #########          instance end           ############ //
    // ###################################################### //


endmodule