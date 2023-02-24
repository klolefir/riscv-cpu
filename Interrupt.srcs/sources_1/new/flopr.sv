`timescale 1ns / 1ps

module flopr
#(
	parameter WIDTH = 32
)
(
	input logic clk, rst, en,
	input logic [WIDTH-1:0] d,
	output logic [WIDTH-1:0] q
);
	always_ff @(posedge clk, posedge rst)
		if(rst) begin
			q <= 32'b0;
		end
		else if(!en) begin
			q <= d;
		end

endmodule
