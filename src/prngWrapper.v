module PRNG (
	input [127:0] seed,
	input [127:0] generatedSeed_i,
	input [3:0] csr,
	input clock,
	output reg [127:0] generatedReg = 0,
	output reg [2:0] csr_o = 0,
	output reg ctrwrite = 0,
	output reg csrUpdate = 0
);

reg [3:0] state = 0;
reg [3:0] nextState = 0;
reg startFlag = 0;
reg prngEnable = 0;
reg loadSeed = 0;
reg [6:0] counter = 0;
wire prngDone;
wire [127:0] generatedReg_inside;
reg [127:0] selectedSeed;

lfsr PRNG (clock, prngEnable, loadSeed, selectedSeed, generatedReg_inside, prngDone);

always @(posedge clock)
begin

state = nextState;

if (csr[2] == 1) begin
	startFlag = 1;
	counter = 0;
end

if (startFlag == 1) begin

case (state)
8'd0: begin //Update csr and load seed
	generatedReg = 0;
	ctrwrite = 0;
	csr_o = 2;
	csrUpdate = 1;
	prngEnable = 1;
	loadSeed = csr[3];
	if (counter == 0)
		selectedSeed = seed;
	else
		selectedSeed = generatedSeed_i;
		
	nextState = 1;
end

8'd1: begin //Start module
	generatedReg = 0;
	csr_o = 2;
	csrUpdate = 0;
	ctrwrite = 0;
	prngEnable = 1;
	loadSeed = 0;
	
	if (prngDone == 0) begin
		nextState = 1;
	end
	else begin
		prngEnable = 0;
		nextState = 2;
	end
	
end

8'd2: begin //Operation end
	generatedReg = generatedReg_inside;
	csr_o = 1;
	csrUpdate = 1;
	ctrwrite = 1;
	
	if (counter > 10) begin
		startFlag = 0;
		counter = 0;
		nextState = 0;
	end
	else
		nextState = 1;
	
	counter = counter + 1;
end

default: begin
	generatedReg = 0;
	ctrwrite = 0;
end
endcase

	
end
end

endmodule