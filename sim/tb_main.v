module tb_main ();


reg clock = 0;
reg readWrite = 0;
reg [3:0] selectWrite = 0;
reg [255:0] writeBus = 0;
reg [3:0] selectRead = 2;
wire [255:0] dataOut;

main dut (clock, readWrite, selectWrite, writeBus, selectRead, dataOut);

always begin
#5;
clock = ~clock;
#5;
end

initial begin
readWrite = 1;
selectWrite = 3;
writeBus = 4;
#25;
readWrite = 0;
selectWrite = 0;
writeBus = 0;
end
endmodule