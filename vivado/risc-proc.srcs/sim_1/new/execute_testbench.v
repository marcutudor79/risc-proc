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
`include "seq_core.vh"

module execute_testbench;

// signals used to connect to the read module
reg                          clk = 0;
reg                          rst = 1;
reg  [`I_EXEC_SIZE-1:0]      instruction_in;
wire [`D_SIZE-1:0]           operand_out;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

// instaniate dut 
execute execute
(
    .clk(clk),
    .rst(rst),
    .instruction_in(instruction_in),
    .operand_out(operand_out)
);

// test dut
initial begin 
    
    // TC-1: Test the exec module
    rst = 1;
    instruction_in = {`ADD, `R0, `R0, `R0, 32'd1, 32'd2};
    #10 `assert(operand_out, 32'd3)
    
    instruction_in = {`ADDF, `R0, `R0, `R0, 32'd2, 32'd3};
    #10 `assert(operand_out, 32'd5)
    
    instruction_in = {`SUB, `R0, `R0, `R0, 32'd1, 32'd1};
    #10 `assert(operand_out, 32'd0)
    
    instruction_in = {`SUBF, `R0, `R0, `R0, 32'd2, 32'd2};
    #10 `assert(operand_out, 32'd0)
    
    instruction_in = {`AND, `R0, `R0, `R0, 32'hFFFF, 32'd1};
    #10 `assert(operand_out, 32'd1)
    
    instruction_in = {`OR, `R0, `R0, `R0, 32'd0, 32'd1};
    #10 `assert(operand_out, 32'd1)
    
    instruction_in = {`XOR, `R0, `R0, `R0, 32'd1, 32'd1};
    #10 `assert(operand_out, 32'd0)
    
    instruction_in = {`NAND, `R0, `R0, `R0, 32'd0, 32'd1};
    #10 `assert(operand_out, -1)
    
    instruction_in = {`NOR, `R0, `R0, `R0, 32'd1, 32'd0};
    #10 `assert(operand_out, 32'b11111111111111111111111111111110)
    
    instruction_in = {`NXOR, `R0, `R0, `R0, 32'd0, 32'd1};
    #10 `assert(operand_out, 32'b11111111111111111111111111111110)
    
    
end

endmodule
