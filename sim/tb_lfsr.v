module tb_lfsr();

reg clock = 0;
reg enable = 0;
reg loadSeed = 0;
reg [127:0] seed = 0;
wire [127:0] lfsr_out;
wire lfsr_done;

lfsr dut(
    .clock(clock),
    .enable(enable),
    .loadSeed(loadSeed),
	.seed(seed),
    .lfsr_out(lfsr_out),
    .lfsr_done(lfsr_done)
    );

always begin
	#5;
	clock = !clock;
	#5;
end

initial begin
	#20; enable = 1;
end
endmodule
