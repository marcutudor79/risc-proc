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
    output reg [`I_EXEC_SIZE-1:0] instruction_out, // go to the execute stage
    output reg [`I_EXEC_SIZE-1:0] instruction_out_floating_point, // go to the execute_floating_point stage
    
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
    input wire [`D_SIZE-1:0] result,
    input wire [`I_EXEC_SIZE-1:0] instruction_out_exec,
    input wire [`D_SIZE-1:0] data_in
);

/*
    maintain compatibility with the other depency flags
*/
reg [`OP_SEL_SIZE-1:0] load_dep_op_sel;
reg load_dep_detected;

/*  keep the instruction_out in one register 
    then based on the instruction opcode move it to 
    the appropriate output register -> to the EXEC stage or EXEC FPU stage
*/
reg [`I_EXEC_SIZE-1:0] instruction_out_temp;

/*
    1. Based on the instruction_in -> send to the register block
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
            sel_op1 = instruction_in_save[`I_OP0];
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

/* 
    2. Save in internal buffers the value of the instruction_in and operands from regs
    to avoid chaging the value of instruction_in by fetch while the instruction_out is processed
*/
reg [`I_SIZE-1:0] instruction_in_save;
reg [`D_SIZE-1:0] val_op1_save;
reg [`D_SIZE-1:0] val_op2_save;

always @(posedge clk) begin
    instruction_in_save <= instruction_in;
    val_op1_save <= val_op1;
    val_op2_save <= val_op2;
end

/*
    3. Write the instruction_out register {IR, val_op1, val_op2} based on:
        - value of the operands read from the registers
        - the dependencies flags raised by the data_dep_ctrl module 
        - the depency flag raised by the read module (load_dep_detected) - processed here due to the fact 
        a load depency is first raised by the exec module as exec_dep_detected, then in the next clock cycle
        it is transformed in load_dep_detected
*/
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
                    instruction_out_temp <= {instruction_in_save, instruction_out_exec[`I_EXEC_DAT2], val_op2_save};
                end
                `OVERRIDE_EXEC_DAT2: begin
                    #1 // avoid race conditions
                    instruction_out_temp <= {instruction_in_save, val_op1_save, instruction_out_exec[`I_EXEC_DAT2]};
                end
                `OVERRIDE_RESREGS_DAT1: begin
                    #1 // avoid race conditions
                    instruction_out_temp <= {instruction_in_save, result, val_op2_save}; 
                end
                `OVERRIDE_RESREGS_DAT2: begin
                    #1 // avoid race conditions
                    instruction_out_temp <= {instruction_in_save, val_op1_save, result}; 
                end
                
                /*  For load depencies, one first needs to first send a NOP 
                    through the pipeline and raise an internal flag load_dep_detected
                    (this is because the mem needs 1 clk cycle to reply)
                */
                `OVERRIDE_MEM_DAT1: begin
                    instruction_out_temp   <= {`NOP, 32'd0, 32'd0};
                    load_dep_op_sel   <= `OVERRIDE_MEM_DAT1;
                    load_dep_detected <= 1'b0;
                end 
                `OVERRIDE_MEM_DAT2: begin
                    instruction_out_temp   <= {`NOP, 32'd0, 32'd0};
                    load_dep_op_sel   <= `OVERRIDE_MEM_DAT2;
                    load_dep_detected <= 1'b0;
                end
            endcase 
       end
       
       /*
            For load dependecies, after mem replied, 
            load the the value from memory in the instruction_out
       */
       else if (1'b0 == load_dep_detected) begin
            if (`OVERRIDE_MEM_DAT1 == load_dep_op_sel) begin
                instruction_out_temp   <= {instruction_in, data_in, val_op2};
                load_dep_detected <= 1'b0;
            end else if (`OVERRIDE_MEM_DAT2 == load_dep_op_sel) begin
                instruction_out_temp   <= {instruction_in, val_op1, data_in};
                load_dep_detected <= 1'b0;
            end         
       end else begin
            instruction_out_temp <= {instruction_in, val_op1, val_op2};
       end
    end
end

/*
    4. Select via a multiplexer where the instruction_out_temp needs to go
    -> to the EXEC stage (instruction_out)
    -> to the EXEC_FLOATING_POINT (instruction_out_floating_point)
*/
always @(*) begin
    casex(instruction_out_temp[`I_EXEC_OPCODE])
        `ADDF,
        `SUBF: begin
            instruction_out_floating_point = instruction_out_temp;
            instruction_out                = {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
        end
        
        default: begin
            instruction_out                = instruction_out_temp;
            instruction_out_floating_point = {`NOP, `R0, `R0, `R0, 32'd0, 32'd0};
        end
    endcase
end

endmodule
