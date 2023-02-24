`timescale 1ns / 1ps

`include "alu_ops.vh"

module alu
#(
	parameter N = 32
)
(
	input logic [4:0] op,
    input logic signed [N-1:0] a, b,
    output logic signed [N-1:0] result,
    output logic flag
);
    

	always_ff @(*) begin
        unique case(op)
        `ADD: begin
            result = a + b;
            flag = 0;
        end
        `SUB: begin
            result = a - b;
            flag = 0;
        end
        `SLL: begin
            result = a << b[4:0];
            flag = 0;
        end
        `SLT: begin
            result = $signed(a) < $signed(b);
            flag = 0;
        end
        `SLTU: begin
            result = (a) < (b);
            flag = 0;
        end
        `XOR: begin
            result = a ^ b;
            flag = 0;
        end
        `SRL: begin
            result = a >> b[4:0];
            flag = 0;
        end
        `SRA: begin
            result = $signed(a) >>> b[4:0];
            flag = 0;
        end
        `OR: begin
            result = a | b;
            flag = 0;
        end
        `AND: begin
            result = a & b;
            flag = 0;
        end
        `BEQ: begin
            result = 0;
            flag = (a == b);
        end
        `BNE: begin
            result = 0;
            flag = (a != b);
        end
        `BLT: begin
            result = 0;
            flag = $signed(a) > $signed(b);
        end
        `BGE: begin
            result = 0;
            flag = $signed(a) >= $signed(b);
        end
        `BLTU: begin
            result = 0;
            flag = a < b;
        end
        `BGEU: begin
            result = 0;
            flag = a >= b;
        end
        endcase
	end

endmodule: alu

