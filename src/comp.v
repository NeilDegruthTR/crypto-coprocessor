`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.09.2021 09:39:33
// Design Name: 
// Module Name: comp
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


module comp (
	input [255:0] digest0, digest1,
	input [159:0] rReg, vReg,
	input csr,
	output reg equal
);

always @(*) begin
	if (csr == 0) begin
		if (rReg == vReg)
			equal <= 2'b01;
		else
			equal <= 2'b00;
	end
	else
		if (digest0 == digest1)
			equal <= 2'b01;
		else
			equal <= 2'b00;
	end
		
endmodule
