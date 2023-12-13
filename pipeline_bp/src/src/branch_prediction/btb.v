module BTB (
    input clk, rst,
    input [31:0] pc_if, pc_exe,  // pc_if for read, pc_exe for update
    input update_flag_exe, branch_taken_exe,
    input [31:0] branch_addr_exe,
    output predict_jump,
    output reg [31:0] jump_addr
);
    // btb record
    reg valid[7:0];
    reg [31:0] branch_pc_addr[7:0];
    reg [31:0] target_pc_addr[7:0];
    wire [1:0] state[7:0];
    wire [4:0] lru_counter[7:0];  // replace flag (for lru strategy)

    reg hit_read_[7:0];
    reg hit_write_[7:0];
    wire [7:0] hit_read;  // if there is a hit when read. should be pipelined?
    wire [7:0] hit_write;
    wire hit_flag_read, hit_flag_update;
    wire [2:0] hit_index_read, hit_index_update;
    wire new_btb_record;
    reg [2:0] replace_index;
    
    integer i;
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            valid[i] = 1'b0;
            branch_pc_addr[i] = 32'b0;
            target_pc_addr[i] = 32'b0;
            jump_addr[i] = 32'b0;
            // state[i] = 2'b0;
            // lru_counter[i] = 5'b0;
        end
    end


    assign hit_read = {hit_read_[7], hit_read_[6], hit_read_[5], hit_read_[4], hit_read_[3], hit_read_[2], hit_read_[1], hit_read_[0]};
    assign hit_write = {hit_write_[7], hit_write_[6], hit_write_[5], hit_write_[4], hit_write_[3], hit_write_[2], hit_write_[1], hit_write_[0]};
    assign hit_flag_read = (hit_read == 8'b0000_0000) ? 0 : 1;
    assign hit_flag_update = (hit_write == 8'b0000_0000) ? 0 : 1;

    assign hit_index_read = (hit_read_[0] == 1) ? 0 : 
                            (hit_read_[1] == 1) ? 1 :
                            (hit_read_[2] == 1) ? 2 :
                            (hit_read_[3] == 1) ? 3 :
                            (hit_read_[4] == 1) ? 4 :
                            (hit_read_[5] == 1) ? 5 :
                            (hit_read_[6] == 1) ? 6 :
                            (hit_read_[7] == 1) ? 7 : 0;  // make it error

    assign hit_index_update = (hit_write_[0] == 1) ? 0 : 
                              (hit_write_[1] == 1) ? 1 :
                              (hit_write_[2] == 1) ? 2 :
                              (hit_write_[3] == 1) ? 3 :
                              (hit_write_[4] == 1) ? 4 :
                              (hit_write_[5] == 1) ? 5 :
                              (hit_write_[6] == 1) ? 6 :
                              (hit_write_[7] == 1) ? 7 : 0;  // make it error


    assign predict_jump = hit_flag_read && ((state[hit_index_read] == 2'b10) || (state[hit_index_read] == 2'b11));

    assign new_btb_record = update_flag_exe && (!hit_flag_update);


    // ########### check hit (in if/exe) ############ //
    always @(*) begin  // selector
        if (hit_read_[0] && valid[0] == 1) jump_addr = target_pc_addr[0];
        else if (hit_read_[1] && valid[1] == 1) jump_addr = target_pc_addr[1];
        else if (hit_read_[2] && valid[2] == 1) jump_addr = target_pc_addr[2];
        else if (hit_read_[3] && valid[3] == 1) jump_addr = target_pc_addr[3];
        else if (hit_read_[4] && valid[4] == 1) jump_addr = target_pc_addr[4];
        else if (hit_read_[5] && valid[5] == 1) jump_addr = target_pc_addr[5];
        else if (hit_read_[6] && valid[6] == 1) jump_addr = target_pc_addr[6];
        else if (hit_read_[7] && valid[7] == 1) jump_addr = target_pc_addr[7];
        else jump_addr = 32'b0;
    end

    always @(*) begin
        if (valid[0] == 1) begin
            hit_read_[0] = (pc_if == branch_pc_addr[0]);
            hit_write_[0] = (pc_exe == branch_pc_addr[0]);
        end
        else begin
            hit_read_[0] = 0;
            hit_write_[0] = 0;
        end
    end

    always @(*) begin
        if (valid[1] == 1) begin
            hit_read_[1] = (pc_if == branch_pc_addr[1]);
            hit_write_[1] = (pc_exe == branch_pc_addr[1]);
        end
        else begin
            hit_read_[1] = 0;
            hit_write_[1] = 0;
        end
    end

    always @(*) begin
        if (valid[2] == 1) begin
            hit_read_[2] = (pc_if == branch_pc_addr[2]);
            hit_write_[2] = (pc_exe == branch_pc_addr[2]);
        end
        else begin
            hit_read_[2] = 0;
            hit_write_[2] = 0;
        end
    end

    always @(*) begin
        if (valid[3] == 1) begin
            hit_read_[3] = (pc_if == branch_pc_addr[3]);
            hit_write_[3] = (pc_exe == branch_pc_addr[3]);
        end
        else begin
            hit_read_[3] = 0;
            hit_write_[3] = 0;
        end
    end

    always @(*) begin
        if (valid[4] == 1) begin 
            hit_read_[4] = (pc_if == branch_pc_addr[4]);
            hit_write_[4] = (pc_exe == branch_pc_addr[4]);
        end
        else begin
            hit_read_[4] = 0;
            hit_write_[4] = 0;
        end
    end

    always @(*) begin
        if (valid[5] == 1) begin
            hit_read_[5] = (pc_if == branch_pc_addr[5]);
            hit_write_[5] = (pc_exe == branch_pc_addr[5]);
        end
        else begin
            hit_read_[5] = 0;
            hit_write_[5] = 0;
        end
    end

    always @(*) begin
        if (valid[6] == 1) begin
            hit_read_[6] = (pc_if == branch_pc_addr[6]);
            hit_write_[6] = (pc_exe == branch_pc_addr[6]);
        end
        else begin
            hit_read_[6] = 0;
            hit_write_[6] = 0;
        end
    end

    always @(*) begin
        if (valid[7] == 1) begin
            hit_read_[7] = (pc_if == branch_pc_addr[7]);
            hit_write_[7] = (pc_exe == branch_pc_addr[7]);
        end
        else begin
            hit_read_[7] = 0;
            hit_write_[7] = 0;
        end
    end


    // ############# update a new record ############//
    always @(posedge clk) begin
        if (new_btb_record) begin
            valid[replace_index] = 1;
            branch_pc_addr[replace_index] = pc_exe;
            target_pc_addr[replace_index] = branch_addr_exe;
        end
    end

    // ########## lru replacer ######### //
    integer j;
    reg find_replce;
    reg [4:0] max_counter;
    reg [2:0] max_counter_index;
    reg [2:0] replace_index_;

    initial begin
        max_counter_index = 0;
        max_counter = 0;
    end

    always @(*) begin
        find_replce = 0;
        max_counter = 0;
        max_counter_index = 0;
        for (j = 0; j < 8 && !find_replce; j = j + 1) begin
            if (valid[j] == 0) begin
                find_replce = 1;
                replace_index_ = j;
            end
            if (lru_counter[j] > max_counter) begin
                max_counter = lru_counter[j];
                max_counter_index = j;
            end
        end

        if (find_replce == 0) begin
            replace_index = max_counter_index;
        end
        else replace_index = replace_index_;
    end


    // ############ lru counter (update in exe) ############## //
    LRUCounter lru_counter_0(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 0))),
        .en(valid[0] && update_flag_exe),  // update only when meet branch
        .hit(hit_write_[0]),
        .counter(lru_counter[0])
    );

    LRUCounter lru_counter_1(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 1))),
        .en(valid[1] && update_flag_exe),
        .hit(hit_write_[1]),
        .counter(lru_counter[1])
    );

    LRUCounter lru_counter_2(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 2))),
        .en(valid[2] && update_flag_exe),
        .hit(hit_write_[2]),
        .counter(lru_counter[2])
    );

    LRUCounter lru_counter_3(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 3))),
        .en(valid[3] && update_flag_exe),
        .hit(hit_write_[3]),
        .counter(lru_counter[3])
    );

    LRUCounter lru_counter_4(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 4))),
        .en(valid[4] && update_flag_exe),
        .hit(hit_write_[4]),
        .counter(lru_counter[4])
    );

    LRUCounter lru_counter_5(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 5))),
        .en(valid[5] && update_flag_exe),
        .hit(hit_write_[5]),
        .counter(lru_counter[5])
    );

    LRUCounter lru_counter_6(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 6))),
        .en(valid[6] && update_flag_exe),
        .hit(hit_write_[6]),
        .counter(lru_counter[6])
    );

    LRUCounter lru_counter_7(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 7))),
        .en(valid[7] && update_flag_exe),
        .hit(hit_write_[7]),
        .counter(lru_counter[7])
    );


    // ######### branch fsm   (update in exe) ######### //
    BranchFSM fsm_0(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 0))),
        .update(hit_flag_update && (hit_index_update == 0)),
        .jump(branch_taken_exe),
        .cur_state(state[0])
    );

    BranchFSM fsm_1(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 1))),
        .update(hit_flag_update && (hit_index_update == 1)),
        .jump(branch_taken_exe),
        .cur_state(state[1])
    );

    BranchFSM fsm_2(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 2))),
        .update(hit_flag_update && (hit_index_update == 2)),
        .jump(branch_taken_exe),
        .cur_state(state[2])
    );

    BranchFSM fsm_3(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 3))),
        .update(hit_flag_update && (hit_index_update == 3)),
        .jump(branch_taken_exe),
        .cur_state(state[3])
    );

    BranchFSM fsm_4(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 4))),
        .update(hit_flag_update && (hit_index_update == 4)),
        .jump(branch_taken_exe),
        .cur_state(state[4])
    );

    BranchFSM fsm_5(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 5))),
        .update(hit_flag_update && (hit_index_update == 5)),
        .jump(branch_taken_exe),
        .cur_state(state[5])
    );

    BranchFSM fsm_6(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 6))),
        .update(hit_flag_update && (hit_index_update == 6)),
        .jump(branch_taken_exe),
        .cur_state(state[6])
    );

    BranchFSM fsm_7(
        .clk(clk), 
        .rst(rst || (new_btb_record && (replace_index == 7))),
        .update(hit_flag_update && (hit_index_update == 7)),
        .jump(branch_taken_exe),
        .cur_state(state[7])
    );


endmodule