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
    input      [`I_SIZE-1:0]       instruction_read_in,
    output reg                     data_dep_detected,
    output reg [`OP_SEL_SIZE-1:0]  data_dep_op_sel,
    
    // execution stage hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_exec_in,
    
    // write_back stage hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in,
    
    // registers stage hypervisor
    input      [`REG_A_SIZE-1:0] destination
);
    
    reg exec_dep_detected;
    reg wb_dep_detected;
    
    // detect if the read block is going to 
    // get from registers the resulting operand from
    // the execution stage -> override it with the result
    always @(posedge clk) begin
        if (1'b0 == rst) begin
            data_dep_detected <= 1'b1;
        end
        
        /*
            DETECT DEPENDENCIES BETWEEN READ & EXEC
        */
        casex(instruction_read_in[`I_OPCODE])
            `ADD,       
            `ADDF,   
            `SUB,   
            `SUBF,     
            `AND,      
            `OR,      
            `XOR,      
            `NAND,      
            `NOR,      
            `NXOR,  
            `SHIFTR,    
            `SHIFTRA,   
            `SHIFTL: begin
                casex (instruction_exec_in[`I_EXEC_OPCODE])
                    `ADD,       
                    `ADDF,   
                    `SUB,   
                    `SUBF,     
                    `AND,      
                    `OR,      
                    `XOR,      
                    `NAND,      
                    `NOR,      
                    `NXOR,  
                    `SHIFTR,    
                    `SHIFTRA,   
                    `SHIFTL: begin
                        /*
                            read - ARITHMETIC & LOGIC op
                            exec - ARITHMETIC & LOGIC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_EXEC_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_EXEC_DAT2;
                        end 
                    end
                    `LOAD: begin
                        /*
                            read - ARITHMETIC & LOGIC op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_MEM_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_MEM_DAT2;
                        end    
                    end 
                    `LOADC: begin
                         /*
                            read - ARITHMETIC & LOGIC op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_CONSTANT_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_CONSTANT_DAT2;
                        end
                    end
                endcase                   
            end   
            `LOAD,
            `STORE,
            `JMP: begin
                  casex (instruction_exec_in[`I_EXEC_OPCODE])
                    `ADD,       
                    `ADDF,   
                    `SUB,   
                    `SUBF,     
                    `AND,      
                    `OR,      
                    `XOR,      
                    `NAND,      
                    `NOR,      
                    `NXOR,  
                    `SHIFTR,    
                    `SHIFTRA,   
                    `SHIFTL: begin
                        /*
                            read - LOAD, STORE & JMP op
                            exec - ARITHMETIC & LOGIC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_EXEC_DAT2;
                        end
                    end
                    `LOAD: begin
                        /* 
                            read - LOAD, STORE & JMP op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_MEM_DAT2;
                        end
                    end 
                    `LOADC: begin
                         /*  
                            read - LOAD, STORE & JMP op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_CONSTANT_DAT2;
                        end
                    end
                endcase 
            end
            `JMPcond: begin
                casex (instruction_exec_in[`I_EXEC_OPCODE])
                    `ADD,       
                    `ADDF,   
                    `SUB,   
                    `SUBF,     
                    `AND,      
                    `OR,      
                    `XOR,      
                    `NAND,      
                    `NOR,      
                    `NXOR,  
                    `SHIFTR,    
                    `SHIFTRA,   
                    `SHIFTL: begin
                        /* 
                            read - JMPcond op
                            exec - ARITHMETIC & LOGIC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_EXEC_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                            data_dep_detected <= 0;
                            data_dep_op_sel   <= `OVERRIDE_EXEC_DAT2;
                        end
                    end
                    `LOAD: begin
                        /*         
                            read - JMPcond op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_MEM_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                            data_dep_detected <= 0;
                            data_dep_op_sel   <= `OVERRIDE_EXEC_DAT2;
                        end
                    end 
                    `LOADC: begin
                         /*
                            read - JMPcond op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_CONSTANT_DAT1;
                         end
                         else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                            data_dep_detected <= 0;
                            data_dep_op_sel   <= `OVERRIDE_EXEC_DAT2;
                         end
                    end
                endcase                 
            end
            `JMPRcond:  begin
                casex (instruction_exec_in[`I_EXEC_OPCODE])
                    `ADD,       
                    `ADDF,   
                    `SUB,   
                    `SUBF,     
                    `AND,      
                    `OR,      
                    `XOR,      
                    `NAND,      
                    `NOR,      
                    `NXOR,  
                    `SHIFTR,    
                    `SHIFTRA,   
                    `SHIFTL: begin
                        /*
                            read - JMPcond op
                            exec - ARITHMETIC & LOGIC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_EXEC_DAT1;
                        end
                    end
                    `LOAD: begin
                        /*
                            read - JMPcond op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_MEM_DAT1;
                        end
                    end 
                    `LOADC: begin
                         /*
                            read - JMPcond op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             data_dep_detected <= 0;
                             data_dep_op_sel   <= `OVERRIDE_CONSTANT_DAT1;
                         end
                    end
                endcase                           
            end
        endcase
    end
endmodule
