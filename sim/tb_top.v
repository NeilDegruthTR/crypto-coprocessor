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
	instruct = 32'h40000003;
	#10;
	instruct = 32'h94;
	#10;
	instruct = 32'h40000000;
	#20;
	instruct = 32'h7393172a; //6bc1bee2_2e409f96_e93d7e11_7393172a
	#10;
	instruct = 32'he93d7e11;
	#10;
	instruct = 32'h2e409f96;
	#10;
	instruct = 32'h6bc1bee2;
	#10;
	instruct = 32'h0; 
	#900;
	instruct = 32'h40000000;
    #20;
    instruct = 32'h45af8e51; //ae2d8a5_71e03ac9_c9eb76fac_45af8e51
    #10;
    instruct = 32'h9eb76fac;
    #10;
    instruct = 32'h1e03ac9c;
    #10;
    instruct = 32'hae2d8a57;
    #10;
    instruct = 32'h0;
    #900;
    instruct = 32'h40000000;
    #20;
    instruct = 32'h1a0a52ef; //30c81c46_a35ce411_e5fbc119_1a0a52ef
    #10;
    instruct = 32'he5fbc119;
    #10;
    instruct = 32'ha35ce411;
    #10;
    instruct = 32'h30c81c46;
    #10;
    instruct = 32'h0;
    #900;
    instruct = 32'h40000000;
    #20;
    instruct = 32'he66c3710; //f69f2445_df4f9b17_ad2b417b_e66c3710
    #10;
    instruct = 32'had2b417b;
    #10;
    instruct = 32'hdf4f9b17;
    #10;
    instruct = 32'hf69f2445;
    #10;
    instruct = 32'h0;
end
endmodule
