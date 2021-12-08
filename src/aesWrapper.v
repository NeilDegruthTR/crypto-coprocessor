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
	input [127:0] prngGen,
	input clock, ptxWE,
	output reg [127:0] ciphertext,
	output reg [2:0] aesCSR_o = 0,
	output reg ctrwrite = 0,
	output reg csrUpdate = 0
);

wire [1:0] keyMode = 2'b00;

//wire [127:0] plaintext0 = 'h6bc1bee22e409f96e93d7e117393172a;
reg [127:0] CTRcounter = 'hf0f1f2f3f4f5f6f7f8f9fafbfcfdfeff;
//wire [127:0] key0 = 'h2b7e151628aed2a6abf7158809cf4f3c;
reg [127:0] ivMux;// = 'h000102030405060708090a0b0c0d0e0f;

reg reset = 0;
reg [3:0] state = 7;
reg [3:0] nextState = 7;
reg startFlag = 0;

reg start = 0; //key expansion start
reg enable = 0;
reg encDec = 0; //encryption = 0, decryption = 1
reg loadPlaintext = 0;
reg [3:0] counter = 0;
reg [4:0] modCounter = 0;

reg [127:0] plaintextTemp = 0;
reg [127:0] ciphertextTemp = 0;

reg [127:0] plaintextWire;
wire [127:0] ciphertextWire;
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
	.i_data(plaintextWire),
	.i_data_valid(loadPlaintext), //Load plaintext
	.o_ready(o_ready), //Ready for new operation
	.o_data (ciphertextWire),
	.o_data_valid (aesFinish), 
	.o_key_ready (keyExpansionDone)
);

always @(posedge clock)
begin

	state <= nextState;
	
	if (state == 0)
		counter <= counter + 1;

	if (state == 5) begin
	   if (aesCSR[5:3] == 2)
	       ciphertextTemp <= ciphertextWire ^ plaintext;
	   else
	       ciphertextTemp <= ciphertextWire;
	   plaintextTemp <= plaintext; 
	end
	
	if (state == 6) begin
		modCounter <= modCounter + 1;
		CTRcounter <= CTRcounter + 1;
	end
    
    if (aesCSR[2] == 1) begin
        startFlag <= 1;
        nextState <= 7;
    end
end	//always end

always @(*) begin
    if (aesCSR[6])
        ivMux <= iv;
    else
        ivMux <= prngGen;
end

always @(*) begin //plaintext, iv, key, aesCSR, clock, ptxWE, startFlag, state, modCounter

	if (startFlag == 1) begin

	case (state)
		8'd7: begin
			if (aesCSR[5:3] != 0) begin //Enc with mods
				if (modCounter == 0) begin
					nextState <= 0;
				end
				else begin
					if (ptxWE)
						nextState <= 0;
					else
						nextState <= 7;
				end
			end
			else
				nextState <= 0;
			ciphertext <= 0;
			
		end
		
		8'd0: begin //Update csr and reset
			reset <= 1;
			ctrwrite <= 0;
			aesCSR_o <= 2;
			csrUpdate <= 1;
			enable <= 1;
			start <= 0;
			ciphertext <= 0;
			
			if ((counter > 6)) begin
				nextState <= 1;
			end
			else
				nextState <= 0;
				
		end

		8'd1: begin //Wait for key expansion
			reset <= 0;
			start <= 1;
			ciphertext <= 0;
			
			case (aesCSR[5:3])
				0: begin //No modes
					encDec <= aesCSR[7];
					if (aesCSR[7]) begin //Decryption
						plaintextWire <= plaintext;
					end
					else begin //Encryption
						plaintextWire <= plaintext;
					end
				end
				
				1: begin //CBC
					encDec <= aesCSR[7];
					if (aesCSR[7]) begin //Decryption
						plaintextWire <= plaintext;
					end
					else begin //Encryption
						if (!modCounter) begin
							plaintextWire <= plaintext ^ ivMux;
						end
						else begin
							plaintextWire <= plaintext ^ ciphertextTemp;
						end
					end
				end
				
				2: begin //CFB
					encDec <= 0;
					if (aesCSR[7]) begin //Decryption
						if (!modCounter) begin
							plaintextWire <= ivMux;
						end
						else begin
							plaintextWire <= ciphertextTemp;
						end
					end
					else begin //Encryption
						if (!modCounter) begin
							plaintextWire <= ivMux;
						end
						else begin
							plaintextWire <= plaintextTemp;
						end
					end
				end
				
				3: begin //OFB
					encDec <= 0;
					if (aesCSR[7]) begin //Decryption
						if (!modCounter) begin
							plaintextWire <= ivMux;
						end
						else begin
							plaintextWire <= ciphertextTemp;
						end
					end
					else begin //Encryption
						if (!modCounter) begin
							plaintextWire <= ivMux;
						end
						else begin
							plaintextWire <= ciphertextTemp;
						end
					end
				end
				
				4: begin //CTR
					encDec <= 0;
					if (aesCSR[7]) begin //Decryption
						plaintextWire <= CTRcounter;
					end
					else begin //Encryption
						plaintextWire <= CTRcounter;
					end
				end
				
				endcase
			
			aesCSR_o <= 2;
			csrUpdate <= 0;
			ctrwrite <= 0;
			nextState <= 2;
			end

		8'd2: begin
			start <= 0;
			csrUpdate <= 0;
			aesCSR_o <= 2;
			ctrwrite <= 0;
			ciphertext <= 0;
			
			if (keyExpansionDone == 1) begin
				nextState <= 3;
			end
			else begin
				nextState <= 2;
			end

		end

		8'd3: begin //Load plaintext
			loadPlaintext <= 1;
			csrUpdate <= 0;
			aesCSR_o <= 2;
			ciphertext <= 0;
			ctrwrite <= 0;
			nextState <= 4;
		end

		8'd4: begin
			loadPlaintext <= 0;
			ciphertext <= 0;
			if (aesFinish == 1) begin
				nextState <= 5;
			end
			else
				nextState <= 4;
		end

		8'd5: begin
			ctrwrite <= 1;
			
			case (aesCSR[5:3])
			
				0: begin //No modes
					if (aesCSR[7]) begin //Decryption
						ciphertext <= ciphertextWire;
					end
					else begin //Encryption
						ciphertext <= ciphertextWire;
					end
				end
				
				1: begin //CBC
					if (aesCSR[7]) begin //Decryption
						if (!modCounter) begin
							ciphertext <= ciphertextWire ^ ivMux;
						end
						else begin
							ciphertext <= ciphertextWire ^ plaintextTemp;
						end
					end
					else begin //Encryption
						ciphertext <= ciphertextWire;
						//ciphertextTemp <= ciphertextWire;
					end
				end
				
				2: begin //CFB
					if (aesCSR[7]) begin //Decryption
						ciphertext <= ciphertextWire ^ plaintext;
					end
					else begin //Encryption
						ciphertext <= ciphertextWire ^ plaintext;
					end
				end
				
				3: begin //OFB
					if (aesCSR[7]) begin //Decryption
						ciphertext <= ciphertextWire ^ plaintext;
					end
					else begin //Encryption
						ciphertext <= ciphertextWire ^ plaintext;
					end
				end
				
				4: begin //CTR
					if (aesCSR[7]) begin //Decryption
						ciphertext <= ciphertextWire ^ plaintext;
					end
					else begin //Encryption
						ciphertext <= ciphertextWire ^ plaintext;
					end
				end
				
				default: begin
				    ciphertext <= 0;
				end
			
			endcase
			aesCSR_o <= 1;
			csrUpdate <= 1;
			nextState <= 6;
		end

		8'd6: begin
			if (aesCSR[5:3])
				startFlag <= 1;
			else
				startFlag <= 0;
			
			ctrwrite <= 0;
			aesCSR_o <= 0;
			ciphertext <= 0;
			csrUpdate <= 0;
			nextState <= 7;
			
		end

		default: begin
			ctrwrite <= 0;
			ciphertext <= 0;
			csrUpdate <= 0;
			nextState <= 7;
		end
		endcase
end

end
endmodule
