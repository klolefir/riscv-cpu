`timescale 1ns / 1ps

module riscv_core
#(
	parameter WIDTH = 32
)
(
	input logic clk_i, rst_i,
	input logic signed [WIDTH-1:0] ext_data,

	
	//instr
	input logic [WIDTH-1:0] instr_rdata_i,
	//pc
	output logic [WIDTH-1:0] pc,

	//for LSU
	input logic [WIDTH-1:0] data_rdata_i,
	//from LSU
	output lsu_stall_req_o,
	output logic data_req_o,
	output logic data_we_o,
	output logic [3:0] data_be_o,
	output logic [WIDTH-1:0] data_addr_o,
	output logic [WIDTH-1:0] data_wdata_o,

	//from interrupt
	input logic [4:0] int_mcause,
	input logic int_i,
	//for interrupt
	output logic int_rst_o,
	//input logic int_rst_o,
	output logic [WIDTH-1:0] int_mie
);

	//decoder signals
	logic [1:0] ex_op_a_sel_o;
	logic [2:0] ex_op_b_sel_o;
	logic [4:0] alu_op_o;
	logic mem_req_o;
	logic mem_we_o;
	logic [2:0] mem_size_o;
	logic gpr_we_a_o;
	logic wb_src_sel_o;
	logic illegal_instr_o;
	logic branch_o;
	logic jal_o;
	logic [1:0] jalr_o;
	logic enpc;
	logic lsu_stall_req_o;
	//new(interrupt)
	logic csr_o;
	logic [2:0] csr_op_o;

	datapath riscv_datapath
	(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.ext_data(ext_data),
		.instr(instr_rdata_i),
		.*
	);

	decoder_riscv riscv_decoder
	(
		.fetched_instr_i(instr_rdata_i),
		.*
	);

endmodule: riscv_core
