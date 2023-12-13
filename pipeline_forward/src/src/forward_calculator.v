module ForwardCalculator (
    input alu_src_id, s_type_id, jal_id,
    input reg_write_exe, reg_write_mem,
    input [4:0] r1_addr_id, r2_addr_id,
    input [4:0] rd_addr_exe, rd_addr_mem,
    output [1:0] r1_forward_id, r2_forward_id
);
    wire r1_used, r2_used;
    reg [1:0] r1_forward_, r2_forward_;
    
    assign r1_used = (jal_id == 1) ? 0 : 1;
    assign r2_used = (jal_id == 1) ? 0 :
                        (alu_src_id == 1 && s_type_id == 0) ? 0 : 1;

    always @(*) begin
        if (r1_used && (r1_addr_id != 0) && reg_write_exe && (r1_addr_id == rd_addr_exe)) r1_forward_ = 'd2;
        else if (r1_used && (r1_addr_id != 0) && reg_write_mem && (r1_addr_id == rd_addr_mem)) r1_forward_ = 'd1;
        else r1_forward_ = 'd0;

        if (r2_used && (r2_addr_id != 0) && reg_write_exe && (r2_addr_id == rd_addr_exe)) r2_forward_ = 'd2;
        else if (r2_used && (r2_addr_id != 0) && reg_write_mem && (r2_addr_id == rd_addr_mem)) r2_forward_ = 'd1;
        else r2_forward_ = 'd0;
    end

    assign r1_forward_id = r1_forward_;
    assign r2_forward_id = r2_forward_;

    
endmodule