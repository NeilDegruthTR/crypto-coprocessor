`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.09.2021 09:37:03
// Design Name: 
// Module Name: aesWrapper
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

module AESwrapper (
	input [127:0] plaintext, iv, key,
	input [7:0] aesCSR,
	input clock,
	output [127:0] ciphertext,
	output reg [2:0] aesCSR_o = 0,
	output reg ctrwrite = 0,
	output reg csrUpdate = 0
);

wire [1:0] keyMode = 2'b00;

reg reset = 0;
reg [3:0] state = 0;
reg [3:0] nextState = 0;
reg startFlag = 0;

reg start = 0; //key expansion start
reg enable = 0;
reg encDec = 0; //encryption = 0, decryption = 1
reg loadPlaintext = 0;
reg [3:0] counter = 0;
wire [255:0] aesKey;
wire aesFinish;
wire o_ready;
wire keyExpansionDone;

assign aesKey = {key,{128{1'b0}}};

aes aes0 (
	.clk(clock),
	.reset(reset),
	.i_start(start), //Key expansion start
	.i_enable(enable), //Module enable
	.i_ende (encDec), //Encryption or decryption
	.i_key (aesKey),
	.i_key_mode (keyMode), //0 = 128 bit
	.i_data(plaintext),
	.i_data_valid(loadPlaintext), //Load plaintext
	.o_ready(o_ready), //Ready for new operation
	.o_data (ciphertext),
	.o_data_valid (aesFinish), 
	.o_key_ready (keyExpansionDone)
);

always @(posedge clock)
begin

state = nextState;

if (aesCSR[2] == 1) begin
	startFlag = 1;
	state = 0;
end

if (startFlag == 1) begin

case (state)
8'd0: begin //Update csr and reset
	reset <= 1;
	ctrwrite <= 0;
	aesCSR_o <= 2;
	csrUpdate <= 1;
	enable <= 1;
	encDec <= aesCSR[6];
	start <= 0;
	
	if (counter > 6)
		nextState = 1;
	else
		nextState = 0;
	
	counter = counter + 1;
end

8'd1: begin //Wait for key expansion
	reset = 0;
	start = 1;
	aesCSR_o = 2;
	csrUpdate = 0;
	ctrwrite = 0;
	nextState = 2;
	
end

8'd2: begin //Load plaintext
	start = 0;
	csrUpdate = 0;
	aesCSR_o = 2;
	ctrwrite = 0;
	
	if (keyExpansionDone == 1) begin
		nextState = 3;
	end
	else begin
		nextState = 2;
	end

end

8'd3: begin
	loadPlaintext = 1;
	csrUpdate = 0;
	aesCSR_o = 2;
	ctrwrite = 0;
	nextState = 4;
end

8'd4: begin
	loadPlaintext = 0;
	if (aesFinish == 1) begin
		nextState = 5;
		ctrwrite = 1;
	end
	else
		nextState = 4;
end

8'd5: begin
	ctrwrite = 0;
	aesCSR_o = 1;
	csrUpdate = 1;
	nextState = 0;
	startFlag = 0;
	enable = 0;
end

default: begin
	ctrwrite = 0;
	csrUpdate = 0;
	nextState = 0;
end
endcase

	
end
end

endmodule
