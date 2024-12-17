`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2024 03:33:21 PM
// Design Name: 
// Module Name: seq_core_imem
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

module seq_core_imem(
    input [`A_SIZE-1:0]      pc,
    output reg [`I_SIZE-1:0] instruction
);

reg [`I_SIZE-1:0] mem [0:`A_SIZE-1];

always @(*) begin
    instruction = mem[pc];
end

endmodule
