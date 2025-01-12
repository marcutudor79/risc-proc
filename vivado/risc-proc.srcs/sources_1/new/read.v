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
    input wire load_dep_detected,
    input wire [`D_SIZE-1:0] result,
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec,
    input wire [`D_SIZE-1:0] data_in
);

/*  register needed because if a load_dep_det is triggered,
    the memory replies 1 clk cycle later than the sampling of instruction_out
    -> therefore save the data_dep_op_sel and send a NOP through the pipeline
    -> then in the clk cycle in which memory replied, compute the instruction based on this reg
*/
reg [`OP_SEL_SIZE-1:0] load_dep_op_sel;

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
        `JMPRcond,
        `LOADC: begin
            // I_EXEC_DAT1
            sel_op1 = instruction_in[`I_OP0];
         end

         `STORE: begin
            // I_EXEC_DAT1 - location to store data
            sel_op1 = instruction_in[`I_OP0];
            // I_EXEC_DAT2 - data to be stored
            sel_op2 = instruction_in[`I_OP2];
          end

         `LOAD: begin
            sel_op1 = instruction_in[`I_OP2];
         end

        `JMPcond: begin
            // I_EXEC_DAT1
            sel_op1 = instruction_in[`I_OP0];
            // I_EXEC_DAT2
            sel_op2 = instruction_in[`I_OP2];
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
        load_dep_op_sel = `OVERRIDE_MEM_NONE;
    end

    // if no reset, proceed further
    else begin
       /* Check if any depency flags are raised
          NOTE: In the case of SHIFT op:
                VAL_OP1 is VAL_OP0
                VAL_OP2 is X
       */
       case(load_dep_op_sel)
             // NO LOAD DEP -> no load_dep detected for which the mem value is available
            `OVERRIDE_MEM_NONE: begin
               // OTHER DEP DETECTED -> compute the instruction_out based on WB result or EXEC exec_out and reg block
               if ((1'b0 == exec_dep_detected) || (1'b0 == wb_dep_detected) || (1'b0 == load_dep_detected)) begin
                    case(data_dep_op_sel)
                        `OVERRIDE_EXEC_DAT1: begin instruction_out = {instruction_in, instruction_out_exec[`I_EXEC_DAT2], val_op2}; end

                        `OVERRIDE_EXEC_DAT2: begin instruction_out = {instruction_in, val_op1, instruction_out_exec[`I_EXEC_DAT2]}; end

                        `OVERRIDE_RESREGS_DAT1: begin instruction_out = {instruction_in, result, val_op2}; end

                        `OVERRIDE_RESREGS_DAT2: begin instruction_out = {instruction_in, val_op1, result}; end

                         /*  For load depencies, one first needs to first send a NOP
                            through the pipeline and raise an internal flag load_dep_detected
                            (this is because the mem needs 1 clk cycle to reply)
                        */
                        `OVERRIDE_MEM_DAT1: begin instruction_out = {`NOP, 32'd0, 32'd0}; end

                        `OVERRIDE_MEM_DAT2: begin instruction_out = {`NOP, 32'd0, 32'd0}; end

                    endcase

               // NO DEP -> directly compute the instruction with the values from reg block
               end else begin
                    instruction_out = {instruction_in, val_op1, val_op2};
               end
            end

            // LOAD DEP -> compute instruction out based on value from MEM and reg block
            `OVERRIDE_MEM_DAT1: begin instruction_out = {instruction_in, data_in, val_op2}; end

            `OVERRIDE_MEM_DAT2: begin instruction_out = {instruction_in, val_op1, data_in}; end

       endcase
    end
end

/*
    3. Select via a multiplexer where the instruction_out needs to go
    -> to the EXEC stage (instruction_out)
    -> to the EXEC_FLOATING_POINT (instruction_out_floating_point)
*/
always @(posedge clk) begin

    // LOAD_DEP combinational logic control
    if (1'b0 == load_dep_detected) begin
        // set the delay register with the override operand position IF load_dep_detected flag is raised
        load_dep_op_sel <= data_dep_op_sel;
    end else begin
        // otherwise reset it to NONE
        load_dep_op_sel <= `OVERRIDE_MEM_NONE;
    end

    // based on instruction_out opcode, go to -> EXEC or EXEC_FLOATING_POINT stage (they are in parallel)
    casex(instruction_out[`I_EXEC_OPCODE])
        `ADDF,
        `SUBF: begin
            instruction_out_read_floating = instruction_out;
            instruction_out_read          = {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
        end

        default: begin
            instruction_out_read          = instruction_out;
            instruction_out_read_floating = {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
        end
    endcase
end

endmodule
