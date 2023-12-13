// this file is generated automatically
module Imem (
	input [9:0] addr,
	output reg[31:0] instr
);
	always @(addr) begin
		case (addr)
			10'b0000000000 : instr = 32'h00000413;
			10'b0000000001 : instr = 32'h00000493;
			10'b0000000010 : instr = 32'h00000913;
			10'b0000000011 : instr = 32'h00000993;
			10'b0000000100 : instr = 32'h00046413;
			10'b0000000101 : instr = 32'h0014e493;
			10'b0000000110 : instr = 32'h00296913;
			10'b0000000111 : instr = 32'h0039e993;
			10'b0000001000 : instr = 32'h00842023;
			10'b0000001001 : instr = 32'h00942223;
			10'b0000001010 : instr = 32'h01242423;
			10'b0000001011 : instr = 32'h01342623;
			10'b0000001100 : instr = 32'h00a00893;
			10'b0000001101 : instr = 32'h00000493;
			10'b0000001110 : instr = 32'h00000913;
			10'b0000001111 : instr = 32'h00000993;
			10'b0000010000 : instr = 32'h00000073;
			default: instr = 0;
		endcase
	end
endmodule