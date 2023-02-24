`timescale 1ns / 1ps

module riscv_rom
#(
	parameter WIDTH = 32,
	parameter RAM_SIZE = 256,
	parameter RAM_INIT_FILE = ""
)
(
	input logic clk_i,
	input logic rst_i,

	output logic [WIDTH-1:0] instr_rdata_o,
	input logic [WIDTH-1:0] instr_addr_i,

	output logic [WIDTH-1:0] data_rdata_o,
	input logic data_req_i,
	input logic data_we_i,
	input logic [3:0] data_be_i,
	input logic [WIDTH-1:0] data_addr_i,
	input logic [WIDTH-1:0] data_wdata_i
);
	logic [WIDTH-1:0] mem [0:RAM_SIZE/4-1];
	logic [WIDTH-1:0] data_int;

	integer ram_index;

	initial begin
		if(RAM_INIT_FILE != "")
			$readmemb(RAM_INIT_FILE, mem);
		else
			for(ram_index = 0; ram_index < (RAM_SIZE / 4 - 1); ram_index++)
				mem[ram_index] = { 32{1'b0} };
	end

	assign instr_rdata_o = mem[(instr_addr_i % RAM_SIZE) / 4];

	always_ff @(posedge clk_i, posedge rst_i) begin
		if(rst_i) begin
			data_rdata_o <= 32'b0;
		end
		else if(data_req_i) begin
			data_rdata_o <= mem[(data_addr_i % RAM_SIZE) / 4];

			if(data_we_i && data_be_i[0])
				mem[data_addr_i[31:2]][7:0] <= data_wdata_i[7:0];

			if(data_we_i && data_be_i[1])
				mem[data_addr_i[31:2]][15:8] <= data_wdata_i[15:8];

			if(data_we_i && data_be_i[2])
				mem[data_addr_i[31:2]][23:16] <= data_wdata_i[23:16];

			if(data_we_i && data_be_i[3])
				mem[data_addr_i[31:2]][31:24] <= data_wdata_i[31:24];

		end
	end

endmodule: riscv_rom
