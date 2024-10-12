`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2024 05:14:10 PM
// Design Name: 
// Module Name: proc
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
`include "defines.vh"

module proc(
    input  [`ISIZE-1:0] instr,
    input  [`DSIZE-1:0] datain,
    output [`DSIZE-1:0] dataout
    );

wire [`CSIZE-1:0] opcode;
wire [`ASIZE-1:0] addr;

assign opcode = instr[`operatie];
assign addr   = instr[`addrmem];

/* add the alu to the project */
alu alu (
    .opcode (opcode),
    .datain (datain),
    .dataout(dataout),
    .sign   ()
);

mem mem(
    .addr(addr)
);

endmodule