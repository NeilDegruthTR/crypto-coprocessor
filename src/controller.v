`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2021 23:45:58
// Design Name: 
// Module Name: controller
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


module controller(
	input clock,
    input [31:0] instruct,
	input [447:0] dataOut,
    output reg [31:0] out = 0,
	output reg [4:0] sliceSelector,
	output reg [5:0] writeEnableKey,
	output reg [3:0] selectRead,
	output reg [16:0] writeEnable = 0,
	output reg [447:0] writeBus = 0
    );
	
	reg [2:0] state = 0;
	reg [2:0] nextState = 0;
	
	reg [4:0] roundNumber;
	reg [4:0] counter;
	reg [4:0] counterNext;

always @(posedge clock) begin

	case (state)
		0: begin
			selectRead <= instruct[3:0];
			out <= 0;
			writeBus <= 0;
			if (instruct[31:30] == 2'b00) begin
				case (instruct[4:0])
				0,1,2,8,9: begin
					roundNumber <= 4;
				end
				5,6: begin
					roundNumber <= 8;
				end
				12,13,14: begin
					roundNumber <= 5;
				end
				4: begin
					roundNumber <= 14;
				end
				7: begin
					roundNumber <= 3;
				end
				16: begin
				    roundNumber <= 2;
				end
				default: begin
					roundNumber <= 1;
				end
				endcase
			end
			else if (instruct[31:30] == 2'b01) begin
				case (instruct[4:0])
				0,1,2,8,9: begin
					roundNumber <= 4;
				end
				5,6: begin
					roundNumber <= 8;
				end
				12,13,14: begin
					roundNumber <= 5;
				end
				4: begin
					roundNumber <= 14;
				end
				7: begin
					roundNumber <= 3;
				end
				3: begin
					roundNumber <= 1;
				end
				16: begin
                    roundNumber <= 2;
                end
				default: begin
					roundNumber <= 1;
				end
			endcase
			end
			else if (instruct[31:30] == 2'b10) begin
				case (instruct[3:0])
				0,1: begin
					roundNumber <= 4;
				end
				2: begin
					roundNumber <= 10;
				end
				3,4,5: begin
					roundNumber <= 64;
				end
				default: begin
					roundNumber <= 1;
				end
				endcase
				end
			else begin
				roundNumber <= 0;
			end
		end
		
		1: begin
			out <= dataOut[32*counter+31 -:32];
			writeBus <= 0;
		end
		
		2: begin
			writeBus[32*counter+31 -:32] <= instruct;
			out <= 0;
		end
		
		3: begin
			writeBus <= 0;
			out <= 0;
		end
		
		4: begin
			writeBus <= 0;
			out <= 0;
		end
	endcase
	
	counter <= counterNext;
	state <= nextState;
end
	
always @(*) begin
	case (state)

		0: begin
			sliceSelector = 0;
			writeEnableKey = 0;
			writeEnable = 0;
			counterNext = 0;
			
			if (instruct[31:30] == 2'b00)
				nextState = 1;
			else if (instruct[31:30] == 2'b01)
				nextState = 2;
			else if (instruct[31:30] == 2'b10)
				nextState = 4;
			else begin
				nextState = 0;
			end
		
		end

		1: begin //Read case
			writeEnable = 0;
			sliceSelector = 0;
			writeEnableKey = 0;
			
			if (counter < (roundNumber - 1)) begin
				nextState = 1;
				counterNext = counter + 1;
			end
			else begin
				counterNext = counterNext;
				nextState = 0;
			end
			

		end //end case 1


		2: begin //Write case
			writeEnable = 0;
			sliceSelector = 0;
			writeEnableKey = 0;
			if (counter < (roundNumber - 1)) begin
				nextState = 2;
				counterNext = counter + 1;
			end
			else begin
				counterNext = counterNext;
				nextState = 3;
			end
			
			
		end

		3: begin
			writeEnable[selectRead] = 1; 
			nextState = 0;
			sliceSelector = 0;
			writeEnableKey = 0;
			counterNext = 0;
		end

		4: begin

			writeEnableKey[selectRead] = 1;
			if (counter < (roundNumber - 1)) begin
				counterNext = counter + 1;
				sliceSelector = counter;
				nextState = 4;
			end
			else begin
				counterNext = counterNext;
				sliceSelector = 0;
				nextState = 0;
				writeEnableKey = 0;
			end
		end

		default: begin
			counterNext = 0;
			sliceSelector = 0;
			writeEnableKey = 0;
			writeEnable = 0;
			nextState = 0;
		end

		endcase //end case states
end
	
endmodule
