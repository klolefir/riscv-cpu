`timescale 1ns / 1ps

`include "defines_riscv.vh"

module datapath
#(
	parameter WIDTH = 32, REG_ADR_WIDTH = 5, ALU_OP_WIDTH = 5 
)
(
	input logic clk_i, rst_i,
	input logic signed [WIDTH-1:0] ext_data,
	output logic [WIDTH-1:0] pc,
	input logic [WIDTH-1:0] instr,

	//from decoder
	input logic [1:0] ex_op_a_sel_o,
	input logic [2:0] ex_op_b_sel_o,
	input logic [4:0] alu_op_o,
	input logic mem_req_o,
	input logic mem_we_o,
	input logic [2:0] mem_size_o,
	input logic gpr_we_a_o,
	input logic wb_src_sel_o,
	input logic illegal_instr_o,
	input logic branch_o,
	input logic jal_o,
	input logic [1:0] jalr_o,
	input logic enpc,
	//new(interrupt)
	input logic [2:0] csr_op_o,
	input logic csr_o,

	//from int controller
	//input logic [WIDTH-1:0] int_mcause,
	input logic [2:0] int_mcause,
	//for int controller
	//output logic [WIDTH-1:0] int_mie,
	output logic [4:0] int_mie,
	
	//for LSU
	input logic lsu_stall_req_o,
	input logic [WIDTH-1:0] data_rdata_i,
	output logic data_req_o,
	output logic data_we_o,
	output logic [3:0] data_be_o,
	output logic [WIDTH-1:0] data_addr_o,
	output logic [WIDTH-1:0] data_wdata_o
);
	//reg variables
	logic signed [WIDTH-1:0] reg_rd1, reg_rd2, reg_wd;
	logic [REG_ADR_WIDTH-1:0] reg_adr_rd1, reg_adr_rd2, reg_adr_wd; 
	//pconunter variables
	logic signed [WIDTH-1:0] pc_next, pc_increase;
	//alu variables
	logic signed [WIDTH-1:0] alu_result, alu_var1, alu_var2;
	logic alu_flag;
	logic [ALU_OP_WIDTH-1:0] alu_op;

	//imm variables
	logic signed [WIDTH-1:0] imm_I;
	logic signed [WIDTH-1:0] imm_S;
	logic signed [WIDTH-1:0] imm_J;
	logic signed [WIDTH-1:0] imm_B;
	logic signed [WIDTH-1:0] imm_U;

	//lsu variables
	logic lsu_we_i;
	logic [2:0] lsu_size_i;
	logic [WIDTH-1:0] lsu_data_i;
	logic lsu_req_i;
	logic [WIDTH-1:0] lsu_data_o;

	//CSR variables
	//logic [WIDTH-1:0] csr_mie, csr_mtvec, csr_mcause, csr_mepc, csr_rd, csr_wd;
	logic [WIDTH-1:0] csr_mtvec, csr_mepc, csr_rd, csr_wd;
	logic [2:0] csr_mcause;
	logic [4:0] csr_mie;
	logic [11:0] csr_addr;

	assign csr_addr = instr[31:20];
	assign csr_wd = reg_rd1;
	assign csr_mcause = int_mcause;
	assign int_mie = csr_mie;

	//CSR
	csr_riscv riscv_csr
	(
		.clk(clk_i),
		.rst(rst_i),
		.wd(csr_wd),
		.op(csr_op_o),
		.addr(csr_addr),
		.pc(pc),
		.mcause(csr_mcause),
		.mie(csr_mie),
		.mtvec(csr_mtvec),
		.mepc(csr_mepc),
		.rd(csr_rd)
	);

	//LSU
	riscv_lsu riscv_lsu
	(
		.clk_i(clk_i),
		.arst_i(rst_i),
		//.lsu_addr_i(lsu_addr_i),
		.lsu_addr_i(alu_result),
		.lsu_we_i(lsu_we_i),
		.lsu_size_i(lsu_size_i),
		.lsu_data_i(lsu_data_i),
		.lsu_req_i(lsu_req_i),
		.lsu_stall_req_o(lsu_stall_req_o),
		.lsu_data_o(lsu_data_o),
		.*
	);

	assign lsu_req_i = mem_req_o;
	assign lsu_we_i = mem_we_o;
	assign lsu_data_i = reg_rd2;
	assign lsu_size_i = mem_size_o;


	//Program Counter
	flopr riscv_pcounter
	(
		.clk(clk_i),
		.rst(rst_i),
		.en(enpc),
		.d(pc_next),
		.q(pc)
	);

	//Reg File
	reg_file riscv_rf
	(
		.clk(clk_i),
		.we(gpr_we_a_o), 
		.adr1(reg_adr_rd1), 
		.adr2(reg_adr_rd2), 
		.adr_wd(reg_adr_wd), 
		.din(reg_wd), 
		.dout1(reg_rd1), 
		.dout2(reg_rd2)
	);
	
	//ALU
	alu riscv_alu
	(
		.op(alu_op_o),
		.a(alu_var1),
		.b(alu_var2),
		.result(alu_result),
		.flag(alu_flag)
	);

	//imm extend(new)
	always_comb begin
		imm_I = { {20{instr[31]}}, instr[31:20] };
		imm_S = { {20{instr[31]}}, instr[31:25], instr[11:7] };
		imm_J = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
		imm_B = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
		imm_U = { instr[31:12], {12{0}} };
	end
	
	//ALU ZONE
	always_comb begin
		case(ex_op_a_sel_o)
		`OP_A_RS1:
			alu_var1 = reg_rd1;
		`OP_A_CURR_PC:
			alu_var1 = pc;
		`OP_A_ZERO:
			alu_var1 = 0;
		default: begin
			alu_var1 = 0;
		end
		endcase

		case(ex_op_b_sel_o)
		`OP_B_RS2: 
			alu_var2 = reg_rd2;
		`OP_B_IMM_I:
			alu_var2 = imm_I;
		`OP_B_IMM_U:
			alu_var2 = imm_U;
		`OP_B_IMM_S:
			alu_var2 = imm_S;
		`OP_B_INCR:
			alu_var2 = 4; 
		default: begin
			alu_var2 = 0;
		end
		endcase

	end

	//REG_FILE ZONE
	always_comb begin
		reg_adr_rd1 = instr[19:15];
		reg_adr_rd2 = instr[24:20];
		reg_adr_wd = instr[11:7];
	end

	//update(interrupt)
	always_comb begin
		case(wb_src_sel_o)
		`WB_EX_RESULT:
			reg_wd = (csr_o == 1) ? csr_rd : alu_result;
		`WB_LSU_DATA:
			reg_wd = (csr_o == 1) ? csr_rd : lsu_data_o;
		default: begin
			reg_wd = 0;
		end
		endcase
	end


	//PCOUNTER ZONE
	logic signed [31:0] imm_choise;	

	always_comb begin
		case(branch_o)
		1'b0:
			imm_choise = imm_J;
		1'b1:
			imm_choise = imm_B;
		default: begin
			imm_choise = 0;
		end
		endcase

		if(jal_o || (branch_o && alu_flag))
			pc_increase = imm_choise;
		else
			pc_increase = 4;
	end


	always_comb begin
		if(lsu_stall_req_o)
			pc_next = pc;
		else
			case(jalr_o)
			2'b00:
				pc_next = pc + pc_increase;
			2'b01:
				pc_next = reg_rd1 + imm_I;
			2'b10:
				pc_next = csr_mepc;
			2'b11:
				pc_next = csr_mtvec;
			default: 
				pc_next = 0;
			endcase
	end
		
endmodule: datapath
