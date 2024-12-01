`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2024 08:45:23 PM
// Design Name: 
// Module Name: fetch_testbench
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
`include "seq_core_testbench.vh"

module fetch_testbench;

// signals used to connect to the fetch module
reg clk = 0;
reg rst = 1;
reg [`I_SIZE-1:0] instruction;
wire [`I_SIZE-1:0] instruction_register;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

// instaniate dut 
fetch fetch
(
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .instruction_register(instruction_register)
);

// test dut
initial begin 

     // TC-1: Test the reset of fetch module
    #10 rst = 0;
    #10 `assert(instruction_register, {`NOP, 9'b0})
    
    // TC-2: Test the fetch module
    rst = 1;
    instruction = {`ADD, `R0, `R0, `R0};
    #10 `assert(instruction_register, instruction)
    
    instruction = {`ADDF, `R2, `R2, `R2};
    #10 `assert(instruction_register, instruction)
    
    instruction = {`OR, `R4, `R3, `R4};
    #10 `assert(instruction_register, instruction)
    
    // TC-3: Test the reset of fetch module
    rst = 0;
    #10 `assert(instruction_register, {`NOP, 9'b0})
    
end

endmodule
