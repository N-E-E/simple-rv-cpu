module DMem (  // TODO: change the mem arch to byte addressable
    input [9:0] addr,
    input [31:0] mem_in,
    input store, load, clr, clk,
    output [31:0] dout
);
    reg [31:0] mem[2**11 - 1 : 0];
    
    always @(posedge clk) begin
        // if (clr) mem =  TODO: how to set 0?
        if (store) mem[addr] <= mem_in;
    end
    assign dout = (load) ? mem[addr] : 0;

    // always @(*) begin  // note: read memory don't need clk signal
    //     if (clr) begin
    //         for (i = 0; i < 2**11; i = i + 1) begin
    //             mem[i] = 32'b0;
    //         end
    //     end
    //     if (load) dout <= mem[addr];
    // end
endmodule