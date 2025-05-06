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

module read(
    // general
    input 		rst,   // active 0
    input		clk,

    // pipeline in / out
    input [`I_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out_read,          // go to the execute stage
    output reg [`I_EXEC_SIZE-1:0] instruction_out_read_floating, // go to the execute_floating_point stage

    // registers write
    output reg [`REG_A_SIZE-1:0] sel_op1,
    output reg [`REG_A_SIZE-1:0] sel_op2,

    // registers read
    input wire [`D_SIZE-1:0] val_op1,
    input wire [`D_SIZE-1:0] val_op2,

    // data_dep_ctrl
    input wire [`OP_SEL_SIZE-1:0] data_dep_op_sel,
    input wire exec_dep_detected,
    input wire wb_dep_detected,
    input wire backpressure_exec_floating_dep,
    
    // write_back_ctrl
    input wire backpressure_write_back,

    // fast forward from EXEC stage
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec_0,
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec_1,
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec_2,
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec_3,

    // fast forward from EXEC_FLOATING stage
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_3,

    // fast forward from WB stage
    input wire [`D_SIZE-1:0] result,
    input wire [`D_SIZE-1:0] data_in,
    
    // memctrl interface
    input cpu_rst
);

/* internal variable to save the computed instruction
*/
reg [`I_EXEC_SIZE-1:0] instruction_out;


/*  1. Based on the instruction_in -> send to the register block
    the appropriate selection signals for the operands
*/
always @(*) begin
    casex(instruction_in[`I_OPCODE])

        `SHIFTR,
        `SHIFTL,
        `SHIFTRA,
        `JMP,
        `JMPRcond: begin
            // I_EXEC_DAT1
            sel_op1 = instruction_in[`I_OP0];
        end

        `LOADC: begin
            // I_EXEC_DAT1 - register value to be concat with constant
            sel_op1 = instruction_in[`I_LOADC_OP0];
         end

        `STORE: begin
            // I_EXEC_DAT1 - location to store data
            sel_op1 = instruction_in[`I_STORE_OP0];
            // I_EXEC_DAT2 - data to be stored
            sel_op2 = instruction_in[`I_STORE_OP1];
          end

        `LOAD: begin
            sel_op1 = instruction_in[`I_LOAD_OP1];
         end

        `JMPcond: begin
            // I_EXEC_DAT1
            sel_op1 = instruction_in[`I_JMPcond_OP0];
            // I_EXEC_DAT2
            sel_op2 = instruction_in[`I_JMPcond_OP1];
        end

        default: begin
            // I_EXEC_DAT1
            sel_op1 = instruction_in[`I_OP1];
            // I_EXEC_DAT2
            sel_op2 = instruction_in[`I_OP2];
        end
    endcase
end

/*   2. Compute the instruction_out register {IR, val_op1, val_op2} based on:
        - value of the operands read from the registers
        - the dependencies flags raised by the data_dep_ctrl module
*/
always @(*) begin

    // on reset, the computed instruction should be NOP for EXEC stage to do nothing
    // also reset the load_dep_op_sel register
    if (1'b0 == rst) begin
        instruction_out = {`NOP, 9'b0, val_op1, val_op2};
    end

    // if no reset, proceed further
    else begin
       /* Check if any depency flags are raised
          NOTE: In the case of SHIFT op:
                VAL_OP1 is VAL_OP0
                VAL_OP2 is X
       */
       // DEP DETECTED -> compute the instruction_out based on WB result or EXEC or EXEC FPU and reg block
       if ((1'b0 == exec_dep_detected) || (1'b0 == wb_dep_detected) ) begin
            case(data_dep_op_sel)
                `OVERRIDE_EXEC_0_DAT1: begin instruction_out = {instruction_in, instruction_out_exec_0[`I_EXEC_DAT2], val_op2}; end
    
                `OVERRIDE_EXEC_0_DAT2: begin instruction_out = {instruction_in, val_op1, instruction_out_exec_0[`I_EXEC_DAT2]}; end
    
                `OVERRIDE_EXEC_1_DAT1: begin instruction_out = {instruction_in, instruction_out_exec_1[`I_EXEC_DAT2], val_op2}; end
    
                `OVERRIDE_EXEC_1_DAT2: begin instruction_out = {instruction_in, val_op1, instruction_out_exec_1[`I_EXEC_DAT2]}; end
    
                `OVERRIDE_EXEC_2_DAT1: begin instruction_out = {instruction_in, instruction_out_exec_2[`I_EXEC_DAT2], val_op2}; end
    
                `OVERRIDE_EXEC_2_DAT2: begin instruction_out = {instruction_in, val_op1, instruction_out_exec_2[`I_EXEC_DAT2]}; end
    
                `OVERRIDE_EXEC_3_DAT1: begin instruction_out = {instruction_in, instruction_out_exec_3[`I_EXEC_DAT2], val_op2}; end
    
                `OVERRIDE_EXEC_3_DAT2: begin instruction_out = {instruction_in, val_op1, instruction_out_exec_3[`I_EXEC_DAT2]}; end
    
                `OVERRIDE_EXEC_FLOATING_3_DAT1: begin instruction_out = {instruction_in, instruction_out_exec_floating_3[`I_EXEC_DAT2], val_op2}; end
    
                `OVERRIDE_EXEC_FLOATING_3_DAT2: begin instruction_out = {instruction_in, val_op1, instruction_out_exec_floating_3[`I_EXEC_DAT2]}; end
    
                `OVERRIDE_RESREGS_DAT1: begin instruction_out = {instruction_in, result, val_op2}; end
    
                `OVERRIDE_RESREGS_DAT2: begin instruction_out = {instruction_in, val_op1, result}; end
    
           endcase

           // NO DEP -> directly compute the instruction with the values from reg block
           end else begin
                instruction_out = {instruction_in, val_op1, val_op2};
           end           
    end
end

/*
    3. Select via a multiplexer where the instruction_out needs to go
    -> to the EXEC stage (instruction_out)
    -> to the EXEC_FLOATING_POINT (instruction_out_floating_point)
*/
always @(posedge clk) begin

    if ((1'b0 == rst) || (1'b0 == cpu_rst)) begin 
        instruction_out_read          <= {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
        instruction_out_read_floating <= {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
    end
    
    else if (1'b1 == backpressure_write_back) begin
        casex(instruction_out[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                instruction_out_read_floating <= instruction_out;
                instruction_out_read          <= {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
            end
    
            default: begin
                instruction_out_read_floating <= {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
                instruction_out_read          <= instruction_out;
            end
        endcase
        
    // pipeline is backpressured by a concurrency at the input of WB stage
    end else if ((1'b0 == backpressure_write_back) || ( 1'b0 == backpressure_exec_floating_dep)) begin
        instruction_out_read_floating <= {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};      
        instruction_out_read          <= {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};        
    end
end

endmodule
