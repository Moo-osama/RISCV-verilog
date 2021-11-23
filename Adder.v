`timescale 1ns / 1ps


module Adder(
    input a,
    input b,
    input cin, 
    output cout,
    output sum
    );
    
    assign { cout, sum } = a + b + cin;

endmodule