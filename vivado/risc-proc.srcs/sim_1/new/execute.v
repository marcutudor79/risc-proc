`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 12:07:12 AM
// Design Name: 
// Module Name: execute
// Project Name: 
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

module execute(
    input clk,
    input rst,
    
    // pipeline in/out
    input [`I_EXEC_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out,
    
    // memory control
    output reg [`A_SIZE-1:0] addr,
    output reg [`D_SIZE-1:0] data_out,
    
    // data_dep_ctrl control
    input wire data_dep_detected,  // active 0
    input wire data_dep_op_sel,    // select which operand to override with val_op_exec
    
    // fetch stage control
    input wire [`A_SIZE-1:0] pc,
    output reg jmp_detected, // active 0
    output reg [`A_SIZE-1:0] jmp_pc          
);

// exec fast register -> will override one of the values from read stage
reg [`D_SIZE-1:0] op1;
reg [`D_SIZE-1:0] op2;

// override one of the operands if data dependecy is detected 
always @(*) begin
     if (0'b0 == data_dep_detected) begin
           // by default, the result of arithmetic & logic op
           // is put in I_EXEC_DAT2, therefore, fastforward it
           // to the operands of execute stage
           case(data_dep_op_sel)
            `OVERRIDE_EXEC_DAT1: begin
                // override the op1 with the result from 
                // instruction_out
                op1 = instruction_out[`I_EXEC_DAT2];
                op2 = instruction_in [`I_EXEC_DAT2];
            end
            `OVERRIDE_EXEC_DAT2: begin
                op1 = instruction_in [`I_EXEC_DAT1];
                // override the op2 with the result from
                // instruction_out
                op2 = instruction_out[`I_EXEC_DAT2];
            end         
            endcase
     end

     else begin
        op2 = instruction_in[`I_EXEC_DAT2];
        op1 = instruction_in[`I_EXEC_DAT1];
     end
end

always @(posedge clk) begin
    
    // restore jmp_detected signal if last clock cylce was active
    if (1'b0 == jmp_detected)
        jmp_detected <= 1;
    
    // Set the instruction that was used in the instruction_out register
    instruction_out[`I_EXEC_SIZE-1:64] <= instruction_in[`I_EXEC_SIZE-1:64];
    
    // Set the computed operand in the op0 place
    casex(instruction_in[`I_EXEC_OPCODE])
        `ADD:       instruction_out[`I_EXEC_DAT2] <= op1 + op2;
        `ADDF:      instruction_out[`I_EXEC_DAT2] <= op1 + op2;
        `SUB:       instruction_out[`I_EXEC_DAT2] <= op1 - op2;
        `SUBF:      instruction_out[`I_EXEC_DAT2] <= op1 - op2;
        `AND:       instruction_out[`I_EXEC_DAT2] <= op1 & op2;
        `OR:        instruction_out[`I_EXEC_DAT2] <= op1 | op2;
        `XOR:       instruction_out[`I_EXEC_DAT2] <= op1 ^ op2;
        `NAND:      instruction_out[`I_EXEC_DAT2] <= ~(op1 & op2);
        `NOR:       instruction_out[`I_EXEC_DAT2] <= ~(op1 | op2);
        `NXOR:      instruction_out[`I_EXEC_DAT2] <= ~(op1 ^ op2);
        `SHIFTR:    instruction_out[`I_EXEC_DAT2] <= op1          >>  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `SHIFTRA:   instruction_out[`I_EXEC_DAT2] <= $signed(op1) >>> {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]}; 
        `SHIFTL:    instruction_out[`I_EXEC_DAT2] <= op1          <<  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `JMP:       begin
                        // read stage serts op0 in I_EXEC_DAT1 (op1)
                        jmp_pc       <= op1;
                        // set the signal to 0 to signal a jump to fetch
                        jmp_detected <= 1'b0;
                    end
        `JMPR:      begin
                        jmp_pc       <= pc + instruction_in[`I_EXEC_OFFSET];
                        // set the signal to 0 to detect a jump
                        jmp_detected <= 1'b0;
                    end
        `JMPcond:   begin
                    case (instruction_in[`I_EXEC_COND])
                        `N: if (op1 < 0) begin
                            jmp_pc <= op2;
                            end
                        `NN: if (op1 >= 0) begin
                            jmp_pc <= op2;
                            end
                        `Z: if (op1 == 0) begin
                            jmp_pc <= op2;
                            end
                        `NZ: if (op1 != 0) begin
                             jmp_pc <= op2;
                             end            
                    endcase
                    jmp_detected <= 0;
                    end
        `JMPRcond:  begin
                    case (instruction_in[`I_EXEC_COND])
                         `N: if (op1 < 0) begin
                             jmp_pc <= pc + instruction_in[`I_EXEC_OFFSET];
                             end
                        `NN: if (op1 >= 0) begin
                             jmp_pc <= pc + instruction_in[`I_EXEC_OFFSET];
                             end
                         `Z: if (op1 == 0) begin
                             jmp_pc <= pc + instruction_in[`I_EXEC_OFFSET];
                             end
                        `NZ: if (op1 != 0) begin
                             jmp_pc <= pc + instruction_in[`I_EXEC_OFFSET];
                             end            
                    endcase
                    jmp_detected <= 0;
                    end
    endcase
end

endmodule
