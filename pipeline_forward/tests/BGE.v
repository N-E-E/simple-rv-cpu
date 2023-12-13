// this file is generated automatically
module Imem (
	input [9:0] addr,
	output reg[31:0] instr
);
	always @(addr) begin
		case (addr)
			10'b0000000000 : instr = 32'h00f00493;
			10'b0000000001 : instr = 32'h00900533;
			10'b0000000010 : instr = 32'h02200893;
			10'b0000000011 : instr = 32'h00000073;
			10'b0000000100 : instr = 32'hfff48493;
			10'b0000000101 : instr = 32'hfe04d8e3;
			10'b0000000110 : instr = 32'h00a00893;
			10'b0000000111 : instr = 32'h00000073
;
			default: instr = 0;
		endcase
	end
endmodule