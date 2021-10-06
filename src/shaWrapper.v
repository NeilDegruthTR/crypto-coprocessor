


module SHA2wrapper (
	input [447:0] plaintext,
	input [66:0] sha2CSR,
	input clock,
	output [255:0] digest,
	output reg [2:0] sha2CSR_o = 0,
	output reg regwrite = 0,
	output reg csrUpdate = 0
);

reg [511:0] shaPlaintext = 0; //= 'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;

reg reset = 0;
reg [3:0] state = 0;
reg [3:0] nextState = 0;
reg startFlag = 0;
reg [3:0] counter = 0;

//assign shaPlaintext = {{255{1'b0}},plaintext};

reg load = 0;

wire empty;
wire [255:0] hash;
wire shaFinish;

integer shiftAmount = 0;

assign digest = hash;

sha256for1chunk sha2560
			( .reset(reset),
			  .clock(clock),
			  .plain(shaPlaintext),
			  .load(load),
			  .empty(empty),
			  .digest(hash),
			  .ready(shaFinish)
			  );

always @(posedge clock)
begin

state <= nextState;

if (sha2CSR[2] == 1) begin
	startFlag <= 1;
	nextState <= 0;
	shaPlaintext <= 0;
end

if (startFlag == 1) begin

case (state)
8'd0: begin //Pad the plaintext, update csr and reset
	reset <= 1;
	regwrite <= 0;
	sha2CSR_o <= 2;
	csrUpdate <= 1;
	load <= 0;
	
	shiftAmount <= 447 - sha2CSR[66:3] + 64;
	
	shaPlaintext <= {plaintext[446:0], 1'b1} << shiftAmount;
	
	shaPlaintext[63:0] <= sha2CSR[66:3];
	
	if (counter > 6)
		nextState <= 1;
	else begin
		nextState <= 0;
		counter <= counter + 1;
	end
	
end

8'd1: begin //Start hashing
	reset <= 0;
	load <= 1;
	sha2CSR_o <= 2;
	csrUpdate <= 0;
	regwrite <= 0;
	nextState <= 2;
	
end

8'd2: begin //Wait for hashing
	load <= 0;
	csrUpdate <= 0;
	sha2CSR_o <= 2;
	regwrite <= 0;
	
	if (shaFinish == 1) begin
		nextState <= 3;
		regwrite <= 1;
	end
	else begin
		nextState <= 2;
	end

end

8'd3: begin
	regwrite <= 0;
	sha2CSR_o <= 1;
	csrUpdate <= 1;
	nextState <= 4;
end

8'd4: begin
	regwrite <= 0;
	sha2CSR_o <= 1;
	csrUpdate <= 0;
	nextState <= 0;
	startFlag <= 0;
	load <= 0;
	shaPlaintext <= 0;
end

default: begin
	regwrite <= 0;
	csrUpdate <= 0;
	nextState <= 0;
	shaPlaintext <= 0;
end
endcase

end
end
endmodule