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
	input [16:0] writeEnable,
	input [447:0] writeBus,
	input [3:0] selectRead,
	input [127:0] privateKey,
    input [159:0] q,
    input [1023:0] p,
    input [1023:0] g,
    input [1023:0] y,
	output reg [447:0] dataOut
    );

//AES registers and block
wire [127:0] plaintext, iv;
wire [127:0] ciphertext;
wire [127:0] ciphertext_o;
wire [2:0] aesReg_o;
wire csrUpdateAES;
wire ctrwriteAES;
wire [7:0] aesCSR;
wire [127:0] generated_o;

AESwrapper aesBlock (plaintext, iv, privateKey, aesCSR, generated_o, clock, writeEnable[0], ciphertext, aesReg_o, ctrwriteAES, csrUpdateAES);

register plaintextReg (clock, writeEnable[0], writeBus[127:0], plaintext);
register ivReg (clock, writeEnable[1], writeBus[127:0], iv);
register ciphertextReg (clock, ctrwriteAES, ciphertext, ciphertext_o);
csr #(8) aesCSR1 (clock, writeBus[7:0], aesReg_o, writeEnable[3], csrUpdateAES, aesCSR);

//SHA2 registers and block
wire [447:0] shaPlaintext;
wire [63:0] shaMessageSize;
wire [255:0] digest0writeBus;
wire digest0writeEnable;
wire [255:0] digest0out;
wire [255:0] digest1out;
wire [2:0] shaCSRupdateBus;
wire shaCSRupdateEnable;
wire [2:0] sha2CSR;

SHA2wrapper sha2block(
	.plaintext(shaPlaintext),
	.sha2CSR(sha2CSR),
	.messageSize(shaMessageSize),
	.clock(clock),
	.digest(digest0writeBus),
	.sha2CSR_o(shaCSRupdateBus),
	.regwrite(digest0writeEnable),
	.csrUpdate(shaCSRupdateEnable)
);

register #(448) shaPlaintextReg (clock, writeEnable[4], writeBus, shaPlaintext);
register #(64) shaMessageSizeReg (clock, writeEnable[16], writeBus[63:0], shaMessageSize);
register #(256) digest0 (clock, digest0writeEnable, digest0writeBus, digest0out); //Read-only
register #(256) digest1 (clock, writeEnable[6], writeBus[255:0], digest1out); // Read/Write
csr #(3) sha2CSR0 (.clock(clock), .writeBus(writeBus[2:0]), .csrUpdate(shaCSRupdateBus), .writeEnable(writeEnable[7]), .csrUpdateEnable(shaCSRupdateEnable), .csr_o(sha2CSR));

//PRNG registers and block
wire [127:0] seed;
wire [127:0] generated;
wire ctrwritePRNG;
wire csrUpdateEnablePRNG;
wire [2:0] prngCSR_o;
wire [3:0] prngCSR;

register seedReg (clock, writeEnable[8], writeBus[127:0], seed);
register generatedReg (clock, ctrwritePRNG, generated, generated_o);
csr #(4) prngCSR0 (.clock(clock), .writeBus(writeBus[3:0]), .writeEnable(writeEnable[10]), .csrUpdate(prngCSR_o), .csrUpdateEnable(csrUpdateEnablePRNG), .csr_o(prngCSR));

PRNG prng1 (
	.seed (seed),
	.generatedSeed_i (generated_o),
	.csr(prngCSR),
	.clock(clock),
	.generatedReg(generated),
	.csr_o(prngCSR_o),
	.ctrwrite(ctrwritePRNG),
	.csrUpdate (csrUpdateEnablePRNG)
);

//Comparator registers and block
wire comp_csr;
wire csr0;

wire [255:0] regRout;
wire [255:0] regSout;
wire [255:0] regVin;
wire [255:0] regVout;

comp comp1 (digest0out, digest1out, regRout, regVout, csr0, comp_csr);

//DSA registers and block
wire regwriteDSA;
wire csrUpdateEnableDSA;
wire [2:0] dsaCSR_o;
wire [3:0] dsaCSR;

register #(256) regR(clock, writeEnable[12], writeBus[255:0], regRout);
register #(256) regS(clock, writeEnable[13], writeBus[255:0], regSout);
register #(256) regV(clock, regwriteDSA, regVin, regVout);
csr #(3) dsaCSR0 (.clock(clock), .writeBus(writeBus[2:0]), .writeEnable(writeEnable[15]), .csrUpdate(dsaCSR_o), .csrUpdateEnable(csrUpdateEnableDSA), .csr_o(dsaCSR));
dsa_block dsa(.r(regRout),.s(regSout),.z(digest0out),.dsaCSR(dsaCSR), .clock(clock), .v(regVin), .regWrite(regwriteDSA), .csrUpdate(csrUpdateEnableDSA), .dsaCSR_o(dsaCSR_o));

always @(*) begin

	case (selectRead)
      4'b0000: begin
				  //dataOut[255:128] = 0;
                  dataOut[127:0] = plaintext;
               end
      4'b0001: begin
                  //dataOut[255:128] = 0;
                  dataOut[127:0] = iv;
               end
      4'b0010: begin
                  //dataOut[255:128] = 0;
                  dataOut[127:0] = ciphertext_o;
               end
      4'b0011: begin
                  //dataOut[255:128] = 0;
                  dataOut[127:0] = aesCSR;
               end
      4'b0101: begin
                  //dataOut[255:128] = 0;
                  dataOut[127:0] = generated_o;
               end
      4'b0110: begin
                  //dataOut[255:128] = 0;
                  dataOut[127:0] = prngCSR;
               end
      default: begin
                  dataOut = 0;
               end

	endcase

end

endmodule

//CSR
module csr #(parameter k=8) (
	input clock,
	input [k-1:0] writeBus,
	input [2:0] csrUpdate,
	input writeEnable, csrUpdateEnable,
	output [k-1:0] csr_o
);

reg [k-1:0] csr = 0;

assign csr_o = csr;

always @(posedge clock) begin

if (writeEnable == 1) begin
	csr[k-1:2] = writeBus[k-1:2];
end

if (csrUpdateEnable == 1) begin
	csr[2:0] = csrUpdate;
end

end

endmodule

//reg [159:0] vReg = 'h678d0f19eb98f814c3e71d890f3e2a9075fb5f7b;
