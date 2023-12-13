module ForwardSelector (
    input [1:0] forward,
    input [31:0] r_exe, alu_res_mem, rd_in_wb,
    output [31:0] src   
);
    assign src = (forward == 'd2) ? alu_res_mem :
                    (forward == 'd1) ? rd_in_wb : r_exe;
endmodule