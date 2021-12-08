`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2021 07:44:27
// Design Name: 
// Module Name: dsa_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dsa_block(
    input [255:0] r,
    input [255:0] s,
    input [255:0] z,
    input [2:0] dsaCSR,
    input clock,
    output reg [255:0] v,
	output reg regWrite,
	output reg csrUpdate,
	output reg [2:0] dsaCSR_o
    );
    
    parameter INV_RESET = 0;
    parameter INV_ENABLE = 1;
    parameter INV_WAIT = 2;
    parameter INV_WB = 3;
    parameter MUL_RESET = 4;
    parameter MUL_ENABLE = 5;
    parameter MUL_WAIT = 6;
    parameter MUL_WB = 7;
	parameter EXP_RESET = 8;
	parameter EXP_ENABLE = 9;
	parameter EXP_WAIT = 10;
	parameter EXP_WB = 11;
	parameter DIV_RESET = 12;
	parameter DIV_ENABLE = 13;
	parameter DIV_WAIT = 14;
	parameter DIV_WB = 15;
	parameter IDLE = 16;
    
    reg [2047:0] p = 2048'hF56C2A7D366E3EBDEAA1891FD2A0D099436438A673FED4D75F594959CFFEBCA7BE0FC72E4FE67D91D801CBA0693AC4ED9E411B41D19E2FD1699C4390AD27D94C69C0B143F1DC88932CFE2310C886412047BD9B1C7A67F8A25909132627F51A0C866877E672E555342BDF9355347DBD43B47156B2C20BAD9D2B071BC2FDCF9757F75C168C5D9FC43131BE162A0756D1BDEC2CA0EB0E3B018A8B38D3EF2487782AEB9FBF99D8B30499C55E4F61E5C7DCEE2A2BB55BD7F75FCDF00E48F2E8356BDB59D86114028F67B8E07B127744778AFF1CF1399A4D679D92FDE7D941C5C85C5D7BFF91BA69F9489D531D1EBFA727CFDA651390F8021719FA9F7216CEB177BD75;
    reg [2047:0] g = 2048'h8DC6CC814CAE4A1C05A3E186A6FE27EABA8CDB133FDCE14A963A92E809790CBA096EAA26140550C129FA2B98C16E84236AA33BF919CD6F587E048C52666576DB6E925C6CBE9B9EC5C16020F9A44C9F1C8F7A8E611C1F6EC2513EA6AA0B8D0F72FED73CA37DF240DB57BBB27431D618697B9E771B0B301D5DF05955425061A30DC6D33BB6D2A32BD0A75A0A71D2184F506372ABF84A56AEEEA8EB693BF29A640345FA1298A16E85421B2208D00068A5A42915F82CF0B858C8FA39D43D704B6927E0B2F916304E86FB6A1B487F07D8139E428BB096C6D67A76EC0B8D4EF274B8A2CF556D279AD267CCEF5AF477AFED029F485B5597739F5D0240F67C2D948A6279;
    reg [255:0] q = 256'hC24ED361870B61E0D367F008F99F8A1F75525889C89DB1B673C45AF5867CB467;
    reg [2047:0] y = 2048'h2828003D7C747199143C370FDD07A2861524514ACC57F63F80C38C2087C6B795B62DE1C224BF8D1D1424E60CE3F5AE3F76C754A2464AF292286D873A7A30B7EACBBC75AAFDE7191D9157598CDB0B60E0C5AA3F6EBE425500C611957DBF5ED35490714A42811FDCDEB19AF2AB30BEADFF2907931CEE7F3B55532CFFAEB371F84F01347630EB227A419B1F3F558BC8A509D64A765D8987D493B007C4412C297CAF41566E26FAEE475137EC781A0DC088A26C8804A98C23140E7C936281864B99571EE95C416AA38CEEBB41FDBFF1EB1D1DC97B63CE1355257627C8B0FD840DDB20ED35BE92F08C49AEA5613957D7E5C7A6D5A5834B4CB069E0831753ECF65BA02B;
    //reg [255:0] z = 256'hBA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD;
    reg [255:0] w_D = 0;
    reg [255:0] wReg = 0;
    wire [258:0] w;
    wire [255:0] gcd;
    wire invDone;
    wire [258:0] b_out;
    
    reg [7:0] state = 0;
    reg [7:0] nextState = 0;
    reg invReset = 1;
    reg invEnable = 0;
    reg [5:0] counter = 0;
    
    reg [2050:0] in1 = 0, in2 = 0;
    reg [2048:0] N_mul = 0;
    reg [2048:0] N_exp = 0;
    reg multInReady = 0;
    reg multReset = 1;
    wire [2050:0] multOut;
    wire multDone;
    
	reg [255:0] u1_D = 0;
    reg [255:0] u1Reg = 0;
	reg [255:0] u2_D = 0;
    reg [255:0] u2Reg = 0;
	reg [2047:0] v1_D = 0;
    reg [2047:0] v1Reg = 0;
	reg [2047:0] v2_D = 0;
    reg [2047:0] v2Reg = 0;
	reg [2047:0] v3_D = 0;
    reg [2047:0] v3Reg = 0;
	
	reg [1:0] mulOp = 0;
	reg [1:0] mulOp_D = 0;
	reg expOp = 0;
	reg expOp_D = 0;
	
	parameter NLEN = 2048;
	parameter TAG = 2;

	reg [2048:0] exp;
	reg [2050:0] base;
	reg expInReady;
	reg expReset = 0;
	wire [2050:0] expOut;
	wire expDone;
	
	reg divReset;
	reg divStart;
	wire [2047:0] divDen;
	wire [2047:0] divQuo;
	wire [2047:0] divRmn;
	wire divDone;
	
    bin_ext_gcd #(.NBITS(256)) modInv (
		.clk(clock),
		.rst_n(invReset),
		.enable_p(invEnable),
		.x(s), .y(q), .a(w), .b(b_out), .gcd(gcd),
		.done_irq_p(invDone) );
    
    modmult #(.NLEN(2048)) modmult0(
        .in1(in1),
        .in2(in2),
        .N(N_mul),
        .in_ready(multInReady),
        .clk(clock),
        .reset(multReset),
        .out(multOut),
        .out_ready(multDone)
    );
	
	ModExp #(.NLEN(2048)) modexp0(
		.base(base),
		.exp(exp),
		.N(N_exp),
		.in_ready(expInReady),
		.clk(clock),
		.reset(expReset),
		.out(expOut),
		.out_ready(expDone)
	);
    
    div #(.N(2048)) modMod (
        .clk(clock),
        .rst_n(divReset),
        .start(divStart),
        .num (v3Reg),
        .den ({{1792{1'b0}}, q}),
        .quo (divQuo),
        .rmn (divRmn),
        .done(divDone)
    );
    
    
    reg startFlag;
    reg startFlag_D;
    
    always @(posedge clock) begin
        state <= nextState;
        wReg <= w_D;
        u1Reg <= u1_D;
        u2Reg <= u2_D;
        v1Reg <= v1_D;
        v2Reg <= v2_D;
        v3Reg <= v3_D;
		mulOp <= mulOp_D;
		expOp <= expOp_D;
		
		
        case (state)
            INV_RESET, MUL_RESET, EXP_RESET, DIV_RESET: begin
                counter <= counter + 1;
            end
			default: begin
			    counter <= 0;
			end
        endcase
        
        if (dsaCSR[2] == 1) begin
            startFlag <= dsaCSR[2];
        end
		else
			startFlag <= startFlag_D;
    end
    
	always @(*) begin
		case (mulOp)
			0: begin
				in1 <= z;
				in2 <= w;
				N_mul <= q;
			end
			
			1: begin
				in1 <= r;
				in2 <= w;
				N_mul <= q;
			end
			
			2: begin
				in1 <= v1Reg;
				in2 <= v2Reg;
				N_mul <= p;
			end
			
			default: begin
				in1 <= 0;
				in2 <= 0;
				N_mul <= 0;
			end
		endcase
		
		case (expOp)
			0: begin
				base <= g;
				exp <= u1Reg;
				N_exp <= p;
			end
			
			1: begin
				base <= y;
				exp <= u2Reg;
				N_exp <= p;
			end
		endcase
	end
	
    always @(*) begin
        if (startFlag == 1) begin
            case (state)
                INV_RESET: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    multInReady <= 0;
                    mulOp_D <= 0;
                    v <= 0;
                    w_D <= wReg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2;
                    csrUpdate <= 1;
                    regWrite <= 0;
                    
                    invReset <= 0;
                    invEnable <= 0;
                    if (counter > 5)
                        nextState <= INV_ENABLE;
                    else
                        nextState <= INV_RESET;
                end
                
                INV_ENABLE: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    v <= 0;
                    mulOp_D <= 0;
                    multInReady <= 0;
                    w_D <= wReg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2;
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    invReset <= 1;
                    invEnable <= 1;
                    nextState <= INV_WAIT;
                end
                
                INV_WAIT: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    v <= 0;
                    multInReady <= 0;
                    w_D <= wReg;
                    mulOp_D <= 0;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2;
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    invEnable <= 0;
                    invReset <= 1;
                    if (invDone == 1)
                        nextState <= INV_WB;
                    else
                        nextState <= INV_WAIT;
                end
                
                INV_WB: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    v <= 0;
                    multInReady <= 0;
                    mulOp_D <= 0;
                    w_D <= w[255:0];
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2;
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    invEnable <= 0;
                    invReset <= 1;
                    nextState <= MUL_RESET;
                end
                
                MUL_RESET: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    v <= 0;
                    w_D <= wReg;
                    mulOp_D <= mulOp;
                    invReset <= 1;
                    invEnable <= 0;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    multInReady <= 0;
                    multReset <= 1;
                    if (counter > 5)
                        nextState <= MUL_ENABLE;
                    else
                        nextState <= MUL_RESET;
                end
                
                MUL_ENABLE: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    v <= 0;
                    w_D <= wReg;
                    invReset <= 1;
                    invEnable <= 0;
                    mulOp_D <= mulOp;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    multInReady <= 1;
                    multReset <= 0;
                    nextState <= MUL_WAIT;
                end
                
                MUL_WAIT: begin
                    u1_D <= u1Reg;
                    u2_D <= u2Reg;
                    v <= 0;
                    w_D <= wReg;
                    invReset <= 1;
                    invEnable <= 0;
                    mulOp_D <= mulOp;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    multInReady <= 0;
                    multReset <= 0;
                    if (multDone == 1)
                        nextState <= MUL_WB;
                    else
                        nextState <= MUL_WAIT;
                end
                
                MUL_WB: begin
                    w_D <= wReg;
                    invReset <= 1;
                    invEnable <= 0;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0;
                    v <= 0;
                    multInReady <= 0;
                    multReset <= 0;
                    if (mulOp == 0) begin
                        mulOp_D <= 1;
                        u1_D <= multOut[255:0];
                        u2_D <= u2Reg;
                        nextState <= MUL_RESET;
                    end
                    else if (mulOp == 1) begin
                        mulOp_D <= 1;
                        u1_D <= u1Reg;
                        u2_D <= multOut[255:0];
                        nextState <= EXP_RESET;
                    end
                    else if (mulOp == 2) begin
                        u1_D <= u1Reg;
                        u2_D <= u2Reg;
                        mulOp_D <= 0;
                        v3_D <= multOut[2047:0];
                        nextState <= DIV_RESET;
                    end
                    
                end
                
                EXP_RESET: begin
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    v <= 0;
                    multInReady <= 0;
                    multReset <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    expReset <= 1;
                    expInReady <= 0;
                    if (counter > 5)
                        nextState <= EXP_ENABLE;
                    else
                        nextState <= EXP_RESET;
                end
                
                EXP_ENABLE: begin
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    multInReady <= 0;
                    v <= 0;
                    multReset <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 1;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    nextState <= EXP_WAIT;
                end
                
                EXP_WAIT: begin
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    v <= 0;
                    multInReady <= 0;
                    multReset <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    expReset <= 0;
                    expInReady <= 0;
                    if (expDone == 1)
                        nextState <= EXP_WB;
                    else
                        nextState <= EXP_WAIT;
                end
                
                EXP_WB: begin
                    multInReady <= 0;
                    multReset <= 0;
                    v <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    if (expOp == 0) begin
                        v1_D <= expOut[2047:0];
                        v2_D <= v2Reg;
                        expOp_D <= 1;
                        mulOp_D <= mulOp;
                        nextState <= EXP_RESET;
                    end
                    else begin
                        v1_D <= v1Reg;
                        v2_D <= expOut[2047:0];
                        expOp_D <= 0;
                        mulOp_D <= 2;
                        nextState <= MUL_RESET;
                    end
                end
                
                DIV_RESET: begin
                    multInReady <= 0;
                    multReset <= 0;
                    v <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    divReset <= 0;
                    divStart <= 0;
                    if (counter > 5)
                        nextState <= DIV_ENABLE;
                    else
                        nextState <= DIV_RESET;
                end
                
                DIV_ENABLE: begin
                    multInReady <= 0;
                    multReset <= 0;
                    v <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    divReset <= 1;
                    divStart <= 1;
                    nextState <= DIV_WAIT;
                end
                
                DIV_WAIT: begin
                    multInReady <= 0;
                    multReset <= 0;
                    v <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 2; 
                    csrUpdate <= 0;
                    regWrite <= 0; 
                    
                    divReset <= 1;
                    divStart <= 0;
                    if (divDone == 1)
                        nextState <= DIV_WB;
                    else
                        nextState <= DIV_WAIT;
                end
                
                DIV_WB: begin
                    multInReady <= 0;
                    multReset <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    
                    startFlag_D <= startFlag;
                    dsaCSR_o <= 1; 
                    csrUpdate <= 1;
                    regWrite <= 1;
                    
                    divReset <= 1;
                    divStart <= 0;
                    v <= divRmn[255:0];
                    nextState <= IDLE;
                end
                
                IDLE: begin
                    multInReady <= 0;
                    multReset <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    divReset <= 1;
                    divStart <= 0;
                    
                    startFlag_D <= 0;
                    v <= divRmn[255:0];
                    dsaCSR_o <= 1; 
                    csrUpdate <= 0;
                    regWrite <= 0;
                    
                    nextState <= INV_RESET;
                end
                
                default: begin
                    multInReady <= 0;
                    multReset <= 0;
                    invReset <= 1;
                    invEnable <= 0;
                    expReset <= 0;
                    expInReady <= 0;
                    u1_D <= u1Reg;
                    w_D <= wReg;
                    u2_D <= u2Reg;
                    divReset <= 1;
                    divStart <= 0;
                    startFlag_D <= 0;
					
					dsaCSR_o <= 1; 
                    csrUpdate <= 0;
                    regWrite <= 0;
                    nextState <= INV_RESET;
                end
            endcase
        end //if end
        else begin
            multInReady <= 0;
            multReset <= 0;
            invReset <= 1;
            invEnable <= 0;
            expReset <= 0;
            expInReady <= 0;
            startFlag_D <= 0;
            u1_D <= u1Reg;
            w_D <= wReg;
            u2_D <= u2Reg;
            divReset <= 1;
            divStart <= 0;
			dsaCSR_o <= 0; 
			csrUpdate <= 0;
			regWrite <= 0;
            nextState <= INV_RESET;
        end
    end //always end
endmodule
