module JalDestCalculator (
    input [31:0] imm_J_32,
    input [31:0] cur_pc,
    output [31:0] next_pc
);
    wire [31:0] imm_J_32_shift;

    ShifterLeft #(.WIDTH(32)) shifter(
        .in     (imm_J_32),
        .shift  ('b0_0001),
        .out    (imm_J_32_shift)
    );

    Adder #(.WIDTH(32)) adder(
        .a(imm_J_32_shift),
        .b(cur_pc),
        .out(next_pc)
    );
    
endmodule