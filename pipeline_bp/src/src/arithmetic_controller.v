module ArithController (
    input [6:0] funct7,
    input [2:0] funct3,
    input [4:0] op_code,
    output reg [3:0] op
);
    always @(funct7, funct3, op_code) begin
        if(funct7 == 7'b0000000 && funct3 == 3'b000 && op_code == 5'b01100)   op <= 4'b0101;  //add
        else if(funct7==7'b0100000 && funct3==3'b000 && op_code==5'b01100)   op <= 4'b0110;  //sub
        else if(funct7==7'b0000000 && funct3==3'b111 && op_code==5'b01100)   op <= 4'b0111;  //and
        else if(funct7==7'b0000000 && funct3==3'b110 && op_code==5'b01100)   op <= 4'b1000;  //or
        else if(funct7==7'b0000000 && funct3==3'b010 && op_code==5'b01100)   op <= 4'b1011;  //slt
        else if(funct7==7'b0000000 && funct3==3'b011 && op_code==5'b01100)   op <= 4'b1100;  //sltu
        else if(funct3==3'b000 && op_code==5'b00100)   op <= 4'b0101;  //addi
        else if(funct3==3'b111 && op_code==5'b00100)   op <= 4'b0111;  //andi
        else if(funct3==3'b110 && op_code==5'b00100)   op <= 4'b1000;  //ori
        else if(funct3==3'b100 && op_code==5'b00100)   op <= 4'b1001;  //xori
        else if(funct3==3'b010 && op_code==5'b00100)   op <= 4'b1011;  //slti
        else if(funct7==7'b0000000 && funct3==3'b001 && op_code==5'b00100)   op <= 4'b0000;  //slli
        else if(funct7==7'b0000000 && funct3==3'b101 && op_code==5'b00100)   op <= 4'b0010;  //srli
        else if(funct7==7'b0100000 && funct3==3'b101 && op_code==5'b00100)   op <= 4'b0001;  //srai
        else if(funct3==3'b010 && op_code==5'b00000)   op <= 4'b0101;  //lw
        else if(funct3==3'b010 && op_code==5'b01000)   op <= 4'b0101;  //sw
        else if (op_code==5'b11001)   op <= 4'b0101;  //jalr
        // int
        else if (funct3 == 'd6 && op_code == 'h1c) op <= 'd8;  //csrrsi
        else if (funct3 == 'd7 && op_code == 'h1c) op <= 'd7;  //csrrci
        // ccab
        else if (funct7 == 'd0 && funct3 == 'd5 && op_code == 'hc) op <= 'd2;  //srl
        else if (funct7 == 'd0 && funct3 == 'd4 && op_code == 'hc) op <= 'd9;  //xor
        else if (funct3 == 'd5 && op_code == 'h0) op <= 'd5;  //lhu
        else if (funct3 == 'd5 && op_code == 'h18) op <= 'd11;  // bge

        else op <= 4'b0101;
    end
    
    
endmodule