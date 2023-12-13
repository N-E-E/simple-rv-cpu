`timescale 1ns / 1ps

module CPUTest();
    reg clk, rst, go;
    reg [1:0] clk_sel;
    reg [2:0] display_sel;
    wire [7:0] seg_7_val, an;
    wire pause;
    
    initial begin
        clk <= 0;
        rst <= 0;
        clk_sel <= 0;
        display_sel <= 0;
        go <= 0;
    end
    
    always begin
        #1 clk = ~clk;
    end

    // simulation go
    always begin
        #100;
        if (pause)  begin
            #20 ;
            go <= 1;
            #4;
            go <= 0;
        end
    end

    RiscvCPU cpu(
        .clk            (clk),
        .rst            (rst),
        .go             (go),
        .clk_sel        (clk_sel), 
        .display_sel    (display_sel),
        .seg_7_val      (seg_7_val), 
        .an             (an),
        .pause          (pause)
    );
endmodule
    