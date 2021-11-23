`timescale 1ns / 1ps

module register_neg_edge #(parameter n = 32) (
    input clk,
    input rst,
    input load,
    input [n - 1:0] d,
    output reg [n - 1:0] q
    );
       
    always @(negedge clk, posedge rst) begin
        if(rst) 
            q <= 0;
        else
            if(load)
                q <= d;
            else
                q <= q;
    end

endmodule