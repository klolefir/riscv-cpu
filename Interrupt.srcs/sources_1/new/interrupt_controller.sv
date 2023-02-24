`timescale 1ns / 1ps

module interrupt_controller
#(
	parameter WIDTH = 32
)
(
	input logic clk,
	input logic intr_rst,
	input logic [4:0] mie,
	input logic [4:0] intr_req,
	output logic [4:0] intr_fin,
	output logic [4:0] mcause,
	output logic intr
);
	logic [2:0] mcause_num;

	logic flop_mcause_en;

	assign flop_mcause_en = mcause_in;

	/*flopenr flop_mcause
	(
		.clk(clk),
		.rst(intr_rst),
		.en(!flop_mcause_en),
		.d(mcause_num_next),
		.q(mcause_num)
	);*/

   	always_ff @(posedge clk, posedge intr_rst) begin
		if(intr_rst)
			mcause_num <= 0;
		else if(flop_mcause_en == 1)
			mcause_num <= mcause_num;
		else if(mcause_num < 5)
			mcause_num <= mcause_num + 1'd1;
		else
			mcause_num <= 0;
	end

	//assign mcause_num_next = mcause_num + 1;
	assign mcause = mcause_num;

	logic mcause_in, mcause_out;

	logic [4:0] mcause_find;
	/*flopr flop_intr
	(
		.clk(clk),
		.rst(intr_rst),
		.en(1'b0),
		.d(mcause_in),
		.q(mcause_out)
	);*/

	always_ff @(*) begin
		case(mcause_num)
		3'b000: begin
			mcause_find[0] <= (mie[0] && intr_req[0]);
			intr_fin[0] <= mcause_find[0] && intr_rst;
		end
		3'b001: begin
			mcause_find[1] <=  (mie[1] && intr_req[1]);
			intr_fin[1] <= mcause_find[1] && intr_rst;
		end
		3'b010: begin
			mcause_find[2] <= (mie[2] && intr_req[2]);
			intr_fin[2] <= mcause_find[2] && intr_rst;
		end
		3'b011: begin
			mcause_find[3] <= (mie[3] && intr_req[3]);
			intr_fin[3] <= mcause_find[3] && intr_rst;
		end
		3'b100: begin
			mcause_find[4] <= (mie[4] && intr_req[4]);
			intr_fin[4] <= mcause_find[4] && intr_rst;
		end
		default: begin

		end
		endcase
	   	mcause_in <= mcause_find[0] || mcause_find[1] || mcause_find[2] || mcause_find[3] || mcause_find[4];
	end
		
   always_ff @(posedge clk, posedge intr_rst) begin
	   if(intr_rst)
		   mcause_out <= 0;
	   else if(flop_mcause_en)
		   mcause_out <= mcause_in;
	   else
		   mcause_out <= 0;
   end

	assign intr = mcause_in ^ mcause_out;

endmodule




/*for(int i = 0; i <= 31; i++) begin
			mcause_find[i] = mcause_num && (mie[i] && intr_req[i]); 
		end
		for(int i = 0; i < 31; i++) begin
			mcause_in = mcause_find[i] || mcause_find[i + 1];
		end
		for(int i = 0; i < 31; i++) begin
			intr_fin[i] = mcause_find[i] && intr_rst;
		end*/
		/*for(int i = 0; i < 4; i++) begin
			mcause_in = mcause_find[i] || mcause_find[i + 1];
		end
		for(int i = 0; i < 31; i++) begin
			intr_fin[i] = mcause_find[i] && intr_rst;
		end*/
/*
	//always_ff @(*) begin
	always_comb begin
		mcause_find = 5'b00000;
		intr_fin = 5'b00000;
		case(mcause_num)
		3'b000: begin
			mcause_find[0] = (mie[0] && intr_req[0]);
			intr_fin[0] = mcause_find[0] && intr_rst;
		end
		3'b001: begin
			mcause_find[1] =  (mie[1] && intr_req[1]);
			intr_fin[1] = mcause_find[1] && intr_rst;
		end
		3'b010: begin
			mcause_find[2] = (mie[2] && intr_req[2]);
			intr_fin[2] = mcause_find[2] && intr_rst;
		end
		3'b011: begin
			mcause_find[3] = (mie[3] && intr_req[3]);
			intr_fin[3] = mcause_find[3] && intr_rst;
		end
		3'b100: begin
			mcause_find[4] = (mie[4] && intr_req[4]);
			intr_fin[4] = mcause_find[4] && intr_rst;
		end
		endcase
	   	mcause_in = mcause_find[0] || mcause_find[1] || mcause_find[2] || mcause_find[3] || mcause_find[4];
			end*/


