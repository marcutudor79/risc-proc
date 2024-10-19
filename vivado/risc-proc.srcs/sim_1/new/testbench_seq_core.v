`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 03:27:33 PM
// Design Name: 
// Module Name: testbench_seq_core
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

module testbench_seq_core;
reg rst = 1;
reg clk = 0;
reg [`I_SIZE-1:0] instruction;

seq_core seq_core 
(
    .rst(rst),
    .clk(clk),
    .instruction(instruction)
);

initial begin
    forever #5 clk = ~clk; 
end

initial begin
    // TC0 - reset the chip
    rst = 0;
    #10
    rst = 1;
    instruction = {`NOP, `R0, `R0, `R0};
    #10
    instruction = {`NOP, `R0, `R0, `R0};
    #10
    instruction = {`NOP, `R0, `R0, `R0};
    #10
    instruction = {`ADD, `R1, `R1, `R1};
    #10
    instruction = {`ADD, `R2, `R2, `R2};
    #10
    instruction = {`ADDF, `R3, `R3, `R3};
    #10
    instruction = {`ADDF, `R4, `R4, `R4};
    #10
    instruction = {`SUB, `R1, `R1, `R1};
    #10
    instruction = {`SUB, `R2, `R2, `R2};
    #10
    instruction = {`SUBF, `R3, `R3, `R3};
    #10
    instruction = {`SUBF, `R4, `R4, `R4};
    #10
    instruction = {`AND, `R6, `R6, `R6};
    #10
    instruction = {`AND, `R7, `R7, `R7};
end

endmodule
