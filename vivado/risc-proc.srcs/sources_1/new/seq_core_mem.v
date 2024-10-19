`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: Marculescu Tudor
//
// Create Date: 10/19/2024 12:35:41 PM
// Design Name: seq_core
// Module Name: seq_core
// Project Name: DSD project ACES
// Target Devices: -
// Tool Versions: vivado 2023.2
// Description: golden model of a seq_core
//
// Dependencies: https://users.dcae.pub.ro/~zhascsi/courses/dsd/golden_model.txt
//
// Revision: 1.0
// Revision 1.0 - File Created
// Additional Comments: -
//
//////////////////////////////////////////////////////////////////////////////////


module seq_core_mem
(
    /* INPUT SIGNALS FOR THE MEMORY */
    input clock,  // clock signal
    input we,     // write enable signal 0 - read, 1 - write
    input [`ASIZE-1:0] address,
    input [`DSIZE-1:0] data_in,

    /* OUTPUT SIGNALS FOR THE MEMORY */
    output reg [`DSIZE-1:0] data_out
);

reg [`DSIZE-1:0] memory [0:`MEMSIZE-1];

always @(posedge clock)
begin

    // if we is 1, write to memory address the data_in signal
    if (1'b1 == we)
        memory[address] <= data_in;

    // if we is 0, read from memory address and write to data_out
    else if (1'b0 == we)
        data_out <= memory[address];
end

endmodule
