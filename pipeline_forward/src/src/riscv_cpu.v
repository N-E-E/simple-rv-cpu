module RiscvCPU (
    input clk, rst, go,
    input [1:0] clk_sel,               //时钟选择 clk_sel: 00-1Hz, 01-10Hz, 10-50Hz, 11-100Hz 
    input [2:0] display_sel,           // 显示模式选择：display_sel: 000-led_data, 001-cycle, 010-num_ub, 011-num_cb, 100-num_bubble, 101-num_load_use
    output [7:0] seg_7_val, an,
    output pause
);

    reg pause_exe;
    wire pause_mem, pause_wb;

    // board related signals
    wire [31:0] bcd_cycle, bcd_num_ub, bcd_num_cb, bcd_num_bubble, bcd_num_load_use;
    wire clk_1, clk_10, clk_50, clk_100, clk_n;
    wire [31:0] led_display;

    wire [31:0] led_data_o, cycle, num_ub, num_cb, num_bubble, num_load_use;
    
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
    wire alu_src_id, alu_src_exe;                                               // alu_src
    wire reg_write_id, reg_write_exe, reg_write_mem, reg_write_wb;              // reg_write
    wire ecall_id, ecall_exe;                                                   // ecall
    wire s_type_id;                                                             // s_type
    wire beq_id, beq_exe, bne_id, bne_exe, bge_id, bge_exe, jal_id, jal_exe, jalr_id, jalr_exe;  // branch & jump related
    wire half_id, half_exe, half_mem, half_wb;
    wire csr_id;  // not yet used

    // helper vars
    wire [31:0] r1_id, r1_exe;  // r1/r2 will be used in exe
    wire [31:0] r2_id, r2_exe;
    wire [31:0] rd_in_wb;  // data that write into reg rd
    wire [11:0] Imm_I_S_id_;                // imm_I_id/imm_S_id before extended
    wire [31:0] Imm_I_S_id, imm_I_S_exe;    // possible src_B of the ALU(extended)

    // alu related wire
    wire [31:0] srcA_exe_, srcA_exe;   // srcA_exe = srcA_exe_ in id
    wire [31:0] srcB_exe_, srcB_exe;  // srcB_exe is selected(srcB_exe_/imm_I_S_exe) in exe.
    wire [31:0] alu_res1_exe, alu_res1_mem, alu_res1_wb, alu_res2_exe, alu_res2_mem, alu_res2_wb;  // alu_res1/alu_res2      will be used in wb.
    wire alu_eq_exe, alu_greater_eq_exe, alu_lesser_exe;

    // DMem related signals
    wire [9:0] dmem_addr_exe, dmem_addr_mem;  // dmem_addr = alu_res[11:2]     (appear in exe, used in mem)
    wire [31:0] dmem_in_exe, dmem_in_mem;  // dmem_in = r2  (appear in id, used in mem)
    wire [31:0] dmem_out_mem, dmem_out_wb, dmem_out_wb_;  // (appear in mem, used in wb)
    wire high_wb;

    // write back process related
    wire [31:0] wb_data_wb_, wb_data_wb;

    // branch/jump signal
    wire branch_exe;  
    wire jump_exe;  
    wire jump_mem, jump_wb;

    // led related signals
    wire if_led_exe;
    wire [31:0] led_data_exe;

    // conflict related signals
    wire branch_taken;  // = branch_exe || jump_exe     
    reg branch_taken_reg;  // must use a reg. or cause the combination loop
    wire load_use;
    reg load_use_reg;  // must use a reg. or cause the combination loop
    wire stall;
    reg stall_reg;  // must use a reg. or cause the combination loop
    
    wire [1:0] r1_forward_id, r1_forward_exe, r2_forward_id, r2_forward_exe;


    // ###################################################### //
    // ##################  logic begin   #################### //
    // ###################################################### //

    assign pause = pause_wb;
    
    // solve the combination loop problem
    initial begin
        pause_exe <= 0;
        branch_taken_reg <= 0;
        stall_reg <= 0;
        load_use_reg <= 0;
    end

    always @(negedge clk_n) begin
        branch_taken_reg <= branch_taken;
        load_use_reg <= load_use;
        stall_reg <= stall;
    end

    // instr_addr
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

    // alu input    srcB_exe has been assigned in module srcB_selector.
    assign srcA_exe = srcA_exe_;

    // dmem related signals
    assign dmem_addr_exe = alu_res1_exe[11:2]; 
    assign dmem_in_exe = srcB_exe_;
    assign high_wb = alu_res1_wb[1:1];
    
    // branch & jump signal
    // initial begin
    //     branch_exe <= 0;
    //     jump_exe <= 0;
    // end
    // always @(negedge clk) begin
    //     branch_exe = beq_exe && alu_eq_exe || bne_exe && (!alu_eq_exe) || bge_exe && alu_greater_eq_exe;  // only used in exe
    //     jump_exe = jal_exe || jalr_exe;  // will be used in wb
    // end
    assign branch_exe = beq_exe && alu_eq_exe || bne_exe && (!alu_eq_exe) || bge_exe && alu_greater_eq_exe;  // only used in exe
    assign jump_exe = jal_exe || jalr_exe;  // will be used in wb

    // write back data
    assign rd_in_wb = wb_data_wb;

    // jalr pc destination cal
    assign pc_next_3_exe = alu_res1_exe & 32'hffff_fffe;
    // pc = pc + 4
    assign pc_next_0_if = pc_cur_if + 'd4;

    // led logic
    assign if_led_exe = (srcA_exe_ == 32'h0000_0022) && ecall_exe;  // srcA_exe_ = r1_id
    always @(negedge clk_n) begin  // TODO: this method is not good
        pause_exe = !(srcA_exe_ == 32'h0000_0022) && ecall_exe;
    end      // srcA_exe_ = r1_id

    // led display
    assign led_data_o = led_data_exe;

    // conflict logic
    assign stall = load_use;

    // num_bubble = num_load_use
    assign num_bubble = num_load_use;

    // ###################################################### //
    // ##################   logic end    #################### //
    // ###################################################### //


    // ###################################################### //
    // #########     pipeline register begin    ############ //
    // ###################################################### //

    IF_ID if_id_reg(
        .clk                    (clk_n), 
        .rst                    (rst), 
        .en                     ((!pause_wb || go) && !stall_reg),
        .flush                  (branch_taken_reg),  // TODO: flush not yet used
        .pc_in                  (pc_cur_if), 
        .instr_in               (instr_if),

        .pc_out                 (pc_cur_id), 
        .instr_out              (instr_id)
    );

    ID_EXE id_exe_reg(
        .clk                                (clk_n), 
        .rst                                (rst),
        .en                                 (!pause_wb || go), 
        .flush                              (branch_taken_reg || load_use_reg),  // TODO: flush not yet used
        .pc_in                              (pc_cur_id), 
        .instr_in                           (instr_id),
        .jal_in                             (jal_id), 
        .jalr_in                            (jalr_id), 
        .beq_in                             (beq_id), 
        .bne_in                             (bne_id),  // have to use these signals because branch/jump signal hasn't generated until execution
        .bge_in                             (bge_id),
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
        .r1_forward_in                      (r1_forward_id),
        .r2_forward_in                      (r2_forward_id),
        .half_in                            (half_id),

        .pc_out                             (pc_cur_exe), 
        .instr_out                          (instr_exe),
        .jal_out                            (jal_exe), 
        .jalr_out                           (jalr_exe), 
        .beq_out                            (beq_exe), 
        .bne_out                            (bne_exe),
        .bge_out                            (bge_exe),
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
        .r1_forward_out                     (r1_forward_exe),
        .r2_forward_out                     (r2_forward_exe),
        .half_out                           (half_exe)
    );

    EXE_MEM exe_mem_reg(
        .clk                                    (clk_n), 
        .rst                                    (rst), 
        .en                                     (!pause_wb || go), 
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
        .half_in                                (half_exe),
        .pause_in                               (pause_exe),

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
        .rd_addr_out                            (rd_addr_mem),
        .half_out                               (half_mem),
        .pause_out                              (pause_mem)
    );

    MEM_WB mem_wb_reg(
        .clk                                (clk_n), 
        .rst                                (rst), 
        .en                                 (!pause_wb || go), 
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
        .half_in                            (half_mem),
        .pause_in                           (pause_mem),

        .pc_out                             (pc_cur_wb), 
        .instr_out                          (instr_wb),
        .mem_to_reg_out                     (mem_to_reg_wb), 
        .reg_write_out                      (reg_write_wb),
        .rd_addr_out                        (rd_addr_wb),
        .alu_res1_out                       (alu_res1_wb), 
        .alu_res2_out                       (alu_res2_wb),
        .dmem_out_out                       (dmem_out_wb_),
        .jump_out                           (jump_wb),
        .half_out                           (half_wb),
        .pause_out                          (pause_wb)
    );

    // ###################################################### //
    // #########     pipeline register end      ############ //
    // ###################################################### //


    // ###################################################### //
    // #########          instance begin         ############ //
    // ###################################################### //

//    Divider #(50000000) divider1(.clk(clk), .clk_N(clk_1));  // 生成1Hz的时钟信�?
    Divider #(1) divider1(.clk(clk), .clk_N(clk_1));  // 生成1Hz的时钟信�?

    Divider #(5000000)  divider2(.clk(clk), .clk_N(clk_10));  // 生成10Hz的时钟信�?
    Divider #(1000000)  divider3(.clk(clk), .clk_N(clk_50));  // 生成50Hz的时钟信�?
    Divider #(500000)  divider4(.clk(clk), .clk_N(clk_100));  // 生成100Hz的时钟信�? 

    mux_2_4 #(1) mux_clk(
        .in0(clk_1), 
        .in1(clk_10), 
        .in2(clk_50), 
        .in3(clk_100), 
        .sel(clk_sel),
        .out(clk_n)
    );

    BinToBCD bin_to_bcd_cycle(
        .Bin    (cycle),
        .BCD    (bcd_cycle)
    );

    BinToBCD bin_to_bcd_ub(
        .Bin    (num_ub),
        .BCD    (bcd_num_ub)
    );

    BinToBCD bin_to_bcd_cb(
        .Bin    (num_cb),
        .BCD    (bcd_num_cb)
    );

    BinToBCD bin_to_bcd_bubble(
        .Bin    (num_bubble),
        .BCD    (bcd_num_bubble)
    );

    BinToBCD bin_to_bcd_load_use(
        .Bin    (num_load_use),
        .BCD    (bcd_num_load_use)
    );

    mux_3_8 #(32) mux_display(
        .in0(led_data_o), 
        .in1(bcd_cycle), 
        .in2(bcd_num_ub), 
        .in3(bcd_num_cb), 
        .in4(bcd_num_bubble), 
        .in5(bcd_num_load_use), 
        .in6(0), 
        .in7(0), 
        .sel(display_sel), 
        .out(led_display)
    );

    DigitDisplay digit_display( //数码管信息产�?
        .LedData(led_display),
        .CLK(clk),
        .SEG(seg_7_val),
        .AN(an)
    ); 

    // cycle counter
    Counter cycle_counter(
        .clk        (clk_n), 
        .pause      (pause_wb), 
        .rst        (rst),
        .go         (go),
        .out        (cycle)
    );

    // ub counter
    Counter ub_counter(
        .clk        (clk_n), 
        .pause      (~(jal_id || jalr_id)), 
        .rst        (rst),
        .go         (0),
        .out        (num_ub)
    );

    // cb counter
    Counter cb_counter(
        .clk        (clk_n), 
        .pause      (~branch_exe), 
        .rst        (rst),
        .go         (0),
        .out        (num_cb)
    );

    // load_use counter
    Counter load_use_counter(
        .clk        (clk_n), 
        .pause      (~load_use_reg), 
        .rst        (rst),
        .go         (0),
        .out        (num_load_use)
    );

    // branch_taken detector
    BranchDetector branch_detector(
        .branch         (branch_exe),
        .jump           (jump_exe),
        .branch_taken   (branch_taken)
    );

    // load_use detector
    LoadUseDetector load_use_detector(
        .alu_src_id         (alu_src_id), 
        .s_type_id          (s_type_id), 
        .jal_id             (jal_id),
        .reg_write_exe      (reg_write_exe), 
        .mem_to_reg_exe     (mem_to_reg_exe),
        .r1_addr_id         (r1_addr_id), 
        .r2_addr_id         (r2_addr_id),
        .rd_addr_exe        (rd_addr_exe), 
        .load_use           (load_use)
    );

    // forward calculator. use in id
    ForwardCalculator forward_calculator(
        .alu_src_id         (alu_src_id), 
        .s_type_id          (s_type_id), 
        .jal_id             (jal_id),
        .reg_write_exe      (reg_write_exe),
        .reg_write_mem      (reg_write_mem),
        .r1_addr_id         (r1_addr_id), 
        .r2_addr_id         (r2_addr_id),
        .rd_addr_exe        (rd_addr_exe), 
        .rd_addr_mem        (rd_addr_mem),
        .r1_forward_id      (r1_forward_id), 
        .r2_forward_id      (r2_forward_id)
    );

    // forward selector.  used in exe
    ForwardSelector forward_selector_A(
        .forward        (r1_forward_exe),
        .r_exe          (r1_exe), 
        .alu_res_mem    (alu_res1_mem), 
        .rd_in_wb       (rd_in_wb),
        .src            (srcA_exe_)   
    );
    ForwardSelector forward_selector_B(
        .forward        (r2_forward_exe),
        .r_exe          (r2_exe), 
        .alu_res_mem    (alu_res1_mem), 
        .rd_in_wb       (rd_in_wb),
        .src            (srcB_exe_)   
    );

    // update pc  (appear in if)
    PC pc_updater(
        .pc_in      (pc_next),
        .clk        (clk_n), 
        .rst        (rst), 
        .pause      (pause_wb),
        .stall      (stall_reg),
        .go         (go),
        .pc_out     (pc_cur_if)
    );

    // next_pc selector (used in exe)
    PCSelector pc_selector(
        .jal            (jal_exe), 
        .jalr           (jalr_exe),
        .branch         (branch_exe),
        .pc_next_0      (pc_next_0_if),   // +4
        .pc_next_1      (pc_next_1_exe),   // branch
        .pc_next_2      (pc_next_2_exe),  // jal
        .pc_next_3      (pc_next_3_exe),  // jalr
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
        .jalr           (jalr_id),
        .half           (half_id),
        .bge            (bge_id),
        .csr            (csr_id)
    );
    
    // r1/r2 selector   (used in id)
    Mux_1_2 #(.WIDTH(5)) r1_selector(
        .in1    (r1_addr_id_),
        .in2    (5'h11),
        .sel    (ecall_id),
        .out    (r1_addr_id)
    );
    Mux_1_2 #(.WIDTH(5)) r2_selector(
        .in1    (r2_addr_id_),
        .in2    (5'h0a),
        .sel    (ecall_id),
        .out    (r2_addr_id)
    );

    // RegFile  (used in id & wb)
    RegFile regfile(
        .din            (rd_in_wb),
        .r1_addr        (r1_addr_id),
        .r2_addr        (r2_addr_id),
        .w_addr         (rd_addr_wb),
        .clk            (clk_n),
        .write_en       (reg_write_wb),
        .r1             (r1_id),
        .r2             (r2_id)
    );

    // I/S imm selector (used in id)
    Mux_1_2 #(.WIDTH(12)) i_s_imm_selector(
        .in1    (imm_I_id),
        .in2    (imm_S_id),
        .sel    (s_type_id),
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
        .in1    (srcB_exe_),
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
        .clk    (clk_n),
        .dout   (dmem_out_mem)
    );

    // wb_data selector0    if half, then use lhu instr
    Mux_1_2 #(.WIDTH(32)) wb_data_selector0(
        .in1    (dmem_out_wb_),
        .in2    ((high_wb == 1) ? (dmem_out_wb_ & 'hffff0000) >> 16 : dmem_out_wb_ & 'h0000ffff),
        .sel    (half_wb),
        .out    (dmem_out_wb)
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
        .clk        (clk_n), 
        .rst        (rst),
        .data_in    (srcB_exe_),
        .data_out   (led_data_exe)
    );

    // ###################################################### //
    // #########          instance end           ############ //
    // ###################################################### //


endmodule