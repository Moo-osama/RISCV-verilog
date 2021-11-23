`timescale 1ns / 1ps
`include "defines.v"


module ALU(
    input wire [4:0] opcode,
	input wire [31:0] input1, input2,
	input wire [4:0]  shiftValue,
	input wire [3:0]  ALUSel,
	input wire inst_25,
	output reg  [31:0] result,
	output wire carryFlag, zeroFlag, overFlowFlag, signFlag
    );
    
    wire [31:0] addTemp, negInput2;    
        assign negInput2 = (~input2);
        
        assign {carryFlag, addTemp} = ALUSel[0] ? (input1 + negInput2 + 1'b1) : (input1 + input2);
        
        assign zeroFlag = (addTemp == 0);
        assign signFlag = addTemp[31];
        assign overFlowFlag = (input1[31] ^ (negInput2[31]) ^ addTemp[31] ^ carryFlag);
        
    
    
        always @ * begin
            result = 32'b0;
            case (ALUSel)
                
                `ALU_ADD : result = addTemp; 
                `ALU_SUB : result = addTemp; 
                `ALU_PASS: result = input2;
                
                `ALU_OR:  result = input1 | input2;
                `ALU_AND:  result = input1 & input2;
                `ALU_XOR:  result = input1 ^ input2;
                
                `ALU_SRL:  result=(input1 >> shiftValue); 
                `ALU_SRA:  result=(input1 >>> shiftValue);
                `ALU_SLL:  result=(input1 << shiftValue);
                
                `ALU_SLT:  result = {31'b0,(signFlag != overFlowFlag)}; 
                `ALU_SLTU: result = {31'b0,(~carryFlag)};      
                default: result = 32'b0;         
            endcase
        end
    
endmodule