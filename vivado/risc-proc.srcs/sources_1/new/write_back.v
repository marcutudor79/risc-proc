`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/02/2024 10:40:03 PM
// Design Name:
// Module Name: write_back
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

module write_back(
    // general
    input clk,
    input rst,

    // memory control
    input [`D_SIZE-1:0]        data_in,

    // pipeline in
    input [`I_EXEC_SIZE-1:0]   instruction_in,
    input [`I_EXEC_SIZE-1:0]   instruction_in_floating_point,

    // pipeline out
    output reg [`REG_A_SIZE:0] destination_out,
    output reg [`D_SIZE-1:0]   result_out,

    // read stage control
    output reg backpressure_write_back
);

// internal variables of the WB stage
reg [`REG_A_SIZE:0] destination;
reg [`D_SIZE-1:0]   result;
reg exception_floating_point;
reg exception_backpressure;

/*  1. Compute the destination and result based on:
        - the instruction received from the EXEC stage
        - the instruction received from the EXEC_FPU stage
*/
always @(*) begin

    // assume that the result from EXEC_FLOATING_POINT is valid
    exception_floating_point = 1'b1;

    // assume that no stopping of the pipeline is needed
    exception_backpressure = 1'b1;

    /* if a reset is received, set the destination to `OUT_OF_BOUND_REG,
       such that the register block will do nothing
    */
    if (1'b0 == rst) begin
        destination = `OUT_OF_BOUND_REG;
    end

    // now there are 4 situations to consider:
    /* 1st situation:
       NOP is received from EXEC
       ADDF, SUBF is received from EXEC_FPU,
       -> fetch result from EXEC_FPU instruction
    */
    else if ((`NOP == instruction_in[`I_EXEC_OPCODE]) || (`NOP != instruction_in_floating_point[`I_EXEC_OPCODE])) begin

        if (1'b1 == exception_floating_point) begin
            casex(instruction_in_floating_point[`I_EXEC_OPCODE])
                `ADDF,
                `SUBF: begin
                    result      = instruction_in_floating_point[`I_EXEC_DAT2];
                    destination = instruction_in_floating_point[`I_EXEC_OP0];
                end
                // should never enter default case
                default: begin
                    destination = `OUT_OF_BOUND_REG;
                end
            endcase
        end

        // if a 2nd situation was detected, invalidate the result from EXEC_FPU
        else if (1'b0 == exception_floating_point) begin
            destination = `OUT_OF_BOUND_REG;
        end
    end

    /* 2nd situation:
       ADD, SUB, AND, OR, XOR, NAND, NOR, NXOR, SHIFTR, SHIFTRA, SHIFTL, LOADC, LOAD is received from EXEC
       NOP is received from EXEC_FPU,
       -> fetch result from EXEC instruction, the next EXEC_F result will not be taken into consideration
    */
    else if ((`NOP != instruction_in[`I_EXEC_OPCODE]) || (`NOP == instruction_in_floating_point[`I_EXEC_OPCODE])) begin
        exception_floating_point = 1'b0;

        casex(instruction_in[`I_EXEC_OPCODE])
            `ADD,
            `SUB,
            `AND,
            `OR,
            `XOR,
            `NAND,
            `NOR,
            `NXOR,
            `SHIFTR,
            `SHIFTRA,
            `SHIFTL: begin
                  result      = instruction_in[`I_EXEC_DAT2];
                  destination = instruction_in[`I_EXEC_OP0];
            end
            `LOADC: begin
                  destination = instruction_in[`I_EXEC_LOAD_DEST];
                  result      = instruction_in[`I_EXEC_DAT2];
            end
            // the data_in from mem is already embedded in the pipeline instruction from EXEC
            `LOAD: begin
                destination = instruction_in[`I_EXEC_OP0];
                result      = instruction_in[`I_EXEC_DAT2];
            end
            // should never enter default case
            default: begin
                destination = `OUT_OF_BOUND_REG;
            end
        endcase
    end

    /* 3rd situation:
       NOP is received from EXEC,
       NOP is received from EXEC_FPU,
       -> do nothing
    */
    else if ((`NOP == instruction_in[`I_EXEC_OPCODE]) || (`NOP == instruction_in_floating_point[`I_EXEC_OPCODE])) begin
        destination = `OUT_OF_BOUND_REG;
    end

    /* 4th situation:
       ADD, SUB, AND, OR, XOR, NAND, NOR, NXOR, SHIFTR, SHIFTRA, SHIFTL, LOADC, LOAD, STORE is received from EXEC
       ADDF, SUBF is received from EXEC_FPU,
       -> fetch result from EXEC_FPU instruction, and backpressure the pipeline
    */
    else begin
        if (1'b1 == backpressure_write_back) begin
            exception_backpressure = 1'b0;

            casex(instruction_in_floating_point[`I_EXEC_OPCODE])
                `ADDF,
                `SUBF: begin
                    result      = instruction_in_floating_point[`I_EXEC_DAT2];
                    destination = instruction_in_floating_point[`I_EXEC_OP0];
                end
                // should never enter default case
                default: begin
                    destination = `OUT_OF_BOUND_REG;
                end
            endcase
        end

        // backpressured pipeline -> write the EXEC result to unblock it
        else if (1'b0 == backpressure_write_back) begin
            casex(instruction_in[`I_EXEC_OPCODE])
                `ADD,
                `SUB,
                `AND,
                `OR,
                `XOR,
                `NAND,
                `NOR,
                `NXOR,
                `SHIFTR,
                `SHIFTRA,
                `SHIFTL: begin
                    result      = instruction_in[`I_EXEC_DAT2];
                    destination = instruction_in[`I_EXEC_OP0];
                end
                `LOADC: begin
                    destination = instruction_in[`I_EXEC_LOAD_DEST];
                    result      = instruction_in[`I_EXEC_DAT2];
                end
                // the data_in from mem is already embedded in the pipeline instruction from EXEC
                `LOAD: begin
                    destination = instruction_in[`I_EXEC_OP0];
                    result      = instruction_in[`I_EXEC_DAT2];
                end
                // should never enter default case
                default: begin
                    destination = `OUT_OF_BOUND_REG;
                end
            endcase
        end
    end

end

always @(posedge clk) begin

    if (1'b0 == exception_backpressure) begin
        backpressure_write_back <= 1'b0;
    end

    // sample the destionation
    destination_out <= destination;

    // sample the result
    result_out      <= result;

end


endmodule
