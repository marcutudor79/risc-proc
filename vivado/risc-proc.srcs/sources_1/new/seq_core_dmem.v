`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2024 03:32:41 PM
// Design Name: 
// Module Name: seq_core_dmem
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

module seq_core_dmem(
    input clk,
    input read_mem,
    input write_mem,
    input      [`A_SIZE-1:0] address,
    input      [`D_SIZE-1:0] data_in,
    output reg [`D_SIZE-1:0] data_out
);

reg [`A_SIZE-1:0] address_in;
reg [`D_SIZE-1:0] mem [0:`MEM_SIZE-1];

always @(*) begin 
    data_out  <= mem[address_in];
end

always @(posedge clk) begin 
    if (`READ_ACTIVE == read_mem) begin
        address_in <= address;
    end
    
    else if (`WRITE_ACTIVE == write_mem) begin
        mem[address] <= data_in;
    end
end

endmodule
