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
    input [31:0] instruct, //260
    output reg [31:0] out //255
    );
	
	reg [3:0] selectRead = 0;
	reg [15:0] writeEnable = 0;
	reg [255:0] writeBus = 0;
	wire [255:0] dataOut;
	
	reg [1:0] state = 0;
	reg [1:0] nextState = 0;
	//0 = Read, 1= Write
	integer roundNumber = 0;
	integer counter = 0;
	
main datapath (clock, writeEnable, writeBus, selectRead, dataOut);

always @(posedge clock) begin

	state = nextState;

	case (state)

	0: begin
		counter = 0;
		out = 0;
		writeEnable = 0;
		writeBus = 0;
		selectRead = instruct[30:27];
		if (instruct[31] == 0) //Read
			nextState = 1;
		else //Write
			nextState = 2;
	end

	1: begin //Read case
		writeEnable = 0;
		writeBus = 0;
		if (counter <= roundNumber) begin
			out = dataOut[31*counter+31-:32];
			nextState = 1;
		end
		else begin
			nextState = 0;
		end
		counter = counter + 1;
		
		end //end case 1


	2: begin
		out = 0;
		writeEnable = 0;
		if (counter <= roundNumber) begin
			writeBus[31*counter+31-:32] = instruct;
			nextState = 1;
		end
		else begin
			nextState = 3;
		end
		counter = counter + 1;
	end

	3: begin
		writeEnable[selectRead] = 1; 
		nextState = 0;
		out = 0;
	end

	endcase //end case states
	end
	
	always @(*) begin

	if (state == 0) begin
		
		case (instruct[30:27])
			0,1,2,4,8,9: begin
				roundNumber = 4;
			end
			5,6: begin
				roundNumber = 8;
			end
			12,13,14: begin
				roundNumber = 5;
			end
			default: begin
				roundNumber = 1;
			end
		endcase
		
	end

	end
	
/* 	always @(posedge clock) begin
 if (instruct[260] == 0) begin //Read instruction
	selectRead = instruct[259:256];
	writeEnable = 0;
	writeBus = instruct[255:0];
	out = dataOut;
end

else if (instruct[260] == 1) begin //Write instruction
	selectRead = 0;
	writeEnable = 0;
	writeEnable[instruct[259:256]] = 1;
	writeBus = instruct[255:0];
	out = 0;
end

end */

//always end


endmodule
