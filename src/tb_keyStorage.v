`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2021 17:02:45
// Design Name: 
// Module Name: tb_keyStorage
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


module tb_keyStorage();
	
	reg clock = 0;
	reg [31:0] keyInput = 0;
	reg [5:0] writeEnable = 0;
	reg [4:0] sliceSelector = 0;
	wire [127:0] privateKey;
    wire [159:0] q;
    wire [1023:0] p;
    wire [1023:0] g;
    wire [1023:0] y;
	
	keyStorage dut(
	.clock(clock),
    .keyInput(keyInput),
    .writeEnable(writeEnable),
	.sliceSelector(sliceSelector),
    .privateKey(privateKey),
    .q(q),
    .p(p),
    .g(g),
    .y(y)
    );
	
	always begin
		#5;
		clock <= ~clock;
	end
	
	initial begin
		#5;
		writeEnable[0] <= 1;
		sliceSelector <= 0;
		keyInput <= 32'hC5F4B81A;
		#10;
		sliceSelector <= 1;
		#10;
		sliceSelector <= 2;
		#10;
		sliceSelector <= 3;
	end
endmodule
