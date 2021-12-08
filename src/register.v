`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2021 19:39:48
// Design Name: 
// Module Name: register0
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


//Register
module register # (parameter k=128)

( input clock,
input we_i, input [k-1:0] writeData_i, 
output [k-1:0] dataRead_o
);

reg [k-1:0] data = 0;

assign dataRead_o = data;

always @(posedge clock) begin

if (we_i == 1)
	data = writeData_i;

end
endmodule
