`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2024 05:47:06 PM
// Design Name: 
// Module Name: test
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

module test;

reg [`ISIZE-1:0] instr;

proc proc (
    .instr(instr)
);

initial begin 
instr = {`ADD,`R2, `R1, `R0};
#1
instr = {`SUB, `R2, `R3, `R3};
end

endmodule
