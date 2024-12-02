`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 10:40:03 PM
// Design Name: 
// Module Name: write_back
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "seq_core.vh"

module write_back(
    input clk,
    input rst,

    input [`D_SIZE-1:0]     operand_in,
    input [`REG_A_SIZE-1:0] destination_in,
    input [`D_SIZE-1:0]     data_in,
    input                   data_in_ready,
    
    output reg [`REG_A_SIZE-1:0] destination_out,
    output reg [`D_SIZE-1:0]     result_out
);

always @(posedge clk) begin
    if (1'b1 == data_in_ready) begin
        result_out <= data_in;
    end
    
    else begin
        result_out <= operand_in;
        destination_out <= destination_in; 
    end
end


endmodule
