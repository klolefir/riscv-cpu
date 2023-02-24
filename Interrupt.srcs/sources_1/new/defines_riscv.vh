`ifndef DEFINES_RISCV_SENTRY_VH
`define DEFINES_RISCV_SENTRY_VH

//IMM EXTEND TYPE
`define IMM_I_EXT 3'b000
`define IMM_S_EXT 3'b001
`define IMM_B_EXT 3'b010
`define IMM_J_EXT 3'b011
`define IMM_U_EXT 3'b100

`define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  5

`define ALU_ADD   5'b00000
`define ALU_SUB   5'b01000

`define ALU_XOR   5'b00100
`define ALU_OR    5'b00110
`define ALU_AND   5'b00111

// shifts
`define ALU_SRA   5'b01101
`define ALU_SRL   5'b00101
`define ALU_SLL   5'b00001

// comparisons
`define ALU_LTS   5'b11100
`define ALU_LTU   5'b11110
`define ALU_GES   5'b11101
`define ALU_GEU   5'b11111
`define ALU_EQ    5'b11000
`define ALU_NE    5'b11001

// set lower than operations
`define ALU_SLTS  5'b00010
`define ALU_SLTU  5'b00011

// opcodes
`define LOAD_OPCODE      5'b00_000
`define MISC_MEM_OPCODE  5'b00_011
`define OP_IMM_OPCODE    5'b00_100
`define AUIPC_OPCODE     5'b00_101
`define STORE_OPCODE     5'b01_000
`define OP_OPCODE        5'b01_100
`define LUI_OPCODE       5'b01_101
`define BRANCH_OPCODE    5'b11_000
`define JALR_OPCODE      5'b11_001
`define JAL_OPCODE       5'b11_011
`define SYSTEM_OPCODE    5'b11_100

// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

// operand a selection
`define OP_A_RS1         2'b00
`define OP_A_CURR_PC     2'b01
`define OP_A_ZERO        2'b10

// operand b selection
`define OP_B_RS2         3'b000
`define OP_B_IMM_I       3'b001
`define OP_B_IMM_U       3'b010
`define OP_B_IMM_S       3'b011
`define OP_B_INCR        3'b100

// writeback source selection
`define WB_EX_RESULT     1'b0
`define WB_LSU_DATA      1'b1

`define JALR_FUNC 3'B000

`define BEQ_FUNC 3'B000
`define BNE_FUNC 3'B001
`define BLT_FUNC 3'B100
`define BGE_FUNC 3'B101
`define BLTU_FUNC 3'B110
`define BGEU_FUNC 3'B111

`define LB_FUNC 3'B000
`define LH_FUNC 3'B001
`define LW_FUNC 3'B010
`define LBU_FUNC 3'B100
`define LHU_FUNC 3'B101

`define SB_FUNC 3'B000
`define SH_FUNC 3'B001
`define SW_FUNC 3'B010

`define ADDI_FUNC 3'B000
`define XORI_FUNC 3'B100
`define ORI_FUNC 3'B0_110
`define ANDI_FUNC 3'B111
`define SLLI_FUNC 10'B0000000_001
`define SRLI_FUNC 10'B0000000_101
`define SRAI_FUNC 10'B0100000_101
`define SLTI_FUNC 3'B010
`define SLTIU_FUNC 3'B011

`define ADD_FUNC 10'B0000000_000
`define SUB_FUNC 10'B0100000_000
`define SLL_FUNC 10'B0000000_001
`define SLT_FUNC 10'B0000000_010
`define SLTU_FUNC 10'B0000000_011
`define XOR_FUNC 10'B0000000_100
`define SRL_FUNC 10'B0000000_101
`define SRA_FUNC 10'B0100000_101
`define OR_FUNC 10'B0000000_110
`define AND_FUNC 10'B0000000_111

`define MRET_FUNC 3'B000
`define CSRRW_FUNC 3'B001
`define CSRRS_FUNC 3'B010
`define CSRRC_FUNC 3'B011

`endif
