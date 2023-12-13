//将LedData转成数码管信号，SEG为数码管显示，AN为数码管片选信号
module DigitDisplay(
    input [31:0] LedData,
    input CLK,
    output [7:0] SEG,
    output [7:0] AN
);

    wire CLK_N; //高频时钟信号
    wire [3:0] Led; //数码管显示数据
    wire [2:0] count; //计数器计数
   
    //实例化模块
    Divider #(5000) div(
        .clk(CLK),
        .clk_N(CLK_N)
    );
    
    DisplayCounter display_counter(
        .clk(CLK_N),
        .out(count)
    );//高频计数器

    Decoder_3_8 decoder(
        .num(count),
        .sel(AN)
    );//获得数码管片选信号

    DisplaySel sel(
        .num(count), 
        .dig(LedData), 
        .code(Led)
    );

    Seg7LED seg_7_led(
        .code(Led),
        .patt(SEG)
    );
endmodule