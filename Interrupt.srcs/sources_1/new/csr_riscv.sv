`timescale 1ns / 1ps

//`define MIE 32'h304
`define MIE 12'b0011_0000_0100
`define MTVEC 12'b0011_0000_0101
`define MSCRATCH 12'b0011_0100_0000
`define MEPC 12'b0011_0100_0001
`define MCAUSE 12'b0011_0100_0010

module csr_riscv
#(
	parameter WIDTH = 32, 
	parameter ADDR_WIDTH = 12
)
(
	input logic clk,
	input logic rst,
	input logic [WIDTH-1:0] wd,
	input logic [2:0] op,
	input logic [ADDR_WIDTH-1:0] addr,
	input logic [WIDTH-1:0] pc,
	input logic [2:0] mcause,
	output logic [4:0] mie,
	output logic [WIDTH-1:0] mtvec,
	output logic [WIDTH-1:0] mepc,
	output logic [WIDTH-1:0] rd
);
	logic en;
	logic en_mie, en_mtvec, en_mscratch, en_mepc, en_mcause;
	logic [WIDTH-1:0] mepc_in, mepc_out;
	logic [WIDTH-1:0] mie_in, mie_out;
	logic [WIDTH-1:0] mtvec_in, mtvec_out;
	logic [WIDTH-1:0] mcause_in, mcause_out;
	logic [WIDTH-1:0] mscratch_in, mscratch_out;
	logic [WIDTH-1:0] csr_in;

	assign en = op[1] || op[0];
	assign mie = mie_out;
	assign mtvec = mtvec_out;
	assign mepc = mepc_out;


	flopenr flop_mie
	(
		.*,
		.en(en_mie),
		.d(mie_in),
		.q(mie_out)
	);

	flopenr flop_mtvec
	(
		.*,
		.en(en_mtvec),
		.d(mtvec_in),
		.q(mtvec_out)
	);

	flopenr flop_mscratch
	(
		.*,
		.en(en_mscratch),
		.d(mscratch_in),
		.q(mscratch_out)
	);	

	flopenr flop_mepc
	(
		.*,
		.en(en_mepc),
		.d(mepc_in),
		.q(mepc_out)
	);	

	flopenr flop_mcause
	(
		.*,
		.en(en_mcause),
		.d(mcause_in),
		.q(mcause_out)
	);	


	always_comb begin
		case(op)
		3'b011:
			csr_in = (wd | rd);
		3'b010:
			csr_in = (~wd & rd);
		3'b001:
			csr_in = wd;
		3'b000:
			csr_in = 32'b0;
		default:
			csr_in = 32'b0;
		endcase
	end

	always_comb begin
		mie_in = csr_in;
		mtvec_in = csr_in;
		mscratch_in = csr_in;
		if(op[2]) begin
			mepc_in = pc;
			mcause_in = mcause;
		end
		else begin
			mepc_in = csr_in;
			mcause_in = csr_in;
		end
	end
	
//	always_ff @(*) begin
	always_comb begin
		en_mie = 0;
		en_mtvec = 0;
		en_mscratch = 0;
		en_mepc = op[2] || ((addr == `MEPC) ? en : 1'b0);
		en_mcause = op[2] || ((addr == `MCAUSE) ? en : 1'b0);


		case(addr) 
		`MIE:
			en_mie = en;
		`MTVEC: 
			en_mtvec = en;
		`MSCRATCH:	
			en_mscratch = en;
		default: begin
		end	
		endcase
	end
	//demux
	//always_ff @(posedge clk) begin
	always_comb begin
		case(addr) 
		`MIE:
			rd = mie_out;
		`MTVEC: 
			rd = mtvec_out;
		`MSCRATCH:	
			rd = mscratch_out;
		`MEPC:
			rd = mepc_out;
		`MCAUSE:
			rd = mcause_out;
		default:
			rd = 32'b0;
		endcase
	   //rd = (addr == `MIE) ? mie_out : (addr == `MTVEC) ? mtvec_out : (addr == `MSCRATCH) ? mscratch_out : (addr == `MEPC) ? mepc_out : (addr == `MCAUSE) ? mcause_out : 32'b0;
	end

endmodule	
