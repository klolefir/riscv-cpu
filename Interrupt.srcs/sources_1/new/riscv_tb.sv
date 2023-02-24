`timescale 1ns / 1ps

module riscv_tb;
	parameter WIDTH = 32;
	parameter HF_CYCLE = 2.5;
	parameter RST_WAIT = 1.125;
	parameter RAM_SIZE = 8048; 
	
	logic clk;
	logic rst;

	logic [4:0] intr_req;
	logic [4:0] intr_fin;

	riscv_top
	#(
		.RAM_SIZE(RAM_SIZE),
		.RAM_INIT_FILE("riscv_test.mem")
	) dut
	(
		.clk_i(clk),
		.rst_i(rst),
		.intr_req(intr_req),
		.intr_fin(intr_fin)	
	);

	initial begin
		clk = 1'b0;
		dut.riscv_int.mcause_num = 0;
		dut.riscv_int.intr = 0;
		rst = 1'b0;
		dut.intr_rst = 1'b0;
		#RST_WAIT;
		rst = 1'b1;
		dut.intr_rst = 1'b1;
		#RST_WAIT;
		rst = 1'b0;
		dut.intr_rst = 1'b0;
	end

	initial begin
		integer i = 0;
		forever begin
			@(posedge clk);
			/*$display($time, " pc = %1d, alu_res = %1d, int = %1d, mcause = %1d, instr = %1b, jalr = %1b",  dut.core.riscv_datapath.pc, dut.core.riscv_datapath.alu_result, dut.riscv_int.intr, dut.riscv_int.mcause, dut.core.riscv_datapath.instr, dut.core.riscv_decoder.jalr_o);
			$display($time, " imm_S = %1d, imm_I = %1d", dut.core.riscv_datapath.imm_S, dut.core.riscv_datapath.imm_I);
			
			$display($time, " alu_var1 = %1d, alu_var2 = %1d", dut.core.riscv_datapath.alu_var1, dut.core.riscv_datapath.alu_var2);
			$display($time, " rs1 = %1d, rs2 = %1d, rd = %1d", dut.core.riscv_datapath.reg_rd1, dut.core.riscv_datapath.reg_rd2, dut.core.riscv_datapath.reg_wd);
			$display($time, " rs1_adr = %1d, rs2_adr = %1d, rd_adr = %1d", dut.core.riscv_datapath.reg_adr_rd1, dut.core.riscv_datapath.reg_adr_rd2, dut.core.riscv_datapath.reg_adr_wd);
			$display($time, " csr_rd = %1d, csr_in = %1d, csr_op = %1b, en_mcause = %1d, csr_mcause_in = %1d, csr_mcause_out = %1d, csr_mepc = %1d", dut.core.riscv_datapath.riscv_csr.rd, dut.core.riscv_datapath.riscv_csr.csr_in, dut.core.riscv_datapath.riscv_csr.op, dut.core.riscv_datapath.riscv_csr.en_mcause, dut.core.riscv_datapath.riscv_csr.mcause_in, dut.core.riscv_datapath.riscv_csr.mcause_out, dut.core.riscv_datapath.riscv_csr.mepc);
			$display($time, " alu_flag = %1d", dut.core.riscv_datapath.alu_flag);
			$display($time, " intr_rst = %1b, mcause_find = %1b", dut.riscv_int.intr_rst, dut.riscv_int.mcause_find);
			i++;
			if(i == 20)
				intr_req = 5'b10000;
			if(i == 50)
				$stop;*/

		end
	end

	always begin
		integer i = 0;
		//$monitor($time, " instr = %1b, alu_var1 = %1d, alu_val2 = %1d, alu_result = %1d, pc = %1d, pc_next = %1d, mem_wdata = %1d, mem_rdata = %1d, lsu_addr_i = %1d, lsu_data_i = %1d", dut.core.riscv_datapath.instr, dut.core.riscv_datapath.alu_var1, dut.core.riscv_datapath.alu_var2, dut.core.riscv_datapath.alu_result, dut.core.riscv_datapath.pc, dut.core.riscv_datapath.pc_next, dut.rom.data_wdata_i, dut.rom.data_rdata_o, dut.core.riscv_datapath.riscv_lsu.lsu_addr_i, dut.core.riscv_datapath.riscv_lsu.lsu_data_i);
		//$monitor($time, " intr_req = %1d, intr_fin = %1d", intr_req, intr_fin);
		//$monitor($time, " intr_mcause_num = %1d, alu_flag = %1d, csr_op = %1b, csr_ in = %1d, mie_in = %1d, en = %1d, en_mie = %1d, csr_addr = %1h, csr_op_o =  %1b, instr = %1b, mscratch = %1d, rs1 = %1d, rs2 = %1d, rd = %1d\n       intr_req = %1d, intr_fin = %1d", dut.riscv_int.mcause_num, dut.core.riscv_datapath.alu_flag, dut.core.riscv_datapath.riscv_csr.op, dut.core.riscv_datapath.riscv_csr.csr_in, dut.core.riscv_datapath.riscv_csr.mie_in, dut.core.riscv_datapath.riscv_csr.en, dut.core.riscv_datapath.riscv_csr.en_mie, dut.core.riscv_datapath.riscv_csr.addr, dut.core.riscv_decoder.csr_op_o, dut.core.riscv_datapath.instr, dut.core.riscv_datapath.riscv_csr.mscratch_out, dut.core.riscv_datapath.reg_rd1, dut.core.riscv_datapath.reg_rd2, dut.core.riscv_datapath.reg_wd, intr_req, intr_fin);

		//$display($time, "rs1 = %1d, rs2 = %1d, rd = %1d", dut.core.riscv_datapath.reg_rd1, dut.core.riscv_datapath.reg_rd2, dut.core.riscv_datapath.reg_wd);

		#HF_CYCLE;
		clk = ~clk;
		if(dut.core.illegal_instr_o == 1)
			$stop;
	end

endmodule: riscv_tb
