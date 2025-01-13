`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/19/2024 08:25:42 PM
// Design Name:
// Module Name: fetch
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

module fetch(
     // general
    input 		rst,   // active 0
    input		clk,
    // program memory & execute control
    output reg [`A_SIZE-1:0] pc_out,
    input  [`I_SIZE-1:0] instruction,
    // instruction register output
    output reg [`I_SIZE-1:0] instruction_register_out,
    // execute stage jmp control
    input wire jmp_detected,
    input wire [`A_SIZE-1:0] jmp_pc,
    // data_dep control
    input wire load_dep_detected,
    // fetch stage control
    input wire backpressure_wb_concurrency,
    input wire backpressure_exec_load
);

// internal variables of the fetch stage
reg [`I_SIZE-1:0] instruction_register;
reg [`A_SIZE-1:0] pc;
reg exception_detected;

/*
    1. Compute the IR and PC based on the jmp, load and rst signals
*/
always @(*) begin

    // always assume no exception is raised
    exception_detected   = 1'b1;
    instruction_register = instruction;

    /* if `JMP is executed, update pc with value from EXEC stage
       in the same clock cycle
       reason: get immediately the next instruction without instroducting
               incorrect instructions in the pipeline
     */
    if (1'b0 == jmp_detected) begin
        pc                   = jmp_pc;
        exception_detected   = 1'b0;
        // after pc is updated, get the instruction again
        instruction_register = instruction;
    end

    /* if backpressure_exec_load is 0, stop the pipeline from advancing
       reason: keep the current IR with the dependecy the same so
       the mem has time to reply in data_in

       if backpressure_write_back is 0, the pipeline is stopped
       because the EXEC result needs to be written back to the registers
    */
    else if ((1'b0 == backpressure_wb_concurrency) || (1'b0 == backpressure_exec_load)) begin
        pc                   = pc_out;
        exception_detected   = 1'b0;
        instruction_register = instruction_register_out;
    end

    /* if `HALT is the next instruction, stop the pipeline from advancing
    */
    else if (`HALT == instruction) begin
        pc                 = pc_out;
        exception_detected = 1'b0;
    end

    /* if rst is triggered, pc starts from 0
    */
    else if (1'b0 == rst) begin
        pc                 = 0;
        exception_detected = 1'b0;
    end
end

/*
    2. Sample the instruction_register and the PC, provide them to READ stage
*/
always @(posedge clk) begin

    // sample the instruction_register
    instruction_register_out <= instruction_register;

    // on exeption, sample the computed pc
    if (1'b0 == exception_detected) begin
        pc_out <= pc;
    end

    // otherwise continue executing
    else begin
        pc_out <= pc_out + 1;
    end

end
endmodule
