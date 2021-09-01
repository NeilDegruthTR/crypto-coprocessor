module LFSR_TB ();
 
  parameter c_NUM_BITS = 8;
   
  reg r_Clk = 1'b0;
   
  wire [c_NUM_BITS-1:0] w_LFSR_Data;
  wire w_LFSR_Done;
   
  LFSR #(.NUM_BITS(c_NUM_BITS)) LFSR_inst
         (.i_Clk(r_Clk),
          .i_Enable(1'b1),
          .i_Seed_DV(1'b0),
          .i_Seed_Data({c_NUM_BITS{1'b0}}), // Replication
          .o_LFSR_Data(w_LFSR_Data),
          .o_LFSR_Done(w_LFSR_Done)
          );
  
  always @(*)
    #10 r_Clk <= ~r_Clk; 
  
endmodule