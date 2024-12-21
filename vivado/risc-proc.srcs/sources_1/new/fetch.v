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
    input wire [`A_SIZE-1:0] jmp_pc,
    // data_dep control
    input wire load_dep_detected
);

// if JMP is executed, then update pc with it's value
// in the same clock cycle, such that to read the correct
// next instruction
always @(negedge jmp_detected) begin
    pc = jmp_pc;
end

always @(posedge clk) begin 
    // reset the pc
    if (1'b0 == rst) begin
        instruction_register <= `NOP;
        pc <= 1'd0;
    end
    
    // if HALT is executed, then the pc remains frozen
    else if (`HALT == instruction) begin
        pc <= pc;
    end
    
    // HALT the pipeline for 1 clk cycle if load_dep 
    // such that the memory has time to reply with the operand value
    else if (1'b0 == load_dep_detected) begin
        pc <= pc;
        instruction_register <= instruction_register;    
    end
    
    // otherwise continue executing 
    else begin
        instruction_register <= instruction;
        
        // increment pc
        pc <= pc + 1;
    end
   
end
endmodule
