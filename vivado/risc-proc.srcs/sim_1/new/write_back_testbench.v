`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 10:55:18 PM
// Design Name: 
// Module Name: write_back_testbench
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

module write_back_testbench;

// signals used to connect to the read module
reg                clk = 0;
reg                rst = 1;
reg  [`D_SIZE-1:0] data_in;
reg                data_in_ready = 0;

reg [`D_SIZE-1:0]     operand_in;
reg [`REG_A_SIZE-1:0] destination_in;

wire [`D_SIZE-1:0] result_out;
wire [`REG_A_SIZE-1:0] destination_out;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

// instaniate dut 
write_back write_back
(
    .clk(clk),
    .rst(rst),
    .operand_in(operand_in),
    .destination_in(destination_in),
    .result_out(result_out),
    .destination_out(destination_out)
);

// test dut
initial begin 
    
    // TC-1: Test the exec module
    rst = 1;
    destination_in = `R0;
    operand_in = 32'd1;
    #10 `assert(destination_out, `R0)
    `assert(result_out, 32'd1)
    
end

endmodule
