`timescale 1ns / 1ps



module hazard_detection_unit(
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    input [4:0] ID_EX_rd,
    input ID_EX_MemRead,
    input EX_MEM_MemRead,
    output reg stall,
    output reg stallSructural

    );
    
    always @(*) begin

        if (((IF_ID_rs1 == ID_EX_rd) || (IF_ID_rs2 == ID_EX_rd)) && ID_EX_MemRead && (ID_EX_rd != 0))
            stall = 1;
        else
            stall = 0;
    end
    
    always @(*) begin
        if (EX_MEM_MemRead)
            stallSructural = 1;
        else
            stallSructural = 0;
    end
    
endmodule