`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2021 17:21:43
// Design Name: 
// Module Name: main
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


module main(
    input clock,
	input [15:0] writeEnable,
	input [255:0] writeBus,
	input [3:0] selectRead,
	output reg [255:0] dataOut
    );

wire [127:0] plaintext, iv;
wire [127:0] key = 128'h2b7e151628aed2a6abf7158809cf4f3c;

wire [127:0] ciphertext;
wire [127:0] ciphertext_o;
wire [2:0] aesReg_o;
wire csrUpdateAES;
wire ctrwriteAES;

wire [7:0] aesCSR;

//AES registers and block
AESwrapper aesBlock (plaintext, iv, key, aesCSR, clock, ciphertext, aesReg_o, ctrwrite, csrUpdateAES);

register plaintextReg (clock, writeEnable[0], writeBus[127:0], plaintext);
register ivReg (clock, writeEnable[1], writeBus[127:0], iv);
register ciphertextReg (clock, ctrwriteAES, ciphertext, ciphertext_o);
csr aesCSR1 (clock, writeBus[7:0], aesReg_o, writeEnable[3], csrUpdateAES, aesCSR);

//PRNG registers and block
wire [127:0] seed;
wire ctrwritePRNG;
wire csrUpdatePRNG;
wire [127:0] generated;
wire [127:0] generated_o;
wire [2:0] prngCSR_o;
wire [3:0] prngCSR;

register seedReg (clock, writeEnable[8], writeBus[127:0], seed);
register generatedReg (clock, ctrwritePRNG, generated, generated_o);
csr #(4) prngCSR0 (clock, writeBus[3:0], prngCSR_o, writeEnable[10], csrUpdatePRNG, prngCSR);

PRNG prng1 (
	.seed (seed),
	.generatedSeed_i (generated_o),
	.csr(prngCSR),
	.clock(clock),
	.generatedReg(generated),
	.csr_o(prngCSR_o),
	.ctrwrite(ctrwritePRNG),
	.csrUpdate (csrUpdatePRNG)
);

always @(*) begin

	case (selectRead)
      4'b0000: begin
				  dataOut[255:128] = 0;
                  dataOut[127:0] = plaintext;
               end
      4'b0001: begin
                  dataOut[255:128] = 0;
                  dataOut[127:0] = iv;
               end
      4'b0010: begin
                  dataOut[255:128] = 0;
                  dataOut[127:0] = ciphertext_o;
               end
      4'b0011: begin
                  dataOut[255:128] = 0;
                  dataOut[127:0] = aesCSR;
               end
	  4'b0100: begin
				  dataOut[255:128] = 0;
                  dataOut[127:0] = seed;
               end
      4'b0101: begin
                  dataOut[255:128] = 0;
                  dataOut[127:0] = generated_o;
               end
      4'b0110: begin
                  dataOut[255:128] = 0;
                  dataOut[127:0] = prngCSR;
               end
      default: begin
                  dataOut = 0;
               end

	endcase

end

endmodule

//Register
module register # (parameter k=128)

( input clock,
input we_i, input [k-1:0] writeData_i, 
output reg [k-1:0] dataRead_o
);

reg [k-1:0] data = 0;

always @(posedge clock) begin

if (we_i == 1)
	data = writeData_i;
	
dataRead_o = data;
end
endmodule

//CSR
module csr #(parameter k=8) (
	input clock,
	input [k-1:0] writeBus,
	input [2:0] csrUpdate,
	input writeEnable, csrUpdateEnable,
	output reg [k-1:0] csr_o
);

reg [k-1:0] csr = 0;

always @(posedge clock) begin

if (writeEnable == 1) begin
	csr[k-1:2] = writeBus[k-1:2];
end

if (csrUpdateEnable == 1) begin
	csr[2:0] = csrUpdate;
end

csr_o = csr;

end

endmodule

//AES module
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


module PRNG (
input [127:0] seed,
input [127:0] generatedSeed_i,
input [3:0] csr,
input clock,
output reg [127:0] generatedReg = 0,
output reg [2:0] csr_o = 0,
output reg ctrwrite = 0,
output reg csrUpdate = 0
);

reg [3:0] state = 0;
reg [3:0] nextState = 0;
reg startFlag = 0;
reg prngEnable = 0;
reg loadSeed = 0;
reg [6:0] counter = 0;
wire prngDone;
wire [127:0] generatedReg_inside;
reg [127:0] selectedSeed;

lfsr PRNG (clock, prngEnable, loadSeed, selectedSeed, generatedReg_inside, prngDone);

always @(posedge clock)
begin

state = nextState;

if (csr[2] == 1) begin
	startFlag = 1;
	counter = 0;
end

if (startFlag == 1) begin

case (state)
8'd0: begin //Update csr and load seed
	generatedReg = 0;
	ctrwrite = 0;
	csr_o = 2;
	csrUpdate = 1;
	prngEnable = 1;
	loadSeed = csr[3];
	if (counter == 0)
		selectedSeed = seed;
	else
		selectedSeed = generatedSeed_i;
		
	nextState = 1;
end

8'd1: begin //Start module
	generatedReg = 0;
	csr_o = 2;
	csrUpdate = 0;
	ctrwrite = 0;
	prngEnable = 1;
	loadSeed = 0;
	
	if (prngDone == 0) begin
		nextState = 1;
	end
	else begin
		prngEnable = 0;
		nextState = 2;
	end
	
end

8'd2: begin //Operation end
	generatedReg = generatedReg_inside;
	csr_o = 1;
	csrUpdate = 1;
	ctrwrite = 1;
	
	if (counter > 10) begin
		startFlag = 0;
		counter = 0;
		nextState = 0;
	end
	else
		nextState = 1;
	
	counter = counter + 1;
end

default: begin
	generatedReg = 0;
	ctrwrite = 0;
end
endcase

	
end
end

endmodule







//reg [255:0] hashReg = 'h90008400000DBCAF90008400000DBCAF90224480900D3CAF90224480900D3CAF;
//reg [159:0] vReg = 'h678d0f19eb98f814c3e71d890f3e2a9075fb5f7b;
