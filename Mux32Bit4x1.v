`timescale 1ns / 1ps



module mux_4x1(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [31:0] d,
    input [1:0] s,
    output [31:0] out
    );
    
    assign out= s[1] ? (s[0] ? d : c) : (s[0] ? b : a);
    
endmodule 