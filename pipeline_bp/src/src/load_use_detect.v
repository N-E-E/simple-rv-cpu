module LoadUseDetector (  // detect in id
    input alu_src_id, s_type_id, jal_id,
    input reg_write_exe, mem_to_reg_exe,
    input [4:0] r1_addr_id, r2_addr_id,
    input [4:0] rd_addr_exe,
    output load_use
);
    wire r1_used, r2_used;

    assign r1_used = (jal_id == 1) ? 0 : 1;
    assign r2_used = (jal_id == 1) ? 0 :
                        (alu_src_id == 1 && s_type_id == 0) ? 0 : 1;

    assign load_use = r1_used && (r1_addr_id != 0) && mem_to_reg_exe && (r1_addr_id == rd_addr_exe) || 
                        r2_used && (r2_addr_id != 0) && mem_to_reg_exe && (r2_addr_id == rd_addr_exe);
endmodule