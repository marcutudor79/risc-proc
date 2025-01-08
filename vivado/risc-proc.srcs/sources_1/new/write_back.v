`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 10:40:03 PM
// Design Name: 
// Module Name: write_back
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

module write_back(
    // general 
    input clk,
    input rst,
    
    // memory control
    input [`D_SIZE-1:0]        data_in,
    
    // pipeline in 
    input [`I_EXEC_SIZE-1:0]   instruction_in,
    input [`I_EXEC_SIZE-1:0]   instruction_in_floating_point,

    // pipeline out 
    output reg [`REG_A_SIZE:0] destination,
    output reg [`D_SIZE-1:0]   result
);

always @(posedge clk) begin
    if (1'b0 == rst) begin
        result      <= 0;
        destination <= 0;
    end 
    
    // check in the pipeline if a NOP is received from EXEC and not from EXEC_FPU, continue with EXEC_FPU
    if ((`NOP == instruction_in[`I_EXEC_OPCODE]) || (`NOP != instruction_in_floating_point[`I_EXEC_OPCODE])) begin

        casex(instruction_in[`I_EXEC_OPCODE])
            `ADDF,        
            `SUBF: begin
                  result      <= instruction_in[`I_EXEC_DAT2];
                  destination <= instruction_in[`I_EXEC_OP0]; 
            end   
            
            default: begin
                destination   <= `OUT_OF_BOUND_REG;
            end
        endcase  
        
    end
    
    // check in the pipeline if a NOP is received from EXEC_FPU and not from EXEC, continue with EXEC
    else if ((`NOP == instruction_in[`I_EXEC_OPCODE]) || (`NOP != instruction_in_floating_point[`I_EXEC_OPCODE])) begin
         
         // Set the computed operand in the op0 place
        casex(instruction_in[`I_EXEC_OPCODE])
            `ADD,        
            `SUB,    
            `AND,    
            `OR,    
            `XOR,    
            `NAND,    
            `NOR,      
            `NXOR,     
            `SHIFTR,    
            `SHIFTRA,   
            `SHIFTL: begin
                  result      <= instruction_in[`I_EXEC_DAT2];
                  destination <= instruction_in[`I_EXEC_OP0]; 
            end   
            `LOADC: begin
                  destination <= instruction_in[`I_EXEC_LOAD_DEST]; 
                  result      <= instruction_in[`I_EXEC_DAT2];
            end 
            `LOAD: begin
                  result      <= data_in;
                  destination <= instruction_in[`I_EXEC_OP0];
            end
            
            default: begin
                destination   <= `OUT_OF_BOUND_REG;
            end
        endcase  
    
    end
    
    // a NOP is received from both EXEC stages, therefore do nothing
    else begin
        destination <= `OUT_OF_BOUND_REG;
    end
      
end


endmodule
