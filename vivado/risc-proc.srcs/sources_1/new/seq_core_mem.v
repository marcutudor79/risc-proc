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
       input                      rst,
       input                      clk,
       input wire                 read,
       input wire                 write,
       input      [`A_SIZE - 1:0] address,
       input      [`D_SIZE - 1:0] datain,
       output reg [`D_SIZE - 1:0] dataout
);


reg [`D_SIZE - 1:0] mem [0:`A_SIZE - 1];

always @(*) begin
    if (`READ_ACTIVE == read) begin
        dataout = mem[address];
    end
end

always @(posedge clk)
    if (0 == rst) begin
        mem[0] = 32'd0;
        mem[1] = 32'd0;
        mem[2] = 32'd0;
        mem[3] = 32'd0;
        mem[4] = 32'd0;
        mem[5] = 32'd0;
        mem[6] = 32'd0;
        mem[7] = 32'd0;
        mem[8] = 32'd0;
        mem[9] = 32'd0;
    end else 
    if (`WRITE_ACTIVE == write) begin
        mem[address] = datain;
    end
endmodule
    