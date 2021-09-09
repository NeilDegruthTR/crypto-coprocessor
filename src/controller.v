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
    output reg [31:0] out = 0
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

	state <= nextState;

	case (state)

	0: begin
		counter <= 0;
		out <= 0;
		writeEnable <= 0;
		writeBus <= 0;
		selectRead <= instruct[3:0];
		case (selectRead)
			0,1,2,4,8,9: begin
				roundNumber <= 4;
			end
			5,6: begin
				roundNumber <= 8;
			end
			12,13,14: begin
				roundNumber <= 5;
			end
			default: begin
				roundNumber <= 1;
			end
		endcase
		if (instruct[31] == 0) //Read
			nextState <= 1;
		else //Write
			nextState <= 2;
	end

	1: begin //Read case
		writeEnable <= 0;
		writeBus <= 0;
		if (counter < roundNumber) begin
			out <= dataOut[32*counter+31 -:31];
			/* case (counter)
			0: begin
				out = dataOut[31:0];
			end
			
			1: begin
				out = dataOut[63:32];
			end
			
			2: begin
				out = dataOut[95:64];
			end
			
			3: begin
				out = dataOut[127:96];
			end
			
			4: begin
				out = dataOut[159:128];
			end
			
			5: begin
				out = dataOut[191:160];
			end
			
			6: begin
				out = dataOut[223:192];
			end
			
			7: begin
				out = dataOut[255:224];
			end
			
			default: begin
				out = dataOut[31:0];
			end
			
			endcase */
			
			nextState <= 1;
		end
		else begin
			nextState <= 0;
		end
		counter <= counter + 1;
		
		end //end case 1


	2: begin //Write case
		out <= 0;
		writeEnable <= 0;
		if (counter < roundNumber) begin
			writeBus[32*counter+31 -:31] <= instruct;
			/* case (counter)
			0: begin
				writeBus[31:0] = instruct;
			end
			
			1: begin
				writeBus[63:32] = instruct;
			end
			
			2: begin
				writeBus[95:64] = instruct;
			end
			
			3: begin
				writeBus[127:96] = instruct;
			end
			
			4: begin
				writeBus[159:128] = instruct;
			end
			
			5: begin
				writeBus[191:160] = instruct;
			end
			
			6: begin
				writeBus[223:192] = instruct;
			end
			
			7: begin
				writeBus[255:224] = instruct;
			end
			
			default: begin
				writeBus[31:0] = instruct;
			end
			
			endcase */
			
			
			nextState <= 2;
		end
		else begin
			nextState <= 3;
		end
		counter <= counter + 1;
	end

	3: begin
		writeEnable[selectRead] <= 1; 
		nextState <= 0;
		out <= 0;
	end

	endcase //end case states
	end
	
	always @(*) begin

	if (state == 0) begin
		
		
		
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
