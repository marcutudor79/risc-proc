`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2024 08:52:48 PM
// Design Name:
// Module Name: data_dep_ctrl
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

module data_dep_ctrl(
    // general
    input rst,
    input clk,

    // read stage input hypervisor & control
    input      [`I_SIZE-1:0]       instruction_read_in,
    output reg [`OP_SEL_SIZE-1:0]  data_dep_op_sel,
    output reg                     exec_dep_detected, // fast forward the result from exec to an operand of read_out
    output reg                     wb_dep_detected,   // fast forward the result from wb to an operand of read_out
    output reg                     backpressure_exec_floating_dep,
    
    // exec stage input hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_exec_in,

    // exec_floating_point stage input hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_exec_floating_in,

    // write_back stage input hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_exec_0,
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_exec_1,
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_exec_2,
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_exec_3,

    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_floating_0,
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_floating_1,
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_floating_2,
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in_floating_3
);

// internal variables
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_0;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_1;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_2;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_3;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_4;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_5;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_6;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_7;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_8;
wire [`OP_SEL_SIZE-1:0] data_dep_op_sel_9;

wire exec_dep_detected_0;
wire exec_dep_detected_1;

wire wb_dep_detected_0;
wire wb_dep_detected_1;
wire wb_dep_detected_2;
wire wb_dep_detected_3;
wire wb_dep_detected_4;

always @(*) begin
    
    // assume no dependency
    exec_dep_detected = 1'b1;
    wb_dep_detected   = 1'b1;
    backpressure_exec_floating_dep = 1'b1;
    
    // dep is detected between READ IN & EXEC IN
    if (`OVERRIDE_NONE != data_dep_op_sel_0) begin
        data_dep_op_sel   = data_dep_op_sel_0;
        exec_dep_detected = exec_dep_detected_0;
    end
    
    // special case: if dep is detected between READ IN & EXEC FLOATING IN - backpressure the pipeline 3 clk cycles
    else if (`OVERRIDE_NONE != data_dep_op_sel_1) begin
        backpressure_exec_floating_dep = 0;
    end
    
    else if (`OVERRIDE_NONE != data_dep_op_sel_6) begin
        backpressure_exec_floating_dep = 0;
    end
    
    else if (`OVERRIDE_NONE != data_dep_op_sel_7) begin
        backpressure_exec_floating_dep = 0;
    end
    
    else if (`OVERRIDE_NONE != data_dep_op_sel_8) begin
        data_dep_op_sel = data_dep_op_sel_9;
        wb_dep_detected = wb_dep_detected_4;
    end
    
    // dep is detected between READ IN & EXEC OUT 0
    else if (`OVERRIDE_NONE != data_dep_op_sel_2) begin
        data_dep_op_sel = data_dep_op_sel_2;
        wb_dep_detected = wb_dep_detected_0;
    end
    
    // dep is detected between READ IN & EXEC OUT 1
    else if (`OVERRIDE_NONE != data_dep_op_sel_3) begin
        data_dep_op_sel = data_dep_op_sel_3;
        wb_dep_detected = wb_dep_detected_1;
    end
    
    // dep is detected between READ IN & EXEC OUT 2
    else if (`OVERRIDE_NONE != data_dep_op_sel_4) begin
        data_dep_op_sel = data_dep_op_sel_4;
        wb_dep_detected = wb_dep_detected_2;
    end
    
    // dep is detected between READ IN & EXEC OUT 3
    else if (`OVERRIDE_NONE != data_dep_op_sel_5) begin
        data_dep_op_sel = data_dep_op_sel_5;
        wb_dep_detected = wb_dep_detected_3;
    end
    
    // dep is detected between READ IN & EXEC FLOATING OUT 3
    else if (`OVERRIDE_NONE != data_dep_op_sel_6) begin
        data_dep_op_sel = data_dep_op_sel_6;
        wb_dep_detected = wb_dep_detected_4;
    end
end

/*
    DETECT DEPENDENCIES BETWEEN READ IN & EXEC IN 
    -> fast forward the result from instruction_exec_out_0
*/
compute_dep_exec read_in_exec_in
(
    .instruction_read_in(instruction_read_in),
    .instruction_exec_in(instruction_exec_in),
    .instruction_exec_floating_in(instruction_exec_floating_in),
    .exec_dep_detected(exec_dep_detected_0),
    .data_dep_op_sel(data_dep_op_sel_0)
);

/*
    DETECT DEPENDENCIES BETWEEN READ IN & EXEC FLOATING IN
    -> block the pipeline for 3 clock cycles, leave time for the EXEC FLOATING to finish
    -> fast forward the result from instruction_exec_out_0
*/
compute_dep_exec_floating read_in_exec_floating_in
(
    .instruction_read_in(instruction_read_in),
    .instruction_exec_floating_in(instruction_exec_floating_in),
    .exec_dep_detected(exec_dep_detected_1),
    .data_dep_op_sel(data_dep_op_sel_1)
);

/*
    DETECT DEPENDENCIES BETWEEN READ IN & WRITE_BACK IN
*/
compute_dep_wb read_in_exec_out_0
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_exec_0),
    .wb_dep_detected(wb_dep_detected_0),
    .data_dep_op_sel(data_dep_op_sel_2),
    .override_dat1(`OVERRIDE_EXEC_1_DAT1),
    .override_dat2(`OVERRIDE_EXEC_1_DAT2)
);

compute_dep_wb read_in_exec_out_1
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_exec_1),
    .wb_dep_detected(wb_dep_detected_1),
    .data_dep_op_sel(data_dep_op_sel_3),
    .override_dat1(`OVERRIDE_EXEC_2_DAT1),
    .override_dat2(`OVERRIDE_EXEC_2_DAT2)
);

compute_dep_wb read_in_exec_out_2
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_exec_2),
    .wb_dep_detected(wb_dep_detected_2),
    .data_dep_op_sel(data_dep_op_sel_4),
    .override_dat1(`OVERRIDE_EXEC_3_DAT1),
    .override_dat2(`OVERRIDE_EXEC_3_DAT2)
);

compute_dep_wb read_in_exec_out_3
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_exec_3),
    .wb_dep_detected(wb_dep_detected_3),
    .data_dep_op_sel(data_dep_op_sel_5),
    .override_dat1(`OVERRIDE_RESREGS_DAT1),
    .override_dat2(`OVERRIDE_RESREGS_DAT2)
);

compute_dep_wb read_in_exec_floating_out_0
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_floating_0),
    .data_dep_op_sel(data_dep_op_sel_6),
    .override_dat1(`OVERRIDE_EXEC_FLOATING_3_DAT1),
    .override_dat2(`OVERRIDE_EXEC_FLOATING_3_DAT2)
);

compute_dep_wb read_in_exec_floating_out_1
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_floating_1),
    .data_dep_op_sel(data_dep_op_sel_7),
    .override_dat1(`OVERRIDE_EXEC_FLOATING_3_DAT1),
    .override_dat2(`OVERRIDE_EXEC_FLOATING_3_DAT2)
);

// note: for the EXEC FLOATING stage, the result is only ready in
// the last register out of the 4 delay registers
compute_dep_wb read_in_exec_floating_out_2
(
    .instruction_read_in(instruction_read_in),
    .instruction_wrback_in(instruction_wrback_in_floating_2),
    .wb_dep_detected(wb_dep_detected4),
    .data_dep_op_sel(data_dep_op_sel_8),
    .override_dat1(`OVERRIDE_EXEC_FLOATING_3_DAT1),
    .override_dat2(`OVERRIDE_EXEC_FLOATING_3_DAT2)
);


endmodule

