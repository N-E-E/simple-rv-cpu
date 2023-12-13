module RiscvCPU (
    input clk, rst, go,  // clk is simulation signals or clock on the board
    input [1:0] clk_sel, display_sel,  //时钟与显示模式的选择 clk_sel: 00-1Hz, 01-10Hz, 10-50Hz, 11-100Hz | display_sel: 00-led_data, 01-pc, 10-instr, 11-cycle
    output [7:0] seg_7_val, an,
    output reg pause
);

    initial begin pause = 0; end

    // board related signals
    wire [31:0] bcd;
    wire clk_1, clk_10, clk_50, clk_100, clk_n;
    wire [31:0] led_display;

    wire [31:0] led_data_o, cycle;
    
    // pc & instr
    wire [31:0] pc_cur;
    wire [31:0] pc_next;
    wire [31:0] pc_next_0, pc_next_1, pc_next_2, pc_next_3;
    wire [31:0] instr;  // instruction
    wire [9:0] instr_addr;

    // controller input signals, signals splited from IR
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [4:0] op_code;

    // signals splited from IR
    wire [4:0] r1_addr_, r2_addr_, r1_addr, r2_addr, rd_addr;
    wire [11:0] imm_I, imm_S, imm_B;
    wire [19:0] imm_J;

    // controller output signals
    wire [3:0] op; 
    wire mem_to_reg, mem_write, alu_src, reg_write, ecall, s_type, beq, bne, jal, jalr, half, bge, csr;

    // helper vars
    wire [31:0] r1, r2;
    wire [31:0] rd_in;  // data that write into reg rd
    wire [11:0] Imm_I_S_;  // possible src_B of the ALU
    wire [31:0] Imm_I_S;  // possible src_B of the ALU(extended)

    // alu related wire
    wire [31:0] srcA, srcB, alu_res1, alu_res2;
    wire alu_eq, alu_greater_eq, alu_lesser;

    // DMem related signals
    wire [9:0] dmem_addr;
    wire [31:0] dmem_in, dmem_out, dmem_out_;
    wire high;

    // write back process related
    wire [31:0] wb_data_, wb_data;

    // branch/jump signal
    wire branch, jump;

    // led related signals
    wire if_led;
    wire [31:0] led_data;


    // ############# logic begin ################ //
    
    // update pc ?
//    initial begin
//        pc_cur = 32'b0;
//    end
//    pc_cur = 32'b0;
    assign instr_addr = pc_cur[11:2];

    // split from instr
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign op_code = instr[6:2];
    assign r1_addr_ = instr[19:15];
    assign r2_addr_ = instr[24:20];
    assign rd_addr = instr[11:7];
    assign imm_I = instr[31:20];
    assign imm_S = {instr[31:25], instr[11:7]};
    assign imm_B = {instr[31], instr[7], instr[30:25], instr[11:8]};
    assign imm_J = {instr[31], instr[19:12], instr[20], instr[30:21]};

    // alu input    srcB has been assigned in module
    assign srcA = r1;

    // dmem
    assign dmem_addr = alu_res1[11:2]; 
    assign high = alu_res1[1:1];
    
    // branch & jump signal
    assign branch = beq && alu_eq || bne && (!alu_eq) || bge && alu_greater_eq;
    assign jump = jal || jalr;

    // write back data
    assign rd_in = wb_data;

    // jalr pc destination cal
    assign pc_next_3 = alu_res1 & 32'hffff_fffe;
    // pc = pc + 4
    assign pc_next_0 = pc_cur + 'd4;

    // led logic
    assign if_led = (r1 == 32'h0000_0022) && ecall;
    always @(*) begin
        pause = ~(r1 == 32'h0000_0022) && ecall;
    end
    // assign pause = ~(r1 == 32'h0000_0022) && ecall;

    // simulation display
    assign led_data_o = led_data;


    // ######### instance ########## //

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

    BinToBCD bin_to_bcd(
        .Bin    (cycle),
        .BCD    (bcd)
    );

    mux_2_4 #(32) mux_display(
        .in0(led_data_o), 
        .in1(pc_cur), 
        .in2(instr), 
        .in3(bcd), 
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
        .pause      (pause), 
        .rst        (rst),
        .out        (cycle)
    );

    // update pc
    PC pc_updater(
        .pc_in      (pc_next),
        .clk        (clk_n), 
        .rst        (rst), 
        .pause      (pause),
        .go         (go),
        .pc_out     (pc_cur)
    );

    // next_pc selector
    PCSelector pc_selector(
        .jal            (jal), 
        .jalr           (jalr),
        .branch         (branch),
        .pc_next_0      (pc_next_0), 
        .pc_next_1      (pc_next_1), 
        .pc_next_2      (pc_next_2),  
        .pc_next_3      (pc_next_3),
        .pc_next        (pc_next)
    );

    Imem instr_mem(
        .addr   (instr_addr), 
        .instr  (instr)
    );

    Controller controller(
        .funct7         (funct7),
        .funct3         (funct3),
        .op_code        (op_code),
        .op             (op),
        .mem_to_reg     (mem_to_reg),
        .mem_write      (mem_write),
        .alu_src        (alu_src),
        .reg_write      (reg_write),
        .ecall          (ecall),
        .s_type         (s_type),
        .beq            (beq),
        .bne            (bne),
        .jal            (jal),
        .jalr           (jalr),
        .half           (half),
        .bge            (bge),
        .csr            (csr)
    );
    
    // r1/r2 selector
    Mux_1_2 #(.WIDTH(5)) r1_selector(
        .in1    (r1_addr_),
        .in2    (5'h11),
        .sel    (ecall),
        .out    (r1_addr)
    );
    Mux_1_2 #(.WIDTH(5)) r2_selector(
        .in1    (r2_addr_),
        .in2    (5'h0a),
        .sel    (ecall),
        .out    (r2_addr)
    );

    // RegFile
    RegFile regfile(
        .din    (rd_in),
        .r1_addr        (r1_addr),
        .r2_addr        (r2_addr),
        .w_addr         (rd_addr),
        .clk            (clk_n),
        .write_en       (reg_write),
        .r1             (r1),
        .r2             (r2)
    );

    // I/S imm selector
    Mux_1_2 #(.WIDTH(12)) i_s_imm_selector(
        .in1    (imm_I),
        .in2    (imm_S),
        .sel    (s_type),
        .out    (Imm_I_S_)
    );

    // I/S imm sign extender
    ExtenderSign i_s_extender(
        .in     (Imm_I_S_),
        .out    (Imm_I_S)
    );

    // branch destination calculator
    BranchDestCalculator branch_dest_calculator(
        .imm_B      (imm_B),
        .cur_pc     (pc_cur),
        .next_pc    (pc_next_1)
    );

    // jal destination calculator
    JalDestCalculator jal_dest_calculator(
        .imm_J      (imm_J),
        .cur_pc     (pc_cur),
        .next_pc    (pc_next_2)
    );

    // Alu srcB selector
    Mux_1_2 #(.WIDTH(32)) srcB_selector(
        .in1    (r2),
        .in2    (Imm_I_S),
        .sel    (alu_src),
        .out    (srcB)
    );

    // ALU
    Alu alu(
        .a              (srcA),
        .b              (srcB),
        .op             (op),
        .result1        (alu_res1),
        .result2        (alu_res2),
        .eq             (alu_eq), 
        .greater_eq     (alu_greater_eq),
        .lesser         (alu_lesser)
    );

    // DMem
    DMem data_mem(
        .addr   (dmem_addr),
        .mem_in  (r2),
        .store  (mem_write), 
        .load   (mem_to_reg), 
        .clr    (rst), 
        .clk    (clk_n),
        .dout   (dmem_out_)
    );

    // wb_data selector0    if half, then use lhu instr
    Mux_1_2 #(.WIDTH(32)) wb_data_selector0(
        .in1    (dmem_out_),
        .in2    ((high == 1) ? (dmem_out_ & 'hffff0000) >> 16 : dmem_out_ & 'h0000ffff),
        .sel    (half),
        .out    (dmem_out)
    );

    // wb_data selector1    if mem_to_reg, then mem_data will be wrote back
    Mux_1_2 #(.WIDTH(32)) wb_data_selector1(
        .in1    (alu_res1),
        .in2    (dmem_out),
        .sel    (mem_to_reg),
        .out    (wb_data_)
    );

    // wb_data selector2    if jal(r), than PC + 4 will be wrote back
    Mux_1_2 #(.WIDTH(32)) wb_data_selector2(
        .in1    (wb_data_),
        .in2    (pc_cur + 'd4),
        .sel    (jump),
        .out    (wb_data)
    );

    // led data latch
    LedLatch led_latch(
        .if_led     (if_led), 
        .clk        (clk_n), 
        .rst        (rst),
        .data_in    (r2),
        .data_out   (led_data)
    );


endmodule