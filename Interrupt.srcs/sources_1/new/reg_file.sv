`timescale 1ns / 1ps

module reg_file
#(
	parameter WIDTH = 32, ADR_BUS_WIDTH = 32, ADR_WIDTH = 5
)
(
	input logic clk, we,
	input logic [ADR_WIDTH-1:0] adr1, adr2, adr_wd,
	input logic signed [WIDTH-1:0] din,
	output logic signed [WIDTH-1:0] dout1, dout2
);
	logic [WIDTH-1:0] mem [ADR_BUS_WIDTH-1:0];

	always @(posedge clk)
		if(we) mem[adr_wd] <= din;
	
	always_comb begin
		dout1 = (adr1 != 0) ? mem[adr1] : 0;
		dout2 = (adr2 != 0) ? mem[adr2] : 0;
	end

endmodule: reg_file


