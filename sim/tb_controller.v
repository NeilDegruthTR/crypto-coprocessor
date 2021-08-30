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

instruct = 32'h88000000;
#20;
instruct = 32'h12000001;
#15;
instruct = 32'h38000002;
#15;
instruct = 32'h58000003;
#20;
instruct = 32'hC8000004;
#75;
instruct = 32'h08000000;


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