module tb_controller ();

reg clock = 0;
reg [31:0] instruct = 0; //266
wire [31:0] out; //255

controller dut (clock, instruct, out);

always begin
#5;
clock = ~clock;
#5;
end

initial begin
	instruct = 32'h80000000;
	#20;
	instruct = 32'hec0d7191;
	#15;
	instruct = 32'h6eaf70a0;
	#15;
	instruct = 32'h864cdfe0;
	#20;
	instruct = 32'hdda97ca4;
	#80;
	instruct = 32'h80000003;
	#15;
	instruct = 32'h4;


/* instruct[260] = 1;
instruct[259:256] = 8;
instruct[255:0] = 12;
#15;
instruct[259:256] = 10;
instruct[255:0] = 'b0100;
#25;
instruct[260] = 0;
instruct[259:256] = 9; */
end
endmodule