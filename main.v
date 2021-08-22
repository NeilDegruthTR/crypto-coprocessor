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
wire [127:0] key = 0;

wire [127:0] ciphertext;
wire [127:0] ciphertext_o;
wire [2:0] aesReg_o;
wire csrUpdateAES;
wire ctrwriteAES;

wire [127:0] aesCSR;

//AES registers and block
AES aesBlock (plaintext, iv, key, aesCSR, clock, ciphertext, aesReg_o, ctrwrite, csrUpdateAES);

register plaintextReg (writeEnable[0], writeBus[127:0], plaintext);
register ivReg (writeEnable[1], writeBus[127:0], iv);
register ciphertextReg (ctrwriteAES, ciphertext, ciphertext_o);
csr aesCSR1 (writeBus[7:0], aesReg_o, writeEnable[3], csrUpdateAES, aesCSR);

//PRNG registers and block
wire [127:0] seed;
wire ctrwritePRNG;
wire csrUpdatePRNG;
wire [127:0] generated;
wire [127:0] generated_o;
wire [2:0] prngCSR_o;
wire [3:0] prngCSR;

register seedReg (writeEnable[8], writeBus[127:0], seed);
register generatedReg (ctrwritePRNG, generated, generated_o);
csr #(4) prngCSR0 (writeBus[3:0], prngCSR_o, writeEnable[10], csrUpdatePRNG, prngCSR);

PRNG prng1 (
	.seed (seed),
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

module register # (parameter k=128)

(
input we_i, input [k-1:0] writeData_i, 
output reg [k-1:0] dataRead_o
);

reg [k-1:0] data = 0;

always @(*) begin

if (we_i == 1)
	data = writeData_i;
	
dataRead_o = data;
end
endmodule


module csr #(parameter k=8) (
	input [k-1:0] writeBus,
	input [2:0] csrUpdate,
	input writeEnable, csrUpdateEnable,
	output reg [k-1:0] csr_o
);

reg [k-1:0] csr = 0;

always @(*) begin

if (writeEnable == 1) begin
	csr[k-1:2] = writeBus[k-1:2];
end

if (csrUpdateEnable == 1) begin
	csr[2:0] = csrUpdate;
end

csr_o = csr;

end

endmodule

module AES (
input [127:0] plaintext, iv, key,
input [7:0] aesReg,
input clock,
output reg [127:0] ciphertext = 0,
output reg [2:0] aesReg_o = 0,
output reg ctrwrite = 0,
output reg csrUpdate = 0
);

reg [3:0] state = 0;
reg [3:0] nextState = 0;
reg [7:0] counter = 0;
reg startFlag = 0;

always @(posedge clock)
begin

state = nextState;

if (aesReg[2] == 1) begin
	startFlag = 1;
end

if (startFlag == 1) begin

case (state)
8'd0: begin //Update csr
	ciphertext = 0;
	ctrwrite = 0;
	nextState = 1;
	aesReg_o = 2;
	csrUpdate = 1;
end

8'd1: begin //Load plaintext and iv to the module
	ciphertext = 0;
	aesReg_o = 2;
	csrUpdate = 0;
	ctrwrite = 0;
	
	counter = counter + 1;
	
	if (counter == 16) begin
		nextState = 2;
	end
	else begin
		nextState = 1;
	end
end

8'd2: begin //Operation end
	ciphertext = 91999;
	aesReg_o = 1;
	csrUpdate = 1;
	nextState = 0;
	counter = 0;
	startFlag = 0;
	ctrwrite = 1;
end

default: begin
	ciphertext = 0;
	ctrwrite = 0;
end
endcase

	
end
end

endmodule

module PRNG (
input [127:0] seed,
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
wire prngDone;
wire [127:0] generatedReg_inside;

lfsr PRNG (clock, prngEnable, loadSeed, seed, generatedReg_inside, prngDone);

always @(posedge clock)
begin

state = nextState;

if (csr[2] == 1) begin
	startFlag = 1;
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
	nextState = 0;
	startFlag = 0;
	ctrwrite = 1;
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
