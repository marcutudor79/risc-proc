`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/07/2024 09:22:25 PM
// Design Name: seq_core_pipeline
// Module Name: seq_core_pipeline
// Project Name:
// Target Devices:
// Tool Versions:
// Description: pipeline implementation of the golden model
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "seq_core.vh"

module seq_core_pipeline(
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
    output [`D_SIZE-1:0] data_out,
    // interface with mem_ctrl
    input               cpu_rst, 
    input               cpu_stop,
    input               cpu_start,
    output              cpu_status
);


/**************************************
         PIPELINE INSTANTIATION
***************************************/
wire [`I_SIZE-1:0] instruction_register_out;
wire jmp_detected;
wire [`A_SIZE-1:0] jmp_pc;
wire load_dep_detected;
wire backpressure_write_back;
wire backpressure_exec_floating_dep;

fetch fetch
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst), // active 0
    .clk(clk),
    .pc_out(pc),
    .instruction(instruction),

    /*
        PIPELINE SIGNALS
    */
    // pipeline in
    // N/A
    // pipeline out -> to READ stage
    .instruction_register_out(instruction_register_out),

    /*
        EXECUTE STAGE CONTROL SIGNALS
    */
    .jmp_detected(jmp_detected),
    .jmp_pc(jmp_pc),

    /*
        DATA DEP BLOCK CONTROL SIGNAL
    */
    .load_dep_detected(load_dep_detected),


    /*
        FETCH STAGE CONTROL SIGNALS
    */
    .backpressure_wb_concurrency(backpressure_write_back),
    .backpressure_exec_floating_dep(backpressure_exec_floating_dep),
    
    /*
        MEMCTRL SIGNALS 
    */
    .cpu_stop(cpu_stop),
    .cpu_start(cpu_start),
    .stop_detected(cpu_status),
    .cpu_rst(cpu_rst)   
);

wire [`I_EXEC_SIZE-1:0] instruction_out_read;
wire [`I_EXEC_SIZE-1:0] instruction_out_read_floating;
wire [`REG_A_SIZE-1:0] sel_op1;
wire [`REG_A_SIZE-1:0] sel_op2;
wire [`D_SIZE-1:0] val_op1;
wire [`D_SIZE-1:0] val_op2;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel;
wire exec_dep_detected;
wire wb_dep_detected;
wire [`D_SIZE-1:0] result;

// 2nd STAGE
read read
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst),
    .clk(clk),

    /*
        PIPELINE SIGNALS
    */
    // pipeline in <- from FETCH
    .instruction_in(instruction_register_out),
    // pipeline out -> to EXEC stage
    .instruction_out_read(instruction_out_read),
    // pipeline out -> to EXEC_FLOATING_POINT stage
    .instruction_out_read_floating(instruction_out_read_floating),

    /*
        REGISTER BLOCK CONTROL AND RETRIEVE SIGNALS
    */
    // selection signals -> to REGS module
    .sel_op1(sel_op1),
    .sel_op2(sel_op2),
    // register value <- from REGS module
    .val_op1(val_op1),
    .val_op2(val_op2),

    /*
        DATA DEP BLOCK CONTROL SIGNALS AND FAST FORWARD SIGNALS
    */
    // data_dep_flags <- from DATA_DEP_CTRL module
    .exec_dep_detected(exec_dep_detected),
    .wb_dep_detected(wb_dep_detected),
    // data_dep_op_selector <- from DATA_DEP_CTRL module
    .data_dep_op_sel(data_dep_op_sel),
    // instruction_out pipeline <- from EXEC stage
    .instruction_out_exec_0(execute.instruction_out),
    .instruction_out_exec_1(execute.instruction_out_exec_0),
    .instruction_out_exec_2(execute.instruction_out_exec_1),
    .instruction_out_exec_3(execute.instruction_out_exec_2),
    // instruction_out pipeline <- from EXEC FLOATING stage
    .instruction_out_exec_floating_3(execute_floating_point.instruction_out_exec_floating_2),
    // register result <- from WRITE_BACK stage
    .result(result),
    
    /*
        WRITE BACK CONTROL
    */
    .backpressure_write_back(backpressure_write_back),
    
    /* 
        MEM CTRL SIGNALS 
    */
    .cpu_rst(cpu_rst) 
);

wire [`I_EXEC_SIZE-1:0] instruction_out_exec_3;

// 3rd parallel EXEC STAGE
execute execute
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst),
    .clk(clk),

    /*
        PIPELINE SIGNALS
    */
    // pipeline in <- from READ stage
    .instruction_in(instruction_out_read),
    // pipeline out -> to WRITE_BACK stage (4 internal delay registers)
    .instruction_out_exec_3(instruction_out_exec_3),

    /*
        FETCH CONTROL SIGNALS
    */
    // pc value <- from FETCH stage
    .pc(pc),
    // jmp control signals -> to FETCH stage
    .jmp_detected(jmp_detected),
    .jmp_pc(jmp_pc),

    /*
        MEM CONTROL SIGNALS
    */
    // address -> to MEM module external
    .address(address),
    // data to be saved in mem -> to MEM module external
    .data_out(data_out),
    // control signals for mem -> to MEM module external
    .read_mem(read_mem),
    .write_mem(write_mem),
    .data_in(data_in),
    
    /* 
        MEM CTRL SIGNALS 
    */
    .cpu_rst(cpu_rst)
);

wire [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_3;

// 3rd parallel FPU-only EXEC STAGE
execute_floating_point execute_floating_point
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst),
    .clk(clk),

    /*
        PIPELINE SIGNALS
    */
    // pipeline in <- from READ stage
    .instruction_in(instruction_out_read_floating),
    // pipeline out -> to WRITE_BACK stage
    .instruction_out_exec_floating_3(instruction_out_exec_floating_3),
    
    /* 
        MEM CTRL SIGNALS 
    */
    .cpu_rst(cpu_rst)
);

wire [`REG_A_SIZE:0] destination;

// 4th STAGE
write_back write_back
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst),
    .clk(clk),

    /*
        PIPELINE SIGNALS
    */
    // pipeline in <- from EXEC and EXEC_FPU stage
    .instruction_in(instruction_out_exec_3),
    .instruction_in_floating_point(instruction_out_exec_floating_3),
    // pipeline out -> to REGS module
    .destination_out(destination),
    .result_out(result),
    
    /*
        FETCH STAGE CONTROL
    */
    .backpressure_write_back(backpressure_write_back)
);

/**************************************
     REGISTER BLOCK INSTATIATION
***************************************/
regs regs
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst),
    .clk(clk),

    /*
        SIGNALS FROM STAGES
    */
    // input signals read stage
    .sel_op1(sel_op1),
    .sel_op2(sel_op2),
    // output signals for read stage
    .val_op1(val_op1),
    .val_op2(val_op2),
    // input signals write_back stage
    .destination(destination),
    .result(result),
    
    /* 
        MEM CTRL SIGNALS 
    */
    .cpu_rst(cpu_rst)
);

/**************************************
    DATA DEPENDECY CONTROL MODULE
          INSTANTIATION
***************************************/
data_dep_ctrl data_dep_ctrl
(
    /*
        GENERAL SIGNALS
    */
    .rst(rst),
    .clk(clk),

    /*
        SIGNALS FROM STAGES
    */
    // pipeline instruction signals to check
    // check the IN to READ stage and IN to EXEC stage
    .instruction_read_in(instruction_register_out),
    .instruction_exec_in(instruction_out_read),
    .instruction_exec_floating_in(instruction_out_read_floating),
    // check the IN to READ stage and IN to WB stage
    .instruction_wrback_in_exec_0(execute.instruction_out_exec_0),
    .instruction_wrback_in_exec_1(execute.instruction_out_exec_1),
    .instruction_wrback_in_exec_2(execute.instruction_out_exec_2),
    .instruction_wrback_in_exec_3(instruction_out_exec_3),
    .instruction_wrback_in_floating_0(execute_floating_point.instruction_out_exec_floating_0),
    .instruction_wrback_in_floating_1(execute_floating_point.instruction_out_exec_floating_1),
    .instruction_wrback_in_floating_2(execute_floating_point.instruction_out_exec_floating_2),
    .instruction_wrback_in_floating_3(instruction_out_exec_floating_3),

    // read stage control
    .data_dep_op_sel(data_dep_op_sel),
    .exec_dep_detected(exec_dep_detected),
    .wb_dep_detected(wb_dep_detected),
    .backpressure_exec_floating_dep(backpressure_exec_floating_dep)
);

endmodule
