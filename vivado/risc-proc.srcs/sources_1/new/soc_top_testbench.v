`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2024 04:00:49 PM
// Design Name: 
// Module Name: soc_top_testbench
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
`include "seq_core_testbench.vh"

module soc_top_testbench;

reg clk = 0;
reg rst = 1;
reg [`I_SIZE-1:0] instruction;
reg [`D_SIZE-1:0] data_in;
reg [`I_SIZE-1:0] opcode;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

/***************************************
  SOC_TOP DUT
****************************************/

// risc core 4stage pipeline with IMEM and DMEM
soc_top soc_top
(
    .clk(clk),
    .rst(rst)
);

/************************************
               TESTS
*************************************/
`define LOADC_INSTR 5'b01000

initial begin
// TC-1: Load IMEM with a program and execute it
rst = 0;
soc_top.imem.mem[0] =  {`LOADC_INSTR, `R1, 8'd1};
soc_top.imem.mem[1] =  {`LOADC_INSTR, `R2, 8'd2};
soc_top.imem.mem[2] =  {`ADD, `R0, `R1, `R2};
soc_top.imem.mem[3] =  {`ADD, `R0, `R1, `R2};
soc_top.imem.mem[4] =  {`ADD, `R0, `R1, `R2};
soc_top.imem.mem[5] =  {`NOP, `R0, `R1, `R2};
soc_top.imem.mem[6] =  {`NOP, `R0, `R1, `R2};
soc_top.imem.mem[7] =  {`NOP, `R0, `R1, `R2};
soc_top.imem.mem[8] =  {`NOP, `R0, `R1, `R2};
soc_top.imem.mem[9] =  {`NOP, `R0, `R1, `R2};
soc_top.imem.mem[10] = {`NOP, `R0, `R1, `R2};
soc_top.imem.mem[11] = {`HALT};

#10 rst = 1;
end

endmodule
