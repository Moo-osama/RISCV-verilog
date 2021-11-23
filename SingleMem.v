`timescale 1ns / 1ps
`include "defines.v"


module inst_data_mem(
    input clk,
    input MemRead,
    input MemWrite,
    input [2:0] func3,
    input [7:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
    );
    
    reg [7:0] mem [0:255];
    
        
        wire [7:0]data_address;
        wire [7:0]inst_address;
        assign inst_address = addr;
        assign data_address = 255 - addr; 
        
        
        always @(*) begin 
                        
                        
            if (MemRead)
            begin
            
                if (func3 == `F3_LSB)
                begin
                    data_out[7:0] <= mem[data_address];
                    data_out[31:8] <= (data_out[7]) ? 24'hffffff : 24'd0;
                end
            
                else if (func3 == `F3_LSH)
                begin
                    data_out[7:0]   <= mem[data_address];
                    data_out[15:8]  <= mem[data_address-1];
                    data_out[31:16] <= (data_out[15]) ? 16'hffff : 16'd0;
                end
                
                else if (func3 == `F3_LSW)
                begin
                    data_out[7:0] <= mem[data_address];
                    data_out[15:8] <= mem[data_address-1];
                    data_out[23:16] <= mem[data_address-2];
                    data_out[31:24] <= mem[data_address-3];
                end
            
                else if (func3 == `F3_LSBU)
                begin
                    data_out[7:0] <= mem[data_address];
                    data_out[31:8] <= 24'd0;
                end
                
                else if (func3 == `F3_LSHU)
                begin
                    data_out[7:0] <= mem[data_address];
                    data_out[15:8] <= mem[data_address-1];
                    data_out[31:16] <= 16'd0;
                end
                
                else
                    data_out <= 0;         
            end
            
            else
                data_out <= {mem[inst_address + 3], mem[inst_address + 2], mem[inst_address + 1], mem[inst_address]}; 
        end
        
        
        always @(negedge clk) begin
            if (MemWrite)
            begin
            
                if (func3 == `F3_LSB)
                    mem[data_address] <= data_in[7:0];
                
                else if (func3 == `F3_LSH)
                begin
                    mem[data_address] <= data_in[7:0];
                    mem[data_address-1] <= data_in[15:8];
                end
                
                else if (func3 == `F3_LSW)
                begin
                    mem[data_address] <= data_in[7:0];
                    mem[data_address-1] <= data_in[15:8];
                    mem[data_address-2] <= data_in[23:16];
                    mem[data_address-3] <= data_in[31:24];
                end
                
                else
                    mem[data_address]  <= mem[data_address];
                    
            end
            else
                mem[data_address] <= mem[data_address];
        end

        
        
        initial begin
            $readmemh("test.mem", mem);
        end
        
endmodule