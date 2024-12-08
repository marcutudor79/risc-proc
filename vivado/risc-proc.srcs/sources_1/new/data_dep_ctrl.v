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
    
    // read stage hypervisor
    input      [`I_SIZE-1:0] instruction_read_in,
    output reg data_dep_detected,
    output reg data_dep_op_sel,
    
    // execution stage hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_exec_in
);
    
    // detect if the read block is going to 
    // get from registers the resulting operand 
    // the execution stage -> delay by 2 clock cycles
    always @(posedge clk) begin
        if (1'b0 == rst) begin
            data_dep_detected <= 1'b1;
        end
        
        if ((instruction_read_in[`I_OPCODE] != `NOP)&&(instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_OP0])) begin 
            data_dep_detected <= 1'b0;
            data_dep_op_sel   <= `OVERRIDE_EXEC_DAT1;
        end
        
        else if ((instruction_read_in[`I_OPCODE] != `NOP)&&(instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0])) begin
            data_dep_detected <= 1'b0;
            data_dep_op_sel   <= `OVERRIDE_EXEC_DAT1;
        end
        
        else begin
            data_dep_detected <= 1'b1;
        end
    end

endmodule
