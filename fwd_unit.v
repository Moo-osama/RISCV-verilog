module forwarding_unit
        (
        input [4:0] ID_EX_rs1,
        input [4:0] ID_EX_rs2,
        input [4:0] EX_MEM_rd,
        input [4:0] MEM_WB_rd,
        input [4:0] EX_MEM_regWrite,
        input [4:0] MEM_WB_regWrite,
        output reg [1:0] fwd_A,
        output reg [1:0] fwd_B
        );
        always @* begin
        if (EX_MEM_regWrite && (EX_MEM_rd != 0) && (EX_MEM_rd ==ID_EX_rs1))
            fwd_A = 10;
        else  
            if ((MEM_WB_regWrite && (MEM_WB_rd != 0) && (MEM_WB_rd ==ID_EX_rs1)))
                fwd_A = 01;
            else 
                fwd_A=00;
        if (EX_MEM_regWrite && (EX_MEM_rd != 0) && (EX_MEM_rd ==ID_EX_rs2))
            fwd_B = 10;
        else 
            if ((MEM_WB_regWrite && (MEM_WB_rd != 0) && (MEM_WB_rd ==ID_EX_rs2) ))
                 fwd_B = 01;
            else 
                 fwd_B=00;
        end
endmodule 