`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/13/2025 04:57:15 PM
// Design Name:
// Module Name: compute_dep_exec
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

module compute_dep_exec(
    input [`I_SIZE-1:0] instruction_read_in,
    input [`I_EXEC_SIZE-1:0] instruction_exec_in,
    input [`I_EXEC_SIZE-1:0] instruction_exec_floating_in,

    output reg exec_dep_detected,
    output reg [`OP_SEL_SIZE-1:0] data_dep_op_sel
);

/*
    DETECT DEPENDENCIES BETWEEN READ IN & (EXEC IN || EXEC FLOATING POINT IN)
*/
always @(*) begin

    // asume no dependecy is detected
    exec_dep_detected = 1'b1;

    // check between read & exec
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
                    exec - ARITHMETIC & LOGIC & SHIFT op

                    current exec instr has the output ==
                    current read instr operands (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
                else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT2;
                end
            end
            `LOAD,
            `LOADC: begin
                /*
                    read - ARITHMETIC & LOGIC op
                    exec - LOAD, LOADC op

                    current exec instr has the output ==
                    current read instr operands (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
                else if (instruction_read_in[`I_OP2] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT2;
                end
            end
        endcase end
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
                    read - SHIFT op
                    exec - ARITHMETIC & LOGIC & SHIFT op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
            `LOAD,
            `LOADC: begin
                /*
                    read - SHIFT op
                    exec - LOAD, LOADC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
        endcase end
        `LOAD: begin
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
                    read - LOAD op
                    exec - ARITHMETIC & LOGIC & SHIFT op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_LOAD_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
            `LOAD,
            `LOADC: begin
                /*
                    read - LOAD op
                    exec - LOAD, LOADC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_LOAD_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
        endcase end
        `LOADC: begin
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
                    read - LOADC op
                    exec - ARITHMETIC & LOGIC & SHIFT op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_LOADC_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
            `LOAD,
            `LOADC: begin
                /*
                    read - LOADC op
                    exec - LOAD, LOADC op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_LOADC_OP0] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
        endcase end
        `STORE: begin
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
                    read - STORE op
                    exec - ARITHMETIC & LOGIC & SHIFT op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_STORE_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
            `LOAD,
            `LOADC: begin
                /*
                    read - LOADC op
                    exec - LOAD, LOADC op

                    current exec instr has the output ==
                    current read instr operands (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_STORE_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
        endcase end
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
                    exec - ARITHMETIC & LOGIC & SHIFT op

                    current exec instr has the output ==
                    current read instr operand (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_JMPcond_OP0] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
                else if (instruction_read_in[`I_JMPcond_OP1] == instruction_exec_in[`I_EXEC_OP0]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT2;
                end
            end
            `LOAD,
            `LOADC: begin
                /*
                    read - LOADC op
                    exec - LOAD, LOADC op

                    current exec instr has the output ==
                    current read instr operands (additional 6 posedge delay
                    would be needed)
                */
                if (instruction_read_in[`I_STORE_OP1] == instruction_exec_in[`I_EXEC_LOAD_DEST]) begin
                    exec_dep_detected = 0;
                    data_dep_op_sel   = `OVERRIDE_EXEC_0_DAT1;
                end
            end
        endcase end
    endcase
end

endmodule
