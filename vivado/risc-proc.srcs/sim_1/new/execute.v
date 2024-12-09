`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 12:07:12 AM
// Design Name: 
// Module Name: execute
// Project Name: 
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

module execute(
    input clk,
    input rst,
    
    // pipeline in/out
    input [`I_EXEC_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out,
    
    // memory control
    output reg [`A_SIZE-1:0] addr,
    output reg [`D_SIZE-1:0] data_out,
    
    // data_dep_ctrl control
    input wire data_dep_detected,  // active 0
    input wire data_dep_op_sel     // select which operand to override with val_op_exec         
);

// exec fast register -> will override one of the values from read stage
reg [`D_SIZE-1:0] op1;
reg [`D_SIZE-1:0] op2;

// override one of the operands if data dependecy is detected 
always @(*) begin
     if (0'b0 == data_dep_detected) begin
           case(data_dep_op_sel)
            `OVERRIDE_EXEC_DAT1: begin
                op1 = instruction_out[31:0];
                op2 = instruction_in[63:32];
            end
            `OVERRIDE_EXEC_DAT2: begin
                op1 = instruction_in[31:0];
                op2 = instruction_out[31:0];
            end         
            endcase
     end
     else begin
        op2 = instruction_in[31:0];
        op1 = instruction_in[63:32];
     end
end

always @(posedge clk) begin
    
    // Set the instruction that was used in the instruction_out register
    instruction_out[`I_EXEC_SIZE-1:64] <= instruction_in[`I_EXEC_SIZE-1:64];
    
    // Set the computed operand in the op0 place
    casex(instruction_in[`I_EXEC_OPCODE])
        `ADD:       instruction_out[31:0] <= op1 + op2;
        `ADDF:      instruction_out[31:0] <= op1 + op2;
        `SUB:       instruction_out[31:0] <= op1 - op2;
        `SUBF:      instruction_out[31:0] <= op1 - op2;
        `AND:       instruction_out[31:0] <= op1 & op2;
        `OR:        instruction_out[31:0] <= op1 | op2;
        `XOR:       instruction_out[31:0] <= op1 ^ op2;
        `NAND:      instruction_out[31:0] <= ~(op1 & op2);
        `NOR:       instruction_out[31:0] <= ~(op1 | op2);
        `NXOR:      instruction_out[31:0] <= ~(op1 ^ op2);
        `SHIFTR:    instruction_out[31:0] <= op1         >>  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `SHIFTRA:   instruction_out[31:0] <= $signed(op1) >>> {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]}; 
        `SHIFTL:    instruction_out[31:0] <= op1        <<  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
    endcase
end

endmodule
