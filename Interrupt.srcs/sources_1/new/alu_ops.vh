`ifndef ALU_OPS_SENTRY_SV
`define ALU_OPS_SENTRY_SV

typedef enum logic [4:0] {
    ADD = 5'b00000,
    SUB = 5'b01000,
    SLL = 5'b00001,
    SLT = 5'b00010,
    SLTU = 5'b00011,
    XOR = 5'b00100,
    SRL = 5'b00101,
    SRA = 5'b01101,
    OR = 5'b00110,
    AND = 5'b00111,
    BEQ = 5'b11000,
    BNE = 5'b11001,
    BLT = 5'b11100,
    BGE = 5'b11101,
    BLTU = 5'b11110,
    BGEU = 5'b11111
} aluOp;

`define ADD 5'b00000
`define SUB 5'b01000
`define SLL 5'b00001
`define SLT 5'b00010
`define SLTU 5'b00011
`define XOR 5'b00100
`define SRL 5'b00101
`define SRA 5'b01101
`define OR 5'b00110
`define AND 5'b00111
`define BEQ 5'b11000
`define BNE 5'b11001
`define BLT 5'b11100
`define BGE 5'b11101
`define BLTU 5'b11110
`define BGEU 5'b11111

`endif
