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
    output reg [`I_EXEC_SIZE-1:0] instruction_out,
    
    // registers control
    output reg [`REG_A_SIZE-1:0] sel_op1,
    output reg [`REG_A_SIZE-1:0] sel_op2,
    
    // registers fetch
    input wire [`D_SIZE-1:0] val_op1,
    input wire [`D_SIZE-1:0] val_op2
);

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

always @(posedge clk) begin
    if (1'b0 == rst) begin
       instruction_out <= {`NOP, 9'b0, val_op1, val_op2};
    end
    else begin
       /* NOTE: In the case of SHIFT op:
                VAL_OP1 is VAL_OP0
                VAL_OP2 is X 
       */
       instruction_out <= {instruction_in, val_op1, val_op2};
    end
end

endmodule
