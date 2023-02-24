`timescale 1ns / 1ps

`include "defines_riscv.vh"

module riscv_lsu
#(
	parameter WIDTH = 32
)
(
	input logic clk_i,
	input logic arst_i,

	input logic [WIDTH-1:0] lsu_addr_i,
	input logic lsu_we_i,
	input logic [2:0] lsu_size_i,
	input logic [WIDTH-1:0] lsu_data_i,
	input logic lsu_req_i,
	output logic lsu_stall_req_o,
	output logic [WIDTH-1:0] lsu_data_o,

	input logic [WIDTH-1:0] data_rdata_i,
	output logic data_req_o,
	output logic data_we_o,
	output logic [3:0] data_be_o,
	output logic [WIDTH-1:0] data_addr_o,
	output logic [WIDTH-1:0] data_wdata_o
);

	typedef enum logic [1:0] {
		IDLE, WORK, DONE, IDLE_2
	} state_type;
	state_type state, next_state;

	logic [3:0] tmp_be_o;
	//byte offset
	//assign tmp_bo = lsu_addr_i[11:10];
	logic [1:0] tmp_bo;
	assign tmp_bo = lsu_addr_i[1:0];
	//assign tmp_bo = 2'b00;

	//assign data_req_o = lsu_req_i && (state == WORK); 
	//assign data_addr_o = (state == DONE) ? lsu_addr_i : 32'bx;
	always_comb begin
		if(lsu_req_i && !lsu_we_i)
			data_addr_o = lsu_addr_i;
		else if(lsu_req_i && lsu_we_i)
			data_addr_o = lsu_addr_i;
		else
			data_addr_o = 32'bx;
	end
	//assign data_addr_o = lsu_addr_i;

	//assign data_addr_o = (lsu_addr_i << 2);

	//byte enable select
	always_comb begin
		if(lsu_we_i)
			case(lsu_size_i)
			`LDST_B: begin
				if(tmp_bo == 2'b00)
					data_be_o = 4'b0001;
				else if(tmp_bo == 2'b01)
					data_be_o = 4'b0010;
				else if(tmp_bo == 2'b10)
					data_be_o = 4'b0100;
				else if(tmp_bo == 2'b11)
					data_be_o = 4'b1000;
				else
					data_be_o = 4'b0;
			end
			`LDST_H: begin
				if(tmp_bo == 2'b00)
					data_be_o = 4'b0011;
				else if(tmp_bo == 2'b10)
					data_be_o = 4'b1100;
				else
					data_be_o = 4'b0000;
			end
			`LDST_W: begin
				if(tmp_bo == 2'b00)
					data_be_o = 4'b1111;
				else
					data_be_o = 4'b0000;
			end
			default: begin
				data_be_o = 4'b0;
			end
			endcase
		else
			data_be_o = 4'b0;
	end

	/*always_comb begin
		case(lsu_size_i)
		`LDST_B:
			lsu_data_o = { { 24{tmp_rdata[7]}}, tmp_rdata[7:0] };	
		`LDST_H:
			lsu_data_o = { { 16{tmp_rdata[7]}}, tmp_rdata[15:0] };	
		`LDST_W:
			lsu_data_o = tmp_rdata;
		`LDST_BU:
			lsu_data_o = { 24'b0, tmp_rdata[7:0] };	
		`LDST_HU:
			lsu_data_o = { 16'b0, tmp_rdata[15:0] };	
		endcase
	end*/

	logic done;
	assign done = (state == WORK) | (!lsu_req_i);
	assign lsu_stall_req_o = ~done;

	//assign data_we_o = (state == WORK) && (lsu_req_i);
	//assign data_req_o = (state == WORK) && (lsu_req_i);
//	assign data_req_o = (state == DONE) && lsu_req_i;
	//assign data_req_o = lsu_req_i;
//	assign data_we_o = (state == WORK) && (lsu_we_i && lsu_req_i);



	always_comb begin
		if(lsu_req_i && !lsu_we_i) begin
			data_req_o = (state == DONE);
			data_we_o = 0;
		end
		else if(lsu_req_i && lsu_we_i) begin
			data_req_o = (state == WORK);
			data_we_o = 1;
		end
		else begin
			data_req_o = 0;
			data_we_o = 0;
		end
	end
	


	always_ff @(posedge state) begin
		if(arst_i) begin
			lsu_data_o <= 0;
		end
		else begin
			if(lsu_req_i && !lsu_we_i) begin
				if(state == WORK) begin
					case(lsu_size_i)
					`LDST_B: begin
						if(tmp_bo == 2'b00)
							lsu_data_o <= { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
						else if(tmp_bo == 2'b01)
							lsu_data_o <= { {24{data_rdata_i[15]}}, data_rdata_i[15:8] };
						else if(tmp_bo == 2'b10)
							lsu_data_o <= { {24{data_rdata_i[23]}}, data_rdata_i[23:16] };
						else if(tmp_bo == 2'b11)
							lsu_data_o <= { {24{data_rdata_i[31]}}, data_rdata_i[31:24] };
						else
							lsu_data_o <= 32'b0;
					end
					`LDST_H: begin
						if(tmp_bo == 2'b00)
							lsu_data_o <= { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
						else if(tmp_bo == 2'b10)
							lsu_data_o <= { {16{data_rdata_i[31]}}, data_rdata_i[31:16] };
						else
							lsu_data_o <= 32'b0;
					end
					`LDST_W: begin
						if(tmp_bo == 2'b00)
							lsu_data_o <= data_rdata_i[31:0];
						else
							lsu_data_o <= 32'b0;
					end
					`LDST_BU: begin
						if(tmp_bo == 2'b00)
							lsu_data_o <= { 24'b0, data_rdata_i[7:0] };
						else if(tmp_bo == 2'b01)
							lsu_data_o <= { 24'b0, data_rdata_i[15:8] };
						else if(tmp_bo == 2'b10)
							lsu_data_o <= { 24'b0, data_rdata_i[23:16] };
						else if(tmp_bo == 2'b11)
							lsu_data_o <= { 24'b0, data_rdata_i[31:24] };
						else
							lsu_data_o <= 32'b0;
					end
					`LDST_HU: begin
						if(tmp_bo == 2'b00)
							lsu_data_o <= { 16'b0, data_rdata_i[15:0] };
						else if(tmp_bo == 2'b10)
							lsu_data_o <= { 16'b0, data_rdata_i[31:16] };
						else
							lsu_data_o <= 32'b0;
					end
					default: begin
						lsu_data_o <= 0;
					end
					endcase
				end
			end
			else begin
				lsu_data_o <= 0;
			end
		end
	end

	always_ff @(posedge clk_i) begin
		if(arst_i) begin
			data_wdata_o <= 0;
		end

		if(lsu_req_i && lsu_we_i) begin
			if(state == DONE) begin
				case(lsu_size_i) 
				`LDST_B:
					data_wdata_o <= { 4{lsu_data_i[7:0]} };
				`LDST_H:
					data_wdata_o <= { 2{lsu_data_i[15:0]} };
				`LDST_W:
					data_wdata_o <= lsu_data_i[31:0];
				default:
					data_wdata_o <= 32'b0;
				endcase
			end
		end
		else begin
			data_wdata_o <= 32'b0;
		end	
	end

	always_comb begin
		case(state)
		/*IDLE: begin
				//next_state = WORK;
			next_state = WORK;
		end*/
		WORK: begin
			if(lsu_req_i) begin
				//next_state = DONE;
				/*lsu_stall_req_o = 1;
				* data_req_o = 1;
				data_we_o = 1;*/

				next_state = DONE;
			end
			else if(!lsu_req_i) begin
				//next_state = IDLE;
				//state = DONE;
				next_state = DONE;
			end
			else begin
				//next_state = IDLE;
				//state = DONE;
				next_state = DONE;
			end
		end
		/*IDLE: begin
			next_state = WORK;
		end
		IDLE_2: begin
			next_state = WORK;
		end*/
		DONE: begin
			/*if(lsu_req_i)
				next_state = WORK;
			else
				next_state = DONE;*/
			if(lsu_req_i)
				next_state = WORK;
			/*else if(lsu_req_i && lsu_we_i)
				next_state = IDLE;*/
			else
				next_state = DONE;
		end
		default: begin
			//next_state = IDLE;
			next_state = DONE;
		end
		endcase
	end
	
	always_ff @(posedge clk_i) begin
		if(arst_i) begin
			state <= DONE;
		end
		else begin
			state <= next_state;
		end
	end



		

	/*typedef enum logic [1:0] {
		IDLE, LOW, HIGH, DONE
	} state_type;
	state_type state, next_state;

	logic [WIDTH-1:0] tmp_rdata, tmp_wdata;
	logic [3:0] tmp_be_o;

	assign data_req_o = lsu_req_i && (state == LOW || state == HIGH); assign data_addr_o = (state == LOW || state == HIGH) ? lsu_addr_i : 32'b0;
	assign wdata = (lsu_we_i) ? tmp_wdata : 32'b0;
	assign data_be_o = tmp_be_o;

	always_comb begin
		case(lsu_size_i)
		`LDST_B:
			lsu_data_o =  { { 25{tmp_rdata[7]}}, tmp_rdata[6:0] };	
		`LDST_H:
			lsu_data_o =  { { 17{tmp_rdata[7]}}, tmp_rdata[14:0] };	
		`LDST_W:
			lsu_data_o =  tmp_rdata;
		`LDST_BU:
			lsu_data_o =  { 24'b0, tmp_rdata[7:0] };	
		`LDST_HU:
			lsu_data_o =  { 16'b0, tmp_rdata[15:0] };	
		endcase
	end

	logic done;
	assign done = (state == DONE) | (!lsu_req_i);
	assign lsu_stall_req_o = ~done;


	always_ff @(posedge clk_i) begin
		if(arst_i) begin
			tmp_rdata <= 0;
		end
		else begin
			if(lsu_req_i && !lsu_we_i) begin
				if(state == LOW && ready) begin
					case(lsu_size_i)
					`LDST_B: tmp_rdata[7:0] <= data_rdata_i[7:0];
					`LDST_H:	tmp_rdata[15:0] <= data_rdata_i[15:0];
					`LDST_W: tmp_rdata[31:0] <= data_rdata_i[31:0];
					default: tmp_rdata <= 0;
					endcase
				end
				else if(state == HIGH && ready) begin
					case(lsu_size_i)
					`LDST_B: tmp_rdata[7:0] <= data_rdata_i[7:0];
					`LDST_H:	tmp_rdata[15:0] <= data_rdata_i[15:0];
					`LDST_W: tmp_rdata[31:0] <= data_rdata_i[31:0];
					default: tmp_rdata <= 0;
					endcase
				end
			end
			else begin
				tmp_rdata <= 0;
			end
		end
	end

	always_comb begin
		if(lsu_req_i && lsu_we_i) begin
			if(state == LOW) begin
				case(lsu_size_i) 
				`LDST_B: tmp_wdata[7:0] <= lsu_data_i[7:0];
				`LDST_H:	tmp_wdata[15:0] <= lsu_data_i[15:0];
				`LDST_W: tmp_wdata[31:0] <= lsu_data_i[31:0];
				default: tmp_wdata <= 0;
				endcase
			end
			else if(state == HIGH) begin
				case(lsu_size_i)
				`LDST_B: tmp_wdata[7:0] <= lsu_data_i[7:0];
				`LDST_H:	tmp_wdata[15:0] <= lsu_data_i[15:0];
				`LDST_W: tmp_wdata[31:0] <= lsu_data_i[31:0];
				default: tmp_wdata <= 0;
				endcase
			end
		end
		else begin
			tmp_wdata <= 0;
		end	
	end

	always_comb begin
		if(lsu_req_i && lsu_we_i) begin
			if(state == LOW) begin
				case(lsu_size_i)
				`LDST_B: tmp_be_o <= 4'b1000; 
				`LDST_H: tmp_be_o <= 4'b1100;
				`LDST_W: tmp_be_o <= 4'b1111;
				default: tmp_be_o <= 4'b0000;
				endcase
			end
			else if(state == HIGH) begin
				case(lsu_size_i)
				`LDST_B: tmp_be_o <= 4'b0001; 
				`LDST_H: tmp_be_o <= 4'b0011;
				`LDST_W: tmp_be_o <= 4'b1111;
				default: tmp_be_o <= 4'b0000;
				endcase
			end
			else begin
				tmp_be_o <= 4'b0000;
			end
		end
		else begin
			tmp_be_o <= 4'b0000;
		end
	end


	always_comb begin
		case(state)
		IDLE: begin
			if(lsu_req_i)
				next_state = LOW;
		end
		LOW: begin
			if(ready) begin
				next_state = (lsu_size_i == `LDST_W) ? DONE : HIGH;
			end
			else if(!lsu_req_i) begin
				next_state = IDLE;
			end
		end
		HIGH: begin
			if(ready)
				next_state = DONE;
		end
		DONE: begin
			next_state = IDLE;
		end
		default: begin
			next_state = IDLE;
		end
		endcase
	end
	
	always_ff @(posedge clk_i) begin
		if(arst_i) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end
	*/

	//assign data_req_o = lsu_req_i;
	//assign data_we_o = lsu_we_i;
//	assign data_addr_o = lsu_addr_i;


	/*always_ff @(posedge clk_i, posedge arst_i) begin
		if(arst_i) begin
			lsu_stall_req_o <= 1;
			count <= 0;
		end
		if(lsu_req_i) begin
			if(count == 0) begin
				lsu_stall_req_o <= 0;
				count <= 1;
			end
			else begin
				lsu_stall_req_o <= 1;
				count <= 0;
			end
		end
		else
			lsu_stall_req_o <= 0;
	end*/
/*   	always_ff @(posedge clk_i, posedge arst_i) begin
		if(arst_i)
			lsu_stall_req_o = 0;
		if(lsu_req_i) begin
			lsu_stall_req_o <= !lsu_stall_req_o;
		end
		else
			lsu_stall_req_o <= 0;
	end*/

	/*always_ff @(posedge clk_i) begin
		if(lsu_req_i) begin
			if(lsu_stall_req_o == 1)
				lsu_stall_req_o = 0;
			else if(lsu_stall_req_o == 0)
				lsu_stall_req_o = 1;
			else
				lsu_stall_req_o = 0;
		end
		else
			lsu_stall_req_o = 0;
	end*/

	/*always_comb begin
		if(lsu_stall_req_o == 1)
			count = 0;
		else
			count = 1;
	end*/

	//BAD CODE
	/*always_comb begin
		if(lsu_req_i && (lsu_we_i == 0)) begin
			//lsu_stall_req_o = 1;
			case(lsu_size_i)
			`LDST_B: begin
				if(data_be_o == 4'b0001)
					lsu_data_o = { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
				else if(data_be_o == 4'b0010)
					lsu_data_o = { {24{data_rdata_i[15]}}, data_rdata_i[15:8] };
				else if(data_be_o == 4'b0100)
					lsu_data_o = { {24{data_rdata_i[23]}}, data_rdata_i[23:16] };
				else if(data_be_o == 4'b1000)
					lsu_data_o = { {24{data_rdata_i[31]}}, data_rdata_i[31:24] };
				else
					lsu_data_o = { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
			end
			`LDST_H: begin
				if(data_be_o == 4'b0011)
					lsu_data_o = { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
				else if(data_be_o == 4'b1100)
					lsu_data_o = { {16{data_rdata_i[31]}}, data_rdata_i[31:16] };
				else
					lsu_data_o = { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
			end
			`LDST_W: begin
				if(data_be_o == 4'b1111)
					lsu_data_o = data_rdata_i[31:0];
				else
					lsu_data_o = data_rdata_i[31:0];
			end
			`LDST_BU: begin
				if(data_be_o == 4'b00)
					lsu_data_o = { {24{1'b0}}, data_rdata_i[7:0] };
				else if(data_be_o == 2'b01)
					lsu_data_o = { {24{1'b0}}, data_rdata_i[15:8] };
				else if(data_be_o == 2'b10)
					lsu_data_o = { {24{1'b0}}, data_rdata_i[23:16] };
				else if(data_be_o == 2'b11)
					lsu_data_o = { {24{1'b0}}, data_rdata_i[31:24] };
				else
					lsu_data_o = { {24{1'b0}}, data_rdata_i[7:0] };
			end
			`LDST_HU: begin
				if(data_be_o == 2'b00)
					lsu_data_o = { {16{1'b0}}, data_rdata_i[15:0] };
				else if(data_be_o == 2'b10)
					lsu_data_o = { {16{1'b0}}, data_rdata_i[31:16] };
				else
					lsu_data_o = { {16{1'b0}}, data_rdata_i[15:0] };
			end
			default: begin
				lsu_data_o = 32'bx;
			end
			endcase
		end
	//end

	//always_comb begin
		else if(lsu_we_i && lsu_req_i) begin
			//lsu_stall_req_o = 1;
			case(lsu_size_i)
			`LDST_B: begin
				data_wdata_o = { 4{lsu_data_i[7:0]} };
			end
			`LDST_H: begin
				data_wdata_o = { 2{lsu_data_i[15:0]} };
			end
			`LDST_W: begin
				data_wdata_o = lsu_data_i[31:0];
			end
			default: begin
				data_wdata_o = 32'bx;
			end
			endcase
		end
		else begin
			//lsu_stall_req_o = 0;
		end	
	end*/
endmodule: riscv_lsu
