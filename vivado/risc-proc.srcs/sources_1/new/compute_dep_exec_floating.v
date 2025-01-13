`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2025 09:24:13 PM
// Design Name: 
// Module Name: compute_dep_exec_floating
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


module compute_dep_exec_floating(
    input [`I_SIZE-1:0] instruction_read_in,
    input [`I_EXEC_SIZE-1:0] instruction_exec_in,
    input [`I_EXEC_SIZE-1:0] instruction_exec_floating_in,

    output reg exec_dep_detected,
    output reg [`OP_SEL_SIZE-1:0] data_dep_op_sel
);
    
always @(*) begin

    // assume no dep is detected
    exec_dep_detected = 1'b1;
    data_dep_op_sel   = `OVERRIDE_NONE;

    // check between read & exec floating point
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
        `NXOR: begin
        casex (instruction_exec_in[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                /*
                    read - ARITHMETIC & LOGIC op
                    exec - ARITHMETIC op

                    current exec instr has the output ==
                    current read instr operands (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT1;
                end
                else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT2;
                end
            end
        endcase end
        `SHIFTR,
        `SHIFTRA,
        `SHIFTL: begin
        casex (instruction_exec_in[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                /*
                    read - SHIFT op
                    exec - ARITHMETIC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT1;
                end
            end
        endcase end
        `LOAD: begin
        casex (instruction_exec_in[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                /*
                    read - LOAD op
                    exec - ARITHMETIC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_LOAD_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT1;
                end
            end
        endcase end
        `LOADC: begin
        casex (instruction_exec_in[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                /*
                    read - LOADC op
                    exec - ARITHMETIC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_LOADC_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT1;
                end
            end
        endcase end
        `STORE: begin
        casex (instruction_exec_in[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                /*
                    read - STORE op
                    exec - ARITHMETIC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_STORE_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT1;
                end
            end
        endcase end
        `JMPcond: begin
        casex (instruction_exec_in[`I_EXEC_OPCODE])
            `ADDF,
            `SUBF: begin
                /*
                    read - JMPcond op
                    exec - ARITHMETIC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_JMPcond_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT1;
                end
                else if (instruction_read_in[`I_JMPcond_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_FLOATING_3_DAT2;
                end
            end
        endcase end
    endcase
end
endmodule
