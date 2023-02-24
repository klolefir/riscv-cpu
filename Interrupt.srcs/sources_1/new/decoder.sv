`timescale 1ns / 1ps

`include "defines_riscv.vh"

module decoder_riscv
(
	input [31:0] fetched_instr_i,
	input logic lsu_stall_req_o,
	//new(interrupt)
	input reg int_i,

	output reg [1:0] ex_op_a_sel_o,
	output reg [2:0] ex_op_b_sel_o,
	output reg [4:0] alu_op_o,
	output reg mem_req_o,
	output reg mem_we_o,
	output reg [2:0] mem_size_o,
	output reg gpr_we_a_o,
	output reg wb_src_sel_o,
	output reg illegal_instr_o,
	output reg branch_o,
	output reg jal_o,
	output reg [1:0] jalr_o,
	output reg enpc,
	//new(interrupt)
	output reg int_rst_o,
	output reg csr_o,
	output reg [2:0] csr_op_o
);
	logic [4:0] op_code;
	logic [2:0] func3;
	logic [6:0] func7;
	logic [4:0] rd, rs1, rs2;
	assign op_code = fetched_instr_i[6:2];
	assign func7 = fetched_instr_i[31:25];
	assign func3 = fetched_instr_i[14:12];

	always_comb begin
		ex_op_a_sel_o = 0;
		ex_op_b_sel_o = 0;
		alu_op_o = 0;
		mem_req_o = 0;
		mem_we_o = 0;
		mem_size_o = 0;
		gpr_we_a_o = 0;
		wb_src_sel_o = 0;
		branch_o = 0;
		jal_o = 0;
		jalr_o = 0;
		illegal_instr_o = 0;
		enpc = 0;
		//new(interrupt)
		int_rst_o = 0;
		csr_o = 0;
		csr_op_o = 3'b000;

		if(int_i) begin
			csr_op_o = 3'b100;	
			jalr_o = 2'b11;
		end
		else begin

		end

		case(op_code)
		`OP_OPCODE: begin
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load alu result in reg_file
			wb_src_sel_o = `WB_EX_RESULT;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_RS1;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_RS2;
			//select alu operation
			if({ func7, func3 } == `ADD_FUNC)
				alu_op_o = `ALU_ADD; 
			else if({ func7, func3 } == `SUB_FUNC)
				alu_op_o = `ALU_SUB; 
			else if({ func7, func3 } == `XOR_FUNC)
				alu_op_o = `ALU_XOR; 
			else if({ func7, func3 } == `OR_FUNC)
				alu_op_o = `ALU_OR;
			else if({ func7, func3 } == `AND_FUNC)
				alu_op_o = `ALU_AND;
			else if({ func7, func3 } == `SRA_FUNC)
				alu_op_o = `ALU_SRA;
			else if({ func7, func3 } == `SRL_FUNC)
				alu_op_o = `ALU_SRL;
			else if({ func7, func3 } == `SLL_FUNC)
				alu_op_o = `ALU_SLL;
			else if({ func7, func3 } == `SLT_FUNC)
				alu_op_o = `ALU_SLTS;
			else if({ func7, func3 } == `SLTU_FUNC)
				alu_op_o = `ALU_SLTU;
			else
				illegal_instr_o = 1;
		end
		`OP_IMM_OPCODE: begin
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load alu result in reg_file
			wb_src_sel_o = `WB_EX_RESULT;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_RS1;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_IMM_I;
			//select alu operation
			if(func3 == `ADDI_FUNC)
				alu_op_o = `ALU_ADD; 
			else if(func3 == `XORI_FUNC)
				alu_op_o = `ALU_XOR; 
			else if(func3 == `ORI_FUNC)
				alu_op_o = `ALU_OR;
			else if(func3 == `ANDI_FUNC)
				alu_op_o = `ALU_AND;
			else if({ func7, func3 } == `SRAI_FUNC)
				alu_op_o = `ALU_SRA;
			else if({ func7, func3 } == `SRLI_FUNC)
				alu_op_o = `ALU_SRL;
			else if({ func7, func3 } == `SLLI_FUNC)
				alu_op_o = `ALU_SLL;
			else if(func3 == `SLTI_FUNC)
				alu_op_o = `ALU_SLTS;
			else if(func3 == `SLTIU_FUNC)
				alu_op_o = `ALU_SLTU;
			else
				illegal_instr_o = 1;

		end
		`LUI_OPCODE: begin
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load alu result in reg_file
			wb_src_sel_o = `WB_EX_RESULT;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_ZERO;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_IMM_U;
			//select alu operation
			alu_op_o = `ALU_ADD; 
	
		end
		`LOAD_OPCODE: begin
			//load data->reg settings
			mem_req_o = 1;
			mem_we_o = 0;
			if(func3 == `LDST_B) 
				mem_size_o = `LDST_B;
			else if(func3 == `LDST_H)
				mem_size_o = `LDST_H;
			else if(func3 == `LDST_W)
				mem_size_o = `LDST_W;
			else if(func3 == `LDST_BU) 
				mem_size_o = `LDST_BU;
			else if(func3 == `LDST_HU)
				mem_size_o = `LDST_HU;
			else
				illegal_instr_o = 1;
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load data in reg_file
			wb_src_sel_o = `WB_LSU_DATA;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_RS1;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_IMM_I;
			//select alu operation
			alu_op_o = `ALU_ADD; 
		//	enpc = 1;
		//	#10;
			//enpc = lsu_stall_req_o;
		end
		`STORE_OPCODE: begin 
		//load reg->data settings
			mem_req_o = 1;
			mem_we_o = 1;
			if(func3 == `LDST_B) 
				mem_size_o = `LDST_B;
			else if(func3 == `LDST_H)
				mem_size_o = `LDST_H;
			else if(func3 == `LDST_W)
				mem_size_o = `LDST_W;
			else
				illegal_instr_o = 1;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_RS1;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_IMM_S;
			//select alu operation
			alu_op_o = `ALU_ADD;
			//enpc
		//	enpc = 1;
		//	#10;
			//enpc = lsu_stall_req_o;
		end
		`BRANCH_OPCODE: begin
			//select first alu operand
			ex_op_a_sel_o = `OP_A_RS1;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_RS2;
			//select alu operation
			if(func3 == `BEQ_FUNC)
				alu_op_o = `ALU_EQ; 
			else if(func3 == `BNE_FUNC)
				alu_op_o = `ALU_NE; 
			else if(func3 == `BLT_FUNC)
				alu_op_o = `ALU_LTS;
			else if(func3 == `BGE_FUNC)
				alu_op_o = `ALU_GES;
			else if(func3 == `BLTU_FUNC)
				alu_op_o = `ALU_LTU;
			else if(func3 == `BGEU_FUNC)
				alu_op_o = `ALU_GEU;
			else
				illegal_instr_o = 1;
			//branch jump
			branch_o = 1;
		end
		`JAL_OPCODE: begin
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load alu result in reg_file
			wb_src_sel_o = `WB_EX_RESULT;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_CURR_PC;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_INCR;
			//select alu operation
			alu_op_o = `ALU_ADD; 
			//jump and link
			jal_o = 1;	
		end
		`JALR_OPCODE: begin
			if(func3 == `JALR_FUNC) begin
				//permission to load in reg_file
				gpr_we_a_o = 1;
				//mux load alu result in reg_file
				wb_src_sel_o = `WB_EX_RESULT;
				//select first alu operand
				ex_op_a_sel_o = `OP_A_CURR_PC;
				//select second alu operand
				ex_op_b_sel_o = `OP_B_INCR;
				//select alu operation
				alu_op_o = `ALU_ADD; 
				//jump and link reg
				jalr_o = 1;	
			end
			else
				illegal_instr_o = 1;
		end
		`AUIPC_OPCODE: begin
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load alu result in reg_file
			wb_src_sel_o = `WB_EX_RESULT;
			//select first alu operand
			ex_op_a_sel_o = `OP_A_CURR_PC;
			//select second alu operand
			ex_op_b_sel_o = `OP_B_IMM_U;
			//select alu operation
			alu_op_o = `ALU_ADD; 
	
		end
		`MISC_MEM_OPCODE: begin
			illegal_instr_o = 0;
		end
		`SYSTEM_OPCODE: begin
			//permission to load in reg_file
			gpr_we_a_o = 1;
			//mux load alu result in reg_file
			wb_src_sel_o = `WB_EX_RESULT;

			if(func3 == `MRET_FUNC) begin
				jalr_o = 2'b10;
				int_rst_o = 1;
			end
			else if(func3 == `CSRRW_FUNC) begin
				csr_op_o = 3'b001;
				csr_o = 1;
			end
			else if(func3 == `CSRRC_FUNC) begin
				csr_op_o = 3'b010;
				csr_o = 1;
			end
			else if(func3 == `CSRRS_FUNC) begin
				csr_op_o = 3'b011;
				csr_o = 1;
			end
			else
				illegal_instr_o = 1;
		end
		default: begin
			illegal_instr_o = 1;
		end
		endcase

		if(fetched_instr_i[1:0] != 2'b11) begin
			illegal_instr_o = 1;
		end
	end

endmodule: decoder_riscv
