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
    // program memory & execute control
    output reg [`A_SIZE-1:0] pc,
    input  [`I_SIZE-1:0] instruction,
    // instruction register output
    output reg [`I_SIZE-1:0] instruction_register,
    // execute stage jmp control
    input wire jmp_detected,
    input wire [`A_SIZE-1:0] jmp_pc
);

always @(*) begin
    // if JMP is executed, then update pc with it's value
    if (1'b0 == jmp_detected) begin
        pc <= jmp_pc;
    end
end

always @(posedge clk) begin 
    if (1'b0 == rst) begin
        instruction_register <= `NOP;
        
        // reset the pc
        pc <= 1'd0;
    end
    
    // if HALT is executed, then the pc remains frozen
    else if (`HALT == instruction) begin
        pc <= pc;
    end
    
    // continue executing if no HALT or RST
    else begin
        instruction_register <= instruction;
        
        // increment pc
        pc <= pc + 1;
    end
   
end
endmodule
