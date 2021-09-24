module tb_controller ();

reg clock = 0;
reg [31:0] instruct = 0;
wire [31:0] out;

controller dut (clock, instruct, out);

always begin
#5;
clock = ~clock;
#5;
end

initial begin
	/* instruct = 32'h80000000; //ef0bc156 ed8ff212 23f247b3 e0318a99
	#45;
	instruct = 32'he0318a99;
	#15;
	instruct = 32'h23f247b3;
	#15;
	instruct = 32'hed8ff212;
	#20;
	instruct = 32'hef0bc156;
	#120; */
	instruct = 32'h80000007;
	#30;
	instruct = 32'h4;

end
endmodule