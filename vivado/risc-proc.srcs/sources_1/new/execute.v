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
    output reg [`I_EXEC_SIZE-1:0] instruction_out_exec_3,

    // fetch stage control
    input wire [`A_SIZE-1:0] pc,
    output reg jmp_detected, // active 0
    output reg [`A_SIZE-1:0] jmp_pc,
    output reg backpressure_exec_load,

    // memory control
    output reg [`A_SIZE-1:0] address,
    output reg [`D_SIZE-1:0] data_out,
    output reg               read_mem,
    output reg               write_mem,
    
    // memory response
    input [`D_SIZE-1:0] data_in,
    
    // memctrl interface
    input cpu_rst
);

// internal variable to save the values
reg [`I_EXEC_SIZE-1:0] instruction_out;
reg backpressure_load;

// internal delay registers for the instruction_out_exec
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_0;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_1;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_2;

/* 1. Compute the instruction_out_exec combinationally
*/
always @(*) begin
    // assume no jump is excuted
    jmp_detected = 1'b1;
    
    // assume no load is executed
    backpressure_load = 1'b1;

    // Set the instruction_in bits in the instruction_out region, (the operands value are computed after this)
    instruction_out[`I_EXEC_INSTR] = instruction_in[`I_EXEC_INSTR];
    
    // Set data for op1 to 0 and data for op2 to 0 (data for op2 will be used for exec result)
    instruction_out[`I_EXEC_DAT1] = 32'd0;
    instruction_out[`I_EXEC_DAT2] = 32'd0;

    // By default, no MEM access should be
    read_mem  = `READ_DISABLED;
    write_mem = `WRITE_DISABLED;

    // Compute and set the result value in the op0 place
    casex(instruction_in[`I_EXEC_OPCODE])
        `ADD:       instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] + instruction_in[`I_EXEC_DAT2];
        `SUB:       instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] - instruction_in[`I_EXEC_DAT2];
        `AND:       instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] & instruction_in[`I_EXEC_DAT2];
        `OR:        instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] | instruction_in[`I_EXEC_DAT2];
        `XOR:       instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] ^ instruction_in[`I_EXEC_DAT2];
        `NAND:      instruction_out[`I_EXEC_DAT2] = ~(instruction_in[`I_EXEC_DAT1] & instruction_in[`I_EXEC_DAT2]);
        `NOR:       instruction_out[`I_EXEC_DAT2] = ~(instruction_in[`I_EXEC_DAT1] | instruction_in[`I_EXEC_DAT2]);
        `NXOR:      instruction_out[`I_EXEC_DAT2] = ~(instruction_in[`I_EXEC_DAT1] ^ instruction_in[`I_EXEC_DAT2]);
        `SHIFTR:    instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] >>  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `SHIFTRA:   instruction_out[`I_EXEC_DAT2] = $signed(instruction_in[`I_EXEC_DAT1]) >>> {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `SHIFTL:    instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] <<  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `JMP:       begin
                        // read stage serts op0 in I_EXEC_DAT1 (op1)
                        jmp_pc       = instruction_in[`I_EXEC_DAT1];
                        // set the signal to 0 to signal a jump to fetch
                        jmp_detected = 1'b0;
         end
        `JMPR:      begin
                        jmp_pc       = pc + instruction_in[`I_EXEC_OFFSET];
                        // set the signal to 0 to detect a jump
                        jmp_detected = 1'b0;
        end

        `JMPcond:   begin
                    case (instruction_in[`I_EXEC_COND])
                        `N: if (instruction_in[`I_EXEC_DAT1] < 0) begin
                            jmp_pc = instruction_in[`I_EXEC_DAT2];
                            end
                        `NN: if (instruction_in[`I_EXEC_DAT1] >= 0) begin
                            jmp_pc = instruction_in[`I_EXEC_DAT2];
                            end
                        `Z: if (instruction_in[`I_EXEC_DAT1] == 0) begin
                            jmp_pc = instruction_in[`I_EXEC_DAT2];
                            end
                        `NZ: if (instruction_in[`I_EXEC_DAT1] != 0) begin
                             jmp_pc = instruction_in[`I_EXEC_DAT2];
                             end
                    endcase
                    jmp_detected = 0;
         end
        `JMPRcond:  begin
                    case (instruction_in[`I_EXEC_COND])
                         `N: if (instruction_in[`I_EXEC_DAT1] < 0) begin
                             jmp_pc = pc + instruction_in[`I_EXEC_OFFSET];
                             end
                        `NN: if (instruction_in[`I_EXEC_DAT1] >= 0) begin
                             jmp_pc = pc + instruction_in[`I_EXEC_OFFSET];
                             end
                         `Z: if (instruction_in[`I_EXEC_DAT1] == 0) begin
                             jmp_pc = pc + instruction_in[`I_EXEC_OFFSET];
                             end
                        `NZ: if (instruction_in[`I_EXEC_DAT1] != 0) begin
                             jmp_pc = pc + instruction_in[`I_EXEC_OFFSET];
                             end
                    endcase
                    jmp_detected = 0;
         end
        `LOADC: begin
                instruction_out[`I_EXEC_DAT2] = {instruction_in[63:40], instruction_in[`I_EXEC_CONST]};
         end
        `LOAD: begin
              // the pipeline is not backpressured for load
              if (1'b1 == backpressure_exec_load) begin            
                  read_mem  = `READ_ACTIVE;
                  write_mem = `WRITE_DISABLED;
                  // select only the last A_SIZE bits from the register
                  address = instruction_in[41:32];
                  backpressure_load = 0;
              end
              else if (1'b0 == backpressure_exec_load) begin
                  instruction_out[`I_EXEC_DAT2] = data_in;
              end
        end
       `STORE: begin
               read_mem   = `READ_DISABLED;
               write_mem  = `WRITE_ACTIVE;
               // select only the last A_SIZE bits from the register
               address  = instruction_in[41:32];
               data_out = instruction_in[`I_EXEC_DAT2];
       end
    endcase
end

// 2. Sample the value of instruction_out and serve it to WRITE_BACK stage
always @(posedge clk) begin
    if ((1'b0 == rst) || (1'b0 == cpu_rst)) begin
        instruction_out_exec_0 <= {`NOP, `R0, `R0, `R0};
        instruction_out_exec_1 <= {`NOP, `R0, `R0, `R0};
        instruction_out_exec_2 <= {`NOP, `R0, `R0, `R0};
        instruction_out_exec_3 <= {`NOP, `R0, `R0, `R0};
    end
    else begin
        backpressure_exec_load <= backpressure_load;
        instruction_out_exec_0 <= instruction_out;
        instruction_out_exec_1 <= instruction_out_exec_0;
        instruction_out_exec_2 <= instruction_out_exec_1;
        instruction_out_exec_3 <= instruction_out_exec_2;
    end
end

endmodule
