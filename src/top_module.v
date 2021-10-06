`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2021 10:56:15
// Design Name: 
// Module Name: top_module
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


module top_module(
    input clock,
    input [31:0] instruct,
	input [31:0] keyInput,
    output [31:0] out
    );
	
	wire [5:0] writeEnableKey;
	wire [4:0] sliceSelector;
	wire [15:0] writeEnable;
	wire [447:0] writeBus;
	
	wire [127:0] privateKey;
	wire [159:0] q;
	wire [1023:0] p;
	wire [1023:0] g;
	wire [1023:0] y;
	
	wire [3:0] selectRead;
	wire [447:0] dataOut;
	
	controller ct0(.clock(clock), .instruct(instruct), .out(out), .sliceSelector(sliceSelector), .writeEnableKey(writeEnableKey), .dataOut(dataOut), .selectRead(selectRead), .writeEnable(writeEnable), .writeBus(writeBus) );
	keyStorage ks0(.clock(clock), .keyInput(keyInput), .writeEnable(writeEnableKey), .sliceSelector(sliceSelector), .privateKey(privateKey), .q(q), .p(p), .g(g), .y(y) );
	main datapath (.clock(clock), .writeEnable(writeEnable), .writeBus(writeBus), .selectRead(selectRead), .dataOut(dataOut), .privateKey(privateKey), .q(q), .p(p), .g(g), .y(y) );

	
endmodule
