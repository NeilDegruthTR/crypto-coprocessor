`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.09.2021 20:10:27
// Design Name: 
// Module Name: keyStorage
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


module keyStorage(
	input clock,
    input [31:0] keyInput,
    input [5:0] writeEnable,
	input [4:0] sliceSelector,
    output [127:0] privateKey,
    output [159:0] q,
    output [1023:0] p,
    output [1023:0] g,
    output [1023:0] y
    );
	
	reg [1024:0] writeBus;
	
	wire [127:0] privateKey0_o;
	wire [127:0] privateKey1_o;
	
	register #(128) privateKey0(.clock(clock), .we_i(writeEnable[0]), .writeData_i(writeBus[127:0]), .dataRead_o(privateKey0_o) );
	register #(128) privateKey1(.clock(clock), .we_i(writeEnable[1]), .writeData_i(writeBus[127:0]), .dataRead_o(privateKey1_o) );
	register #(160) regQ(.clock(clock), .we_i(writeEnable[2]), .writeData_i(writeBus[159:0]), .dataRead_o(q) );
	register #(1024) regP(.clock(clock), .we_i(writeEnable[3]), .writeData_i(writeBus), .dataRead_o(p) );
	register #(1024) regG(.clock(clock), .we_i(writeEnable[4]), .writeData_i(writeBus), .dataRead_o(g) );
	register #(1024) regY(.clock(clock), .we_i(writeEnable[5]), .writeData_i(writeBus), .dataRead_o(y) );
	
	assign privateKey = privateKey0_o ^ privateKey1_o;
	
	always @(posedge clock) begin
		if (writeEnable != 0)
			writeBus[32*sliceSelector + 31 -:32] <= keyInput;
	end
endmodule
