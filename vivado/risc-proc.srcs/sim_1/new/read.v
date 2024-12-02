`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2024 11:20:37 PM
// Design Name: 
// Module Name: read
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
`define op1 5:3
`define op2 2:0
`define I_EXEC_SIZE (`I_SIZE+ (2*`D_SIZE))

module read(
    // general
    input 		rst,   // active 0
    input		clk,
    
    // pipeline in / out
    input [`I_SIZE-1:0] instruction_in, 
    output reg [`I_EXEC_SIZE-1:0] instruction_out,
    
    // registers control
    output reg [`REG_A_SIZE-1:0] sel_op1,
    output reg [`REG_A_SIZE-1:0] sel_op2,
    
    // registers fetch
    input wire [`D_SIZE-1:0] val_op1,
    input wire [`D_SIZE-1:0] val_op2
);

always @(*) begin
    sel_op1 = instruction_in[`op1];
    sel_op2 = instruction_in[`op2];
end 

always @(posedge clk) begin
    if (1'b0 == rst) begin
       instruction_out <= {`NOP, 9'b0, val_op1, val_op2};
    end
    else begin
       instruction_out <= {instruction_in, val_op1, val_op2};
    end
end

// instantiate registers
regs regs
(
    .clk(clk),
    .rst(rst),
    .sel_op1(sel_op1),
    .sel_op2(sel_op2),
    .val_op1(val_op1),
    .val_op2(val_op2)
);

endmodule
