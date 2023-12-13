// this file is generated automatically
module Imem (
	input [9:0] addr,
	output reg[31:0] instr
);
	always @(addr) begin
		case (addr)
			10'b0000000000 : instr = 32'h00100293;
			10'b0000000001 : instr = 32'h00300313;
			10'b0000000010 : instr = 32'h00800493;
			10'b0000000011 : instr = 32'h00849493;
			10'b0000000100 : instr = 32'h07648493;
			10'b0000000101 : instr = 32'h01449493;
			10'b0000000110 : instr = 32'h00900533;
			10'b0000000111 : instr = 32'h02200893;
			10'b0000001000 : instr = 32'h00000073;
			10'b0000001001 : instr = 32'h00800e13;
			10'b0000001010 : instr = 32'h0054d4b3;
			10'b0000001011 : instr = 32'h0064d4b3;
			10'b0000001100 : instr = 32'h00900533;
			10'b0000001101 : instr = 32'h02200893;
			10'b0000001110 : instr = 32'h00000073;
			10'b0000001111 : instr = 32'hfffe0e13;
			10'b0000010000 : instr = 32'hfe0e14e3;
			10'b0000010001 : instr = 32'h00a00893;
			10'b0000010010 : instr = 32'h00000073
;
			default: instr = 0;
		endcase
	end
endmodule