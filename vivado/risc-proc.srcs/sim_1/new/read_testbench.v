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

module read_testbench;

// signals used to connect to the read module
reg                          clk = 0;
reg                          rst = 1;
reg  [`I_SIZE-1:0]           instruction_in;
wire [`I_SIZE+`D_SIZE*2-1:0] instruction_out;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

// instaniate dut 
read read
(
    .clk(clk),
    .rst(rst),
    .instruction_in(instruction_in),
    .instruction_out(instruction_out)
);

// test dut
initial begin 

    // TC-1: Test the reset of read module
    #10 rst = 0;
    #10 `assert(instruction_out[(`I_SIZE+(`D_SIZE*2)-1):(`I_SIZE+(`D_SIZE*2)-16)], {`NOP, 9'b0})
    
    // TC-2: Test the fetch module
    rst = 1;
    instruction_in = {`ADD, `R0, `R0, `R0};
    #20 `assert(instruction_out, {`ADD, `R0, `R0, `R0, 32'd0, 32'd0})
    
    instruction_in = {`ADDF, `R2, `R2, `R2};
    #20 `assert(instruction_out, {`ADDF, `R2, `R2, `R2, 32'd2, 32'd2})
    
    instruction_in = {`OR, `R4, `R3, `R4};
    #20 `assert(instruction_out, {`OR, `R4, `R3, `R4, 32'd3, 32'd4})
    
    // TC-3: Test the reset of read module
    rst = 0;
    #10 `assert(instruction_out[(`I_SIZE+(`D_SIZE*2)-1):(`I_SIZE+(`D_SIZE*2)-16)], {`NOP, 9'b0})
    
end

endmodule
