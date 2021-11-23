`timescale 1ns / 1ps
`include "defines.v"


module control_unit(
    input [6:0] opcode,
    input stop,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc2,
    output reg ALUSrc1, 
    output reg enableWrite,
    output reg PCOrOther, 
    output reg writeDataOrAddr,
    output reg LoadPC
    );

    always @(*) begin
        if(opcode == 0) begin
            branch = 0;
            memRead = 0;
            memtoReg = 1'b0;
            ALUOp = 2'b00;
            memWrite = 0;
            ALUSrc2 = 0;
            ALUSrc1 = 0;
            enableWrite = 0;
            PCOrOther = 0;
            writeDataOrAddr = 0;
            LoadPC = 1;
        end
        
        else begin
            case (opcode[6:2])
                `OPCODE_LUI: begin  
                    branch = 0;
                    memRead = 0;
                    memtoReg = 0;
                    ALUOp = 2'b11;
                    memWrite = 0;
                    ALUSrc2 = 1;
                    ALUSrc1 = 0;
                    enableWrite = 1;
                    PCOrOther=0;
                    writeDataOrAddr=0;
                    LoadPC = 1;
                end
                `OPCODE_AUIPC: begin 
                    branch = 0;
                    memRead = 0;
                    memtoReg = 0;
                    ALUOp = 2'b10;
                    memWrite = 0;
                    ALUSrc2 = 1;
                    ALUSrc1 = 1;
                    enableWrite = 1;
                    PCOrOther=0;
                    writeDataOrAddr=0;
                    LoadPC = 1;
                end
                `OPCODE_JAL: begin
                    branch = 1;
                    memRead = 0;
                    memtoReg = 0;
                    ALUOp = 2'b10;
                    memWrite = 0;
                    ALUSrc2 = 1;
                    ALUSrc1 = 1;
                    enableWrite = 1;
                    PCOrOther=0;
                    writeDataOrAddr=1;
                    LoadPC = 1;
                end
                `OPCODE_JALR: begin
                    branch = 1;
                    memRead = 0;
                    memtoReg = 0;
                    ALUOp = 2'b10;
                    memWrite = 0;
                    ALUSrc2 = 1;
                    ALUSrc1 = 0;
                    enableWrite = 1;
                    PCOrOther=1;
                    writeDataOrAddr=1;
                    LoadPC = 1;
                end
                `OPCODE_Load: begin
                    branch = 0;
                    memRead = 1;
                    memtoReg = 1;
                    ALUOp = 2'b00;
                    memWrite = 0;
                    ALUSrc2 = 1;
                    ALUSrc1=0;
                    enableWrite = 1;
                    PCOrOther=0;
                    writeDataOrAddr=0;
                    LoadPC = 1;
                end
                `OPCODE_Store: begin
                    branch = 0;
                    memRead = 0;
                    memtoReg = 1'bx;
                    ALUOp = 2'b00;
                    memWrite = 1;
                    ALUSrc2 = 1;
                    ALUSrc1 = 0;
                    enableWrite = 0;
                    PCOrOther=0;
                    writeDataOrAddr=0;
                    LoadPC = 1;
                end
                `OPCODE_Branch: begin
                    branch = 1;
                    memRead = 0;
                    memtoReg = 1'bx;
                    ALUOp = 2'b01;
                    memWrite = 0;
                    ALUSrc2 = 0;
                    ALUSrc1 = 0;
                    enableWrite = 0;
                    PCOrOther = 0;
                    writeDataOrAddr = 0;
                    LoadPC = 1;
                end
                `OPCODE_Arith_I: begin 
                    branch = 0;
                    memRead = 0;
                    memtoReg = 1'b0;
                    ALUOp = 2'b10;
                    memWrite = 0;
                    ALUSrc2 = 1;
                    ALUSrc1 = 0;
                    enableWrite = 1;
                    PCOrOther = 0;
                    writeDataOrAddr = 0; 
                    LoadPC = 1;
                end
                `OPCODE_Arith_R: begin
                    branch = 0;
                    memRead = 0;
                    memtoReg = 1'b0;
                    ALUOp = 2'b10;
                    memWrite = 0;
                    ALUSrc2 = 0;
                    ALUSrc1 = 0;
                    enableWrite = 1;
                    PCOrOther = 0;
                    writeDataOrAddr = 0;
                    LoadPC = 1;
                end
                `OPCODE_SYSTEM: begin
                    if(stop) begin
                        branch = 0;
                        memRead = 0;
                        memtoReg = 1'b0;
                        ALUOp = 2'b00;
                        memWrite = 0;
                        ALUSrc2 = 0;
                        ALUSrc1 = 0;
                        enableWrite = 0;
                        PCOrOther = 0;
                        writeDataOrAddr = 0;
                        LoadPC = 0;
                    end
                    else begin
                        branch = 0;
                        memRead = 0;
                        memtoReg = 1'b0;
                        ALUOp = 2'b00;
                        memWrite = 0;
                        ALUSrc2 = 0;
                        ALUSrc1 = 0;
                        enableWrite = 0;
                        PCOrOther = 0;
                        writeDataOrAddr = 0;
                        LoadPC = 1;
                    end
                end
                default: begin
                    branch = 0;
                    memRead = 0;
                    memtoReg = 0;
                    ALUOp = 2'b00;
                    memWrite = 0;
                    ALUSrc2 = 0;
                    ALUSrc1 = 0;
                    enableWrite = 0;
                    PCOrOther = 0;
                    writeDataOrAddr = 0;
                    LoadPC = 1;
                end         
            endcase
        end
    end

endmodule
