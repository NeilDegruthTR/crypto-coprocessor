`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.08.2021 14:04:41
// Design Name: 
// Module Name: lfsr
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


module lfsr(
    input clock,
    input enable,
    input loadSeed,
    input [127:0] seed,
    output [127:0] lfsr_out,
    output lfsr_done
    );
	
	reg [127:0] lfsr_reg = 0;
	reg [4:0] xnor_out;
	reg counter = 0;
	
	always @(posedge clock) begin
		if (enable == 1) begin
			if(loadSeed == 1) begin
				lfsr_reg = seed;
			end
			else begin
				lfsr_reg = lfsr_reg<<5;
				lfsr_reg[4:0] = xnor_out;
				counter = counter + 1;
			end
		end
	end 
	
	
	always @(*) begin
		xnor_out[4] = lfsr_reg[127] ^~ lfsr_reg[125] ^~ lfsr_reg[100] ^~ lfsr_reg[98];
		xnor_out[3] = lfsr_reg[126] ^~ lfsr_reg[124] ^~ lfsr_reg[99] ^~ lfsr_reg[97];
		xnor_out[2] = lfsr_reg[125] ^~ lfsr_reg[123] ^~ lfsr_reg[98] ^~ lfsr_reg[96];
		xnor_out[1] = lfsr_reg[124] ^~ lfsr_reg[122] ^~ lfsr_reg[97] ^~ lfsr_reg[95];
		xnor_out[0] = lfsr_reg[123] ^~ lfsr_reg[121] ^~ lfsr_reg[96] ^~ lfsr_reg[94];
	end
	
	assign lfsr_out = lfsr_reg;
	assign lfsr_done = (counter==1) ? 1: 0;
endmodule
