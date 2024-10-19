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
/********** INCLUDES **********/
`include "seq_core.vh"

/* seq_core_alu module
    * this module is used to compute the ALU operations
*/
module seq_core_alu
(
    input      [`C_SIZE-1:0] opcode,
    input      [`D_SIZE-1:0] operand1,
    input      [`D_SIZE-1:0] operand2,
    output reg [`D_SIZE-1:0] result,
    output reg sign
);

always @(*) begin

    case(opcode)
    `NOP: begin
          result = 0;
          sign   = 0;
          end
    `ADD: begin 
          result = operand1 + operand2;
          sign   = result[31];
          end
    `ADDF: begin 
           result = operand1 + operand2;
           sign   = result[31];
           end
    `SUB: begin
          result = operand1 - operand2;
          sign   = result[31];
          end 
    `SUBF: begin
           result = operand1 - operand2;
           sign   = result[31];
           end 
     `AND: begin
           result = operand1 & operand2;
           sign   = result[31];
           end
    
    endcase
end

endmodule
