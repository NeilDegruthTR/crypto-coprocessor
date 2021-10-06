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
	output reg [4:0] sliceSelector = 0,
	output reg [5:0] writeEnableKey = 0,
	output reg [3:0] selectRead = 0,
	output reg [15:0] writeEnable = 0,
	output reg [447:0] writeBus = 0
    );
	
	reg [2:0] state = 0;
	reg [2:0] nextState = 0;

	integer roundNumber = 0;
	integer counter = 0;


always @(posedge clock) begin

	//state <= nextState;

	case (state)

	0: begin
		counter <= 0;
		sliceSelector <= 0;
		writeEnableKey <= 0;
		out <= 0;
		writeEnable <= 0;
		writeBus <= 0;
		selectRead <= instruct[3:0];
		
		if (instruct[31:30] == 2'b00) begin
			case (selectRead)
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
				default: begin
					roundNumber <= 1;
				end
			endcase
			state <= 1;
		end
		else if (instruct[31:30] == 2'b01) begin
			case (selectRead)
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
				default: begin
					roundNumber <= 1;
				end
			endcase
			state <= 2;
		end
		else if (instruct[31:30] == 2'b10) begin
			case (selectRead)
				0,1: begin
					roundNumber <= 4;
				end
				2: begin
					roundNumber <= 5;
				end
				3,4,5: begin
					roundNumber <= 32;
				end
				default: begin
					roundNumber <= 1;
				end
			endcase
			state <= 4;
		end
		else
			state <= 0;

	end

	1: begin //Read case
		writeEnable <= 0;
		writeBus <= 0;
		sliceSelector <= 0;
		writeEnableKey <= 0;
		if (counter < roundNumber) begin
			out <= dataOut[32*counter+31 -:32];
			state <= 1;
		end
		else begin
			state <= 0;
		end
		counter <= counter + 1;
		
		end //end case 1


	2: begin //Write case
		out <= 0;
		writeEnable <= 0;
		sliceSelector <= 0;
		writeEnableKey <= 0;
		if (counter < roundNumber) begin
			writeBus[32*counter+31 -:32] <= instruct;
			state <= 2;
		end
		else begin
			state <= 3;
		end
		counter <= counter + 1;
	end

	3: begin
		writeEnable[selectRead] <= 1; 
		state <= 0;
		out <= 0;
		sliceSelector <= 0;
		writeEnableKey <= 0;
		counter <= 0;
	end
	
	4: begin
		out <= 0;
		writeEnableKey[selectRead] <= 1;
		if (counter < roundNumber) begin
			sliceSelector <= counter;
			counter <= counter + 1;
			state <= 4;
		end
		else begin
			sliceSelector <= 0;
			state <= 0;
			writeEnableKey <= 0;
			counter <= 0;
		end
		
	end
	
	default: begin
	   out <= 0;
       sliceSelector <= 0;
       writeEnableKey <= 0;
	   counter <= 0;
	end

	endcase //end case states
	end
	
endmodule
