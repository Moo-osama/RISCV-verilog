`timescale 1ns / 1ps
`include "defines.v"


module ImmGen (
    input  wire [31:0]  IR,
    output reg  [31:0]  imm
    );

always @(*) begin
	case (`OPCODE)
		`OPCODE_Arith_I   : 	imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Store     :     imm = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] };
		`OPCODE_LUI       :     imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_AUIPC     :     imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_JAL       : 	imm = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 };
		`OPCODE_JALR      : 	imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Branch    : 	imm = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
		default           : 	imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; 
	endcase 
end

endmodule