`timescale 1ns / 1ps


module register_file(
    input clk,
    input rst,
    input enableWrite,
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    output [31:0] readData1,
    output [31:0] readData2
    );
    
   
        wire [31:0] regValue [0:31];
        wire [31:0] load;
    
        assign load = enableWrite << writeReg;
        
        genvar i;
        generate
            for(i = 1; i < 32; i = i + 1) begin:reg_file_block
                register_neg_edge reg_i ((clk), (rst), (load[i]), (writeData), (regValue[i]));
            end
        endgenerate
        register_neg_edge reg_0((clk), (rst), (1), (0), (regValue[0]));
        
        assign readData1 = regValue[readReg1];
        assign readData2 = regValue[readReg2];

endmodule