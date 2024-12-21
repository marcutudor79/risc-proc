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
    
    // read stage hypervisor & control
    input      [`I_SIZE-1:0]      instruction_read_in,
    output reg [`OP_SEL_SIZE-1:0] data_dep_op_sel,
    output reg                    exec_dep_detected, // fast forward the result from exec to an operand of read_out
    output reg                    wb_dep_detected,   // fast forward the result from wb to an operand of read_out
    output reg                    load_dep_detected, // fast forward the result from mem to an operand in read_out

    // exec stage hypervisor 
    input      [`I_EXEC_SIZE-1:0] instruction_exec_in,
    
    // write_back stage hypervisor
    input      [`I_EXEC_SIZE-1:0] instruction_wrback_in
); 
    // detect if the read block is going to 
    // get from registers the resulting operand from
    // the execution stage -> override it with the result
    always @(*) begin
    
        if (1'b0 == rst) begin
            exec_dep_detected = 1'b1;
            wb_dep_detected   = 1'b1;
            load_dep_detected = 1'b1;
        end else if (1'b0 == exec_dep_detected) begin
            exec_dep_detected = 1;
        end else if (1'b0 == load_dep_detected) begin
            load_dep_detected = 1;
        end 
        
        /*
            DETECT DEPENDENCIES BETWEEN READ IN & EXEC IN
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
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT2;
                        end 
                    end
                    `LOAD: begin
                        /*
                            read - ARITHMETIC & LOGIC op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_MEM_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_MEM_DAT2;
                        end   
                    end 
                    `LOADC: begin
                         /*
                            read - ARITHMETIC & LOGIC op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0; 
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT2;
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
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT2;
                        end
                        else begin
                            exec_dep_detected = 1;
                        end
                    end
                    `LOAD: begin
                        /* 
                            read - LOAD, STORE & JMP op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_MEM_DAT2;
                         end
                         else begin
                            exec_dep_detected = 1;
                         end
                    end 
                    `LOADC: begin
                         /*  
                            read - LOAD, STORE & JMP op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT2;
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
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                            exec_dep_detected = 0;
                            data_dep_op_sel   = `OVERRIDE_EXEC_DAT2;
                        end
                    end
                    `LOAD: begin
                        /*         
                            read - JMPcond op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_MEM_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                            exec_dep_detected = 0;
                            load_dep_detected = 0;
                            data_dep_op_sel   = `OVERRIDE_MEM_DAT2;
                        end
                    end 
                    `LOADC: begin
                         /*
                            read - JMPcond op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT1;
                         end
                         else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                            exec_dep_detected = 0;
                            data_dep_op_sel   = `OVERRIDE_EXEC_DAT2;
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
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT1;
                        end
                    end
                    `LOAD: begin
                        /*
                            read - JMPcond op
                            exec - LOAD op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_MEM_DAT1;
                         end
                    end 
                    `LOADC: begin
                         /*
                            read - JMPcond op
                            exec - LOADC op 
                            
                            current exec instr has the output ==
                            current read instr operands (additional 3 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                             exec_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_EXEC_DAT1;
                         end
                      end
                endcase
              end                           
        endcase
    end
    
    always @(*) begin
        if (1'b0 == wb_dep_detected) begin
            wb_dep_detected = 1;
        end 
    
         /*
            DETECT DEPENDENCIES BETWEEN READ IN & WRITE_BACK IN
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
                casex (instruction_wrback_in[`I_EXEC_OPCODE])
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
                            read   - ARITHMETIC & LOGIC op
                            wrback - ARITHMETIC & LOGIC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP1] == instruction_wrback_in[`I_EXEC_OP0]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_OP0]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end 
                    end
                    `LOAD: begin
                        /*
                            read   - ARITHMETIC & LOGIC op
                            wrback - LOAD op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP1] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end  
                    end 
                    `LOADC: begin
                         /*
                            read   - ARITHMETIC & LOGIC op
                            wrback - LOADC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP1] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0; 
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end
                    end
                endcase                   
            end   
            `LOAD,
            `STORE,
            `JMP: begin
                  casex (instruction_wrback_in[`I_EXEC_OPCODE])
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
                            read   - LOAD, STORE & JMP op
                            wrback - ARITHMETIC & LOGIC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_OP0]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end
                    end
                    `LOAD: begin
                        /* 
                            read   - LOAD, STORE & JMP op
                            wrback - LOAD op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                         end
                    end 
                    `LOADC: begin
                         /*  
                            read   - LOAD, STORE & JMP op
                            wrback - LOADC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;                 
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end
                    end
                endcase 
            end
            `JMPcond: begin
                casex (instruction_wrback_in[`I_EXEC_OPCODE])
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
                            read   - JMPcond op
                            wrback - ARITHMETIC & LOGIC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_wrback_in[`I_EXEC_OP0]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_OP0]) begin
                            wb_dep_detected   = 0;
                            data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end
                    end
                    `LOAD: begin
                        /*         
                            read   - JMPcond op
                            wrback - LOAD op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             load_dep_detected = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                        end
                        else if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                            wb_dep_detected   = 0;
                            load_dep_detected = 0;
                            data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                        end
                    end 
                    `LOADC: begin
                         /*
                            read   - JMPcond op
                            wrback - LOADC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                         end
                         else if (instruction_read_in[`I_OP2] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                            wb_dep_detected   = 0;
                            data_dep_op_sel   = `OVERRIDE_RESREGS_DAT2;
                         end
                    end
                endcase                 
            end
            `JMPRcond:  begin
                casex (instruction_wrback_in[`I_EXEC_OPCODE])
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
                            read   - JMPcond op
                            wrback - ARITHMETIC & LOGIC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                        if (instruction_read_in[`I_OP0] == instruction_wrback_in[`I_EXEC_OP0]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                        end
                    end
                    `LOAD: begin
                        /*
                            read   - JMPcond op
                            wrback - LOAD op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                         end
                    end 
                    `LOADC: begin
                         /*
                            read   - JMPcond op
                            wrback - LOADC op 
                            
                            current wrback instr has the output ==
                            current read instr operands (additional 2 posedge delay
                            would be needed)
                        */
                         if (instruction_read_in[`I_OP0] == instruction_wrback_in[`I_EXEC_LOAD_DEST]) begin
                             wb_dep_detected   = 0;
                             data_dep_op_sel   = `OVERRIDE_RESREGS_DAT1;
                         end
                    end
                endcase                           
            end
        endcase
    end    
    

endmodule

