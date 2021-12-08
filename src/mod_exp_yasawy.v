`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2021 09:57:26
// Design Name: 
// Module Name: mod_exp_yasawy
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


//Author: Yasaswy Kasarabada
//Date: June 29, 2016
/****************************************************************************
This module performs Modular exponentiation on base and the inputs exp, N. clk
is the clock input. in_ready and reset control data flow within the module. out
return the value of base^exp (mod N). out_ready indicates readiness of out.
****************************************************************************/
module ModExp #(
parameter NLEN = 1024,
parameter TAG = 2
)(
input signed [NLEN:0] exp,
input signed [NLEN:0] N,
input signed [NLEN+TAG:0] base,
input in_ready,
input clk,
input reset,
output reg signed [NLEN+TAG:0] out,
output reg out_ready
);
//Local variables
localparam INITVAL = -1;
reg signed [2:0] state = INITVAL;
reg flag;
reg signed [NLEN:0] exp_local;
reg signed [NLEN+TAG:0] base_temp;
//////////////////////SUB-MODULE INSTANTIATIONS//////////////////////
reg modm_in_ready=0,base2_in_ready=0,modm_reset=0,base2_reset=0;
wire modm_out_ready,base2_out_ready;
wire signed [NLEN+TAG:0] modm_out,base2_out;
//Modular multiplication module instantiation
//to calculate out*base mod N
modmult #(.NLEN (NLEN ), .TAG (TAG )
) modm (
.in1 (base_temp ),
.in2 (out ),
.N (N ),
.in_ready (modm_in_ready ),
.clk (clk ),
.reset (modm_reset ),
.out (modm_out ),
.out_ready (modm_out_ready )
);

//Modular multiplication module instantiation
//to calculate base*base mod N
modmult #(.NLEN (NLEN ), .TAG (TAG ) ) base2 (
.in1 (base_temp ),
.in2 (base_temp ),
.N (N ),
.in_ready (base2_in_ready ),
.clk (clk ),
.reset (base2_reset ),
.out (base2_out ),
.out_ready (base2_out_ready )
);
//////////////////SUB-MODULE INSTANTIATIONS COMPLETE/////////////////
//Main code
always @(posedge clk)
begin
    if(reset==1) begin
        out_ready <= 0;
        state <= INITVAL;
    end
    else begin
    case (state)
        INITVAL : if(in_ready==1) begin
            out <= 1; out_ready <= 0;
            exp_local <= exp;
            base_temp <= base; 
            flag <= 0;
            state <= 0;
        end
        0 : if(exp_local>0) begin
        state <= 1;
        //Compute val = val * base (mod N)
        if(exp_local[0]==1) begin
            flag <= 1;
        if(modm_in_ready==1)
            modm_reset <= 1;
        else
        modm_in_ready <= 1;
        end
        //Computer base = base * base (mod N)
        if(base2_in_ready==1)
        base2_reset <= 1;
        else
        base2_in_ready <= 1;
        end
        else
        state <= 3;
        1 : begin
        modm_reset <= 0;
        base2_reset <= 0;
        state <= 2;
        end
        2 : if(flag==1) begin //if exponent is odd
        if(modm_out_ready==1 && base2_out_ready==1) begin
        exp_local <= exp_local >>> 1;
        base_temp <= base2_out;
        flag <= 0;
        out <= modm_out;
        state <= 0;
        end
        end
        else begin //if exponent is even
        if(base2_out_ready==1) begin
        exp_local <= exp_local >>> 1;
        base_temp <= base2_out;
        state <= 0;
        end
        end
        3 : begin
        out_ready <= 1;
        end
        //For testing purposes only
        default : begin
        $display("Error : Invalid case");
        end
    endcase
    end
    end
endmodule