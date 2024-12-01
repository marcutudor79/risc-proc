`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2024 08:25:42 PM
// Design Name: 
// Module Name: fetch
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

module fetch(
     // general
    input 		rst,   // active 0
    input		clk,
    // program memory
    output reg [`A_SIZE-1:0] pc,
    input  [`I_SIZE-1:0] instruction,
    
    // IR register output
    output reg [`I_SIZE-1:0] instruction_register
);

always @(posedge clk) begin 
    if (1'b0 == rst) begin
        instruction_register <= `NOP;
        
        // reset the pc
        pc <= 1'd0;
    end
    
    else begin
        instruction_register <= instruction;
        
        // increment pc
        pc <= pc + 1;
    end
   
end
endmodule
