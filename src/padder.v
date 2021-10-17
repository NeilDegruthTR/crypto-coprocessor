`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2021 14:12:48
// Design Name: 
// Module Name: padder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module padder(
    input [66:0] sha2CSR,
    input [447:0] plaintext
    );
	
	integer shiftAmount = 0;
	reg [511:0] shaPlaintext = 0;
	
	always @(*) begin
		shiftAmount = 447 - sha2CSR[65:2] + 64;
	
		shaPlaintext = {plaintext[447:0], 1'b1} << shiftAmount;
	
		shaPlaintext[63:0] = sha2CSR[65:2];
		
		//shaPlaintext = sha2CSR ** -1;
	end
endmodule
