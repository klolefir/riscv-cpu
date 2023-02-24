`timescale 1ns / 1ps

module riscv_top
#(
	parameter WIDTH = 32,
	parameter RAM_SIZE = 256,
	parameter RAM_INIT_FILE = ""
)
(
	input clk_i,
	input rst_i,
	input logic [4:0] intr_req,
	output logic [4:0] intr_fin
);	
	//interrupt controller
	logic [4:0] intr_mie;
	logic intr;
	logic [2:0] intr_mcause;
	logic intr_rst;

	//pc
	logic [WIDTH-1:0] pc;

	//instr
	logic [WIDTH-1:0] instr_rdata_core;

	//instr addr
	logic [WIDTH-1:0] instr_addr_core;

	//data core
	logic [WIDTH-1:0] data_rdata_core;
	logic data_req_core;
	logic data_we_core;
	logic [3:0] data_be_core;
	logic [WIDTH-1:0] data_addr_core;
	logic [WIDTH-1:0] data_wdata_core;

	//data ram
	logic [WIDTH-1:0] instr_addr_ram;
	logic [WIDTH-1:0] instr_rdata_ram;
	logic [WIDTH-1:0] data_rdata_ram;
	logic data_req_ram;
	logic data_we_ram;
	logic [3:0] data_be_ram;
	logic [WIDTH-1:0] data_addr_ram;
	logic [WIDTH-1:0] data_wdata_ram;

	logic data_mem_valid;
	assign data_mem_valid = (data_addr_core >= RAM_SIZE) ? 1'b0 : 1'b1;

	assign data_rdata_core = (data_mem_valid) ? data_rdata_ram : 1'b0;
	assign data_req_ram = (data_mem_valid) ? data_req_core : 1'b0;
	assign data_we_ram = data_we_core;
	assign data_be_ram = data_be_core;
	assign data_addr_ram = data_addr_core;
	assign data_wdata_ram = data_wdata_core;

	assign instr_addr_ram = pc;
	assign instr_rdata_core = instr_rdata_ram;

	riscv_core core
	(
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		//interrupt
		.int_mcause(intr_mcause),
		.int_mie(intr_mie),
		.int_rst_o(intr_rst),
		.int_i(intr),

		.instr_rdata_i(instr_rdata_core),
		//.instr_addr_o(instr_addr_core),
		.pc(pc),
		
		.data_rdata_i(data_rdata_core),
		.data_req_o(data_req_core),
		.data_we_o(data_we_core),
		.data_be_o(data_be_core),
		.data_addr_o(data_addr_core),
		.data_wdata_o(data_wdata_core)
	);

	riscv_rom 
	#(
		.RAM_SIZE (RAM_SIZE),
		.RAM_INIT_FILE (RAM_INIT_FILE)
	) riscv_rom
	(
		.clk_i(clk_i),
		.rst_i(rst_i),

		//.instr_rdata_o(instr_rdata_core),
		//.instr_addr_i(instr_addr_core),

		.instr_rdata_o(instr_rdata_ram),
		.instr_addr_i(instr_addr_ram),

		.data_rdata_o(data_rdata_ram),
		.data_req_i(data_req_ram),
		.data_we_i(data_we_ram),
		.data_be_i(data_be_ram),
		.data_addr_i(data_addr_ram),
		.data_wdata_i(data_wdata_ram)
	);

	interrupt_controller
	#(
		.WIDTH(WIDTH)
	) riscv_int
	(
		.clk(clk_i),
		.mie(intr_mie),
		.intr_rst(intr_rst),
		.intr_req(intr_req),
		.intr_fin(intr_fin),
		.intr(intr),
		.mcause(intr_mcause)
	);

endmodule: riscv_top
