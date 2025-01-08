`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2025 11:34:36 AM
// Design Name: 
// Module Name: execute_floating_point
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

module execute_floating_point(
    input clk,
    input rst,
    
    // pipeline in/out
    input [`I_EXEC_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out
    
);

// execute only ADDF and SUBF in this module
always @(posedge clk) begin
     casex(instruction_in[`I_EXEC_OPCODE])
        `ADDF:      instruction_out[`I_EXEC_DAT2] <= instruction_in[`I_EXEC_DAT1] + instruction_in[`I_EXEC_DAT2];
        `SUBF:      instruction_out[`I_EXEC_DAT2] <= instruction_in[`I_EXEC_DAT1] - instruction_in[`I_EXEC_DAT2];
     endcase
end

endmodule