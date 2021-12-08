`timescale 1ns / 1ps
module modmult #(parameter NLEN = 1024, parameter TAG = 2)(
    input      signed [NLEN+TAG:0]  in1         ,
    input      signed [NLEN+TAG:0]  in2         ,
    input      signed [    NLEN:0]  N           ,
    input                           in_ready    ,
    input                           clk         ,
    input                           reset       ,
    output reg signed [NLEN+TAG:0]  out         ,
    output reg                      out_ready
);
//Local variables
localparam INITVAL = -1;
reg signed [2:0] state = INITVAL;
reg signed [NLEN+TAG:0] temp1,temp2;
integer i,j,k;
//Main code
always @(posedge clk)
begin
    if(reset==1)
    begin
        out_ready   <= 0;
        state       <= INITVAL;
    end
    else
    begin
        case (state)
            INITVAL :
            begin
                if(in_ready==1)
                begin
                    state       <= 0; 
                    out_ready   <= 0; 
                    out         <= 0;
                    if(in1<0)
                    begin
                        temp1 <= (in2<0) ? -in1 : in2;
                        temp2 <= (in2<0) ? -in2 : in1;
                    end
                    if(in1>0)
                    begin
                        temp1 <= in1; 
                        temp2 <= in2;
                    end
                    if(in1==0 || in2==0)
                    begin
                        j       <= NLEN;
                        out     <= 0;
                        state   <= 3;
                    end
                    i <= 0;
                    j <= 0;
                    k <= 0;
                end
            end
            0 : 
            begin
                temp1   <= temp1 <<< 1;
                temp2   <= temp2 <<< 1;
                state   <= 1;
                k       <= k + 1;
            end
            1 :
            begin
                if(temp1<N && temp2<N)
                begin
                    if(k<NLEN)
                        state <= 0;
                    if(k>=NLEN)
                    begin
                        out     <= 0;
                        state   <= 2;
                    end
                end
                if(temp1>=N && temp2>=N)
                begin
                    temp1 <= temp1 - N;
                    temp2 <= temp2 - N;
                end
                if(temp1>=N && temp2<N)
                    temp1 <= temp1 - N;
                if(temp1<N && temp2>=N)
                    temp2 <= temp2 - N;
            end
            2 :
            begin
                if(i<NLEN)
                begin
                    i <= i + 1;
                    if(temp1[i]==1)
                        out <= (out+temp2+(((out[0]^temp2[0])==1)?N:0))>>>1;
                    else
                        out <= (out+((out[0]==1)?N:0))>>>1;
                end
                else
                    state <= 3;
            end
            3 :
            begin
                if(j<NLEN)
                begin
                    out <= (out + ((out[0]==1) ? N : 0)) >>> 1;
                    j   <= j + 1;
                end
                else
                begin
                    out_ready <= 1;
                    //state <= INITVAL;
                end
            end
            //For testing purposes only
            default :
            begin
                $display("Error : Invalid case");
            end
        endcase
    end
end

endmodule