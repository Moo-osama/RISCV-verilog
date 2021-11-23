`timescale 1ns / 1ps
`include "defines.v"

module branch_controller(
    input [4:0] opcode, 
    input [2:0] func3,
    input cf, zf, vf, sf, branch,
    output reg flag
    );
    
    always @* begin
         if(branch) begin
            if (opcode==`OPCODE_JALR || opcode== `OPCODE_JAL) begin
                flag=1;
            end
            else begin
            case (func3) 
                `BR_BEQ: flag = zf;        
                `BR_BNE: flag = ~zf;        
                `BR_BLT: flag = (sf!=vf);          
                `BR_BGE: flag = (sf==vf);        
                `BR_BLTU:flag = ~cf;         
                `BR_BGEU:flag = cf;   
                default: flag = 0;    
            endcase
            end
         end
         else flag=0;
    end
    
endmodule
