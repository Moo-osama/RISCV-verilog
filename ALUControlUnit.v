`timescale 1ns / 1ps
`include "defines.v"


module ALU_control_unit
    (
    input [4:0] opCode,
    input [1:0] ALUOp,
    input [2:0] inst_14_12,
    input inst_30,
    output reg [3:0] ALUselc  
    );

        always@(*) begin
            case (ALUOp)   
                2'b00:  ALUselc =  `ALU_ADD;            
                2'b01: ALUselc =  `ALU_SUB;             
                2'b10: begin
                    case(opCode)
                            `OPCODE_AUIPC:ALUselc =`ALU_ADD;
                            `OPCODE_JALR: ALUselc =`ALU_ADD;
                            `OPCODE_JAL : ALUselc =`ALU_ADD;
                        
                            default: begin
                                case({inst_14_12, inst_30})
                                    {`F3_ADD, 1'b0}: ALUselc =`ALU_ADD;
                                    {`F3_ADD, 1'b1}: ALUselc = (opCode == `OPCODE_Arith_R) ? `ALU_SUB : `ALU_ADD;
                                    {`F3_SLL, 1'bx}: ALUselc = `ALU_SLL;                                
                                    {`F3_SLT, 1'bx}: ALUselc = `ALU_SLT;                                
                                    {`F3_SLTU, 1'bx}:ALUselc = `ALU_SLTU; 
                                    {`F3_SRL, 1'b0}: ALUselc = `ALU_SRL;  
                                    {`F3_SRL, 1'b1}: ALUselc = `ALU_SRA; 
                                    
                                    {`F3_OR, 1'b0}:  ALUselc = `ALU_OR;
                                    {`F3_AND, 1'b0}: ALUselc =`ALU_AND;
                                    {`F3_XOR, 1'bx}: ALUselc = `ALU_XOR;
                                    
                                    default:         ALUselc = `ALU_NOP;
                                endcase
                            end   
                    endcase 
                end 
                2'b11: ALUselc= `ALU_PASS;
                default: ALUselc = 4'b1111;
            endcase
        end

   
endmodule