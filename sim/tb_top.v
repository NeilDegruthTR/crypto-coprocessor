`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2021 11:22:29
// Design Name: 
// Module Name: tb_top
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


module tb_top();

reg clock = 0;
reg [31:0] instruct = 0;
reg [31:0] keyInput = 0;
wire [31:0] out;

top_module dut(
    .clock(clock),
    .instruct(instruct),
	.keyInput(keyInput),
    .out(out)
    );

always begin
    #5;
    clock = ~clock;
end

initial begin
    keyInput = 32'h00000000;
    instruct = 32'h40000004;
	#20;
	instruct = 32'h616263;
	#10;
	instruct = 0;
	#45;
	instruct = 32'h40000007;
	#20;
	instruct = 32'hC4;
	#10;
	instruct = 32'h00;
	#10;
	instruct = 32'h00;
end
endmodule
