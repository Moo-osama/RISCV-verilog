`timescale 1ns / 1ps


module Mux2x1(
    input a,
    input b,
    input s,
    output c
    );
    
    assign c = s?b:a;
    
endmodule