module tb_controller ();

reg clock = 0;
reg [266:0] instruct = 0; //266
wire [255:0] out = 0; //255

controller dut (clock, instruct, out);

always begin
#5;
clock = ~clock;
#5;
end

initial begin
instruct[260] = 1;
instruct[259:256] = 8;
instruct[255:0] = 12;
#15;
instruct[259:256] = 10;
instruct[255:0] = 'b0100;
#25;
instruct[260] = 0;
instruct[259:256] = 9;
end
endmodule