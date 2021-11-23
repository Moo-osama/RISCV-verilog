`timescale 1ns / 1ps


module mux_2x1(
    input [31:0] a,
    input [31:0] b,
    input s,
    output [31:0] c
    );
    
    genvar i;
    
    generate
        for (i = 0; i < 32; i = i + 1) begin:Mux32BitBlock
            Mux2x1 Mux2(
                .a(a[i]),
                .b(b[i]),
                .s(s),
                .c(c[i])
                );
        end
    endgenerate
    
endmodule