`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2024 09:16:41 PM
// Design Name: 
// Module Name: seq_core_mem
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

module seq_core_mem(
       input                      clk,
       input wire                 read,
       input wire                 write,
       input      [`A_SIZE - 1:0] address,
       input      [`D_SIZE - 1:0] data_in,
       output reg [`D_SIZE - 1:0] data_out
);


reg [`D_SIZE - 1:0] mem [0:`A_SIZE - 1];

always @(*) begin
    if (`READ_ACTIVE == read) begin
        data_out = mem[address];
    end
end

always @(posedge clk)
    if (`WRITE_ACTIVE == write) begin
        mem[address] = data_in;
    end
endmodule
    