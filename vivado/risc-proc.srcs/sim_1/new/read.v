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
    input wire [`D_SIZE-1:0] val_op2,
    
    // data_dep_ctrl 
    input wire [`OP_SEL_SIZE-1:0] data_dep_op_sel,
    input wire exec_dep_detected,
    input wire wb_dep_detected,
    input wire [`D_SIZE-1:0] result,
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec,
    input wire [`D_SIZE-1:0] data_in
);

/*
    set this register to 0 if a load dependecy was detected
    set to 1 otherwise
*/
reg [`OP_SEL_SIZE-1:0] load_dep_detected;

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

reg [`I_SIZE-1:0] instruction_in_save;
reg [`D_SIZE-1:0] val_op1_save;
reg [`D_SIZE-1:0] val_op2_save;
always @(posedge clk) begin
    instruction_in_save <= instruction_in;
    val_op1_save <= val_op1;
    val_op2_save <= val_op2;
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
       if ((1'b0 == exec_dep_detected) || (1'b0 == wb_dep_detected)) begin
            case(data_dep_op_sel) 
                `OVERRIDE_EXEC_DAT1: begin
                    #1 // avoid race conditions
                    instruction_out <= {instruction_in_save, instruction_out_exec[`I_EXEC_DAT2], val_op2_save};
                end
                `OVERRIDE_EXEC_DAT2: begin
                    #1 // avoid race conditions
                    instruction_out <= {instruction_in_save, val_op1_save, instruction_out_exec[`I_EXEC_DAT2]};
                end
                `OVERRIDE_RESREGS_DAT1: begin
                    #1 // avoid race conditions
                    instruction_out <= {instruction_in_save, result, val_op2_save}; 
                end
                `OVERRIDE_RESREGS_DAT2: begin
                    #1 // avoid race conditions
                    instruction_out <= {instruction_in_save, val_op1_save, result}; 
                end
                `OVERRIDE_MEM_DAT1: begin
                    instruction_out   <= {`NOP, 32'd0, 32'd0};
                    load_dep_detected <= `OVERRIDE_MEM_DAT1;
                end 
                `OVERRIDE_MEM_DAT2: begin
                    instruction_out   <= {`NOP, 32'd0, 32'd0};
                    load_dep_detected <= `OVERRIDE_MEM_DAT2;
                end
            endcase 
       end
       else begin
            if (`OVERRIDE_MEM_DAT1 == load_dep_detected) begin
                instruction_out   <= {instruction_in, data_in, val_op2};
                load_dep_detected <= 1'b0;
            end else if (`OVERRIDE_MEM_DAT2 == load_dep_detected) begin
                instruction_out   <= {instruction_in, val_op1, data_in};
                load_dep_detected <= 1'b0;
            end else begin
                instruction_out   <= {instruction_in, val_op1, val_op2};
                load_dep_detected <= 1'b0;
            end
       end
    end
end

endmodule
