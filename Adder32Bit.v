`timescale 1ns / 1ps


module adder(
    input [31:0]a, b,
    input cin,
    output cout,
    output [31:0]sum
    );
    
    wire [32:0]cinWire;
    genvar i;
    
    assign cinWire[0] = cin;
    assign cout = cinWire[32];
    
    generate
        for(i = 0; i < 32; i = i + 1)begin:Adder32BitBlock
            Adder adder(a[i], b[i], cinWire[i], cinWire[i+1],sum[i]);
        end
    endgenerate
    
endmodule