`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:22:25 PM
// Design Name: 
// Module Name: seq_core_top
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

module seq_core_top(
    // general
    input rst,
    input clk,
    // program memory
    output [`A_SIZE-1:0] pc,
    input  [`I_SIZE-1:0] instruction,
    // data memory
    output               read_mem,
    output               write_mem,
    output [`A_SIZE-1:0] address,
    input  [`D_SIZE-1:0] data_in,
    output [`D_SIZE-1:0] data_out
);


/**************************************
         PIPELINE INSTANTIATION
***************************************/
wire [`I_SIZE-1:0] instruction_register;

fetch fetch
(
    // general
    .rst(rst), // active 0
    .clk(clk),
    // program memory / pipeline in
    .pc(pc),
    .instruction(instruction),
    // pipeline out
    .instruction_register(instruction_register),    
    // exec stage control
    .jmp_detected(jmp_detected),
    .jmp_pc(jmp_pc)
);

wire [`I_EXEC_SIZE-1:0] instruction_out_read;
wire [`REG_A_SIZE-1:0] sel_op1;
wire [`REG_A_SIZE-1:0] sel_op2;
wire [`D_SIZE-1:0] val_op1;
wire [`D_SIZE-1:0] val_op2;
wire data_dep_detected;
wire data_dep_op_sel;

// 2nd STAGE 
read read
(
    // general
    .rst(rst),
    .clk(clk),
    // pipeline in
    .instruction_in(instruction_register),
    // pipeline out
    .instruction_out(instruction_out_read),
    // registers control 
    .sel_op1(sel_op1),
    .sel_op2(sel_op2),
    .val_op1(val_op1),
    .val_op2(val_op2)
);

wire [`I_EXEC_SIZE-1:0] instruction_out_exec;
wire [`D_SIZE-1:0] result_exec;
wire jmp_detected;
wire [`A_SIZE-1:0] jmp_pc;

// 3rd STAGE
execute execute
(
    //general
    .rst(rst),
    .clk(clk), 
    //pipeline in    
    .instruction_in(instruction_out_read),
    //pipeline out
    .instruction_out(instruction_out_exec),
    //data_dep ctrl
    .data_dep_detected(data_dep_detected),
    .data_dep_op_sel(data_dep_op_sel),
    //fetch stage ctrl
    .pc(pc),
    .jmp_detected(jmp_detected),
    .jmp_pc(jmp_pc),
    // memory ctrl
    .address(address),
    .data_out(data_out),
    .read_mem(read_mem),
    .write_mem(write_mem)
);

wire [`REG_A_SIZE-1:0] destination;
wire [`D_SIZE-1:0] result;

// 4th STAGE
write_back write_back
(
    //general
    .rst(rst),
    .clk(clk),
    //pipeline in 
    .instruction_in(instruction_out_exec),
    //pipeline out
    .destination(destination),
    .result(result)
);

/**************************************
     REGISTER BLOCK INSTATIATION 
***************************************/
regs regs
(
    // general
    .rst(rst),
    .clk(clk),
    // input signals read stage
    .sel_op1(sel_op1),
    .sel_op2(sel_op2),
    // input signals write_back stage
    .destination(destination),
    .result(result),
    // output signals for read stage
    .val_op1(val_op1),
    .val_op2(val_op2)
);

/**************************************
    DATA DEPENDECY CONTROL MODULE
          INSTANTIATION
***************************************/
data_dep_ctrl data_dep_ctrl
(
    // general
    .rst(rst),
    .clk(clk),   
    // pipeline instruction signals to check
    // check the IN to READ stage and IN to EXEC stage
    .instruction_read_in(instruction_register),
    .instruction_exec_in(instruction_out_read),
    // exec stage control
    .data_dep_detected(data_dep_detected),
    .data_dep_op_sel(data_dep_op_sel)
);
 
endmodule
