`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2024 03:28:48 PM
// Design Name: 
// Module Name: soc_top
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

module soc_top(
    input rst,
    input clk
);

wire [`A_SIZE-1:0] pc;
wire [`I_SIZE-1:0] instruction;
wire read_mem;
wire write_mem;
wire [`A_SIZE-1:0] address;
wire [`D_SIZE-1:0] data_in_seq_core;
wire [`D_SIZE-1:0] data_out_seq_core;

// instantiate the seq_core_top module
seq_core_top seq_core_top(
    // general
    .rst(rst),
    .clk(clk),
    // IMEM
    .pc(pc),
    .instruction(instruction),
    // DMEM
    .read_mem(read_mem),
    .write_mem(write_mem),
    .address(address),
    .data_in(data_in_seq_core),
    .data_out(data_out_seq_core)
);

// instantiate the DMEM module
seq_core_dmem dmem (
    // general
    .clk(clk),
    
    // seq_core_top
    .read_mem(read_mem),
    .write_mem(write_mem),
    .address(address),
    .data_in(data_out_seq_core),
    .data_out(data_in_seq_core)
);

// instantiate the IMEM module
/*
    this is the istruction memory module
    INPUT: pc - program counter of seq_core
*/
seq_core_imem imem (
    // input 
    .pc(pc),
    // output
    .instruction(instruction)
);


endmodule
