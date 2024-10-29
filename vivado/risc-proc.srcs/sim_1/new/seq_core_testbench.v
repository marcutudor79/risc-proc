`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2024 07:39:57 PM
// Design Name: 
// Module Name: seq_core_testbench
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
`include "seq_core_testbench.vh"

module seq_core_testbench;

reg clk = 0;
reg rst = 1;
reg [`I_SIZE-1:0] instruction;
reg [`D_SIZE-1:0] data_in;
reg [`I_SIZE-1:0] opcode;
reg [`A_SIZE-1:0] pc;

// instaniate dut 
seq_core seq_core 
(   
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .data_in(data_in)
);

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

// test dut
initial begin

     // TC-1: Reset the chip
    #10 rst = 0;
    #10 rst = 1;
    
     // TC-2: Execute 2 NOP
        instruction = {`NOP, `R0, `R0, `R0};
    #10 instruction = {`NOP, `R0, `R0, `R0};
    
     // TC-3: Execute ADD instrcution
     // Expect R0, R1 to double 
     #10 instruction = {`ADD, `R0, `R0, `R0};
     #10 instruction = {`ADD, `R1, `R1, `R1};
     `assert(seq_core.reg_block[`R0], 0)  // assert for the previous instruct

     
     // TC-4: Execute ADDF instrcution
     // Expect R2, R3 to double
     #10 instruction = {`ADDF, `R2, `R2, `R2};
        `assert(seq_core.reg_block[`R1], 2)
     #10 instruction = {`ADDF, `R3, `R3, `R3};
         `assert(seq_core.reg_block[`R2], 4)
     
     
     // TC-5: Execute SUB instrcution
     // Expect R2, R3 to be 0
     #10 instruction = {`SUB, `R2, `R2, `R2};
         `assert(seq_core.reg_block[`R3], 6)
     #10 instruction = {`SUB, `R3, `R3, `R3};
         `assert(seq_core.reg_block[`R2], 0)
     
     // TC-6: Execute SUBF instruction
     // Expect R0, R1 to be 0
     #10 instruction = {`SUBF, `R0, `R0, `R0};
         `assert(seq_core.reg_block[`R3], 0)
     #10 instruction = {`SUBF, `R1, `R1, `R1};
         `assert(seq_core.reg_block[`R0], 0)
     
     // TC-7: Execute AND instruction
     // Expect R1 to become 0
     #10 instruction = {`AND, `R1, `R0, `R1};
         `assert(seq_core.reg_block[`R1], 0)
     // Expect R2 to become 0
     #10 instruction = {`AND, `R2, `R0, `R2};
         `assert(seq_core.reg_block[`R1], 0)
     
     
     // TC-8: Execute OR instruction
     // Expect R4 to become 4
     #10 instruction = {`OR, `R4, `R3, `R4};
         `assert(seq_core.reg_block[`R2], 0)
     // Expect R5 to become 5
     #10 instruction = {`OR, `R5, `R3, `R5};
        `assert(seq_core.reg_block[`R4], 4)
     
     // TC-9: Execute XOR instruction 
     // Expect R0 to become 4
     #10 instruction = {`XOR, `R0, `R0, `R4};
         `assert(seq_core.reg_block[`R5], 5)
     // Expect R1 to become 5
     #10 instruction = {`XOR, `R1, `R1, `R5};
        `assert(seq_core.reg_block[`R0], 4)
    
     // TC-10: Execute NAND instruction
     // Expect R2 to become -1
     #10 instruction = {`NAND, `R2, `R2, `R2};
        `assert(seq_core.reg_block[`R1], 5)
     // Expect R3 to become -1
     #10 instruction = {`NAND, `R3, `R3, `R3};
        `assert(seq_core.reg_block[`R2], -1)
     
     // TC-11: Execute NOR instruction
     // Expect R2 to become 0
     #10 instruction = {`NOR, `R2, `R2, `R2};
        `assert(seq_core.reg_block[`R3], -1)
     // Expect R3 to become 0
     #10 instruction = {`NOR, `R3, `R3, `R3};
        `assert(seq_core.reg_block[`R2], 0)
     
     // TC-12: Execute NXOR instruction
     // Expect R0 to become -1
     #10 instruction = {`NXOR, `R0, `R0, `R0};
        `assert(seq_core.reg_block[`R3], 0)
     // Expect R1 to become -1
     #10 instruction = {`NXOR, `R1, `R1, `R1};
        `assert(seq_core.reg_block[`R0], -1)
     
     // TC-13: Execute SHIFTR
     // Expect R4 to become 3
     #10 instruction = {`SHIFTR, `R4, 6'd1};
        `assert(seq_core.reg_block[`R1], -1)
     // Expect R5 to become 3
     #10 instruction = {`SHIFTR, `R5, 6'd1};
        `assert(seq_core.reg_block[`R4], 2)
     
     // TC-14: Execute SHIFTRA
     // Expect R0 to become -2
         seq_core.reg_block[`R0] = -4;
         seq_core.reg_block[`R1] = -4;
     #10 instruction = {`SHIFTRA, `R0, 6'd1};
        `assert(seq_core.reg_block[`R5], 2)
     // Expect R1 to become -2
     #10 instruction = {`SHIFTRA, `R1, 6'd1};
        `assert(seq_core.reg_block[`R0], -2)
     
     // TC-15: Execute SHIFTL
     // Expect R4 to become 4
     #10 instruction = {`SHIFTL, `R4, 6'd1};
        `assert(seq_core.reg_block[`R1], -2)
     // Expect R5 to become 4
     #10 instruction = {`SHIFTL, `R5, 6'd1};
        `assert(seq_core.reg_block[`R4], 4)
        
     // TC-16: Execute LOAD
     opcode = `LOAD;
     // Expect R0 to become 0
     #10 instruction = {opcode[6:2], `R0, 5'b00000, `R3};
        `assert(seq_core.reg_block[`R5], 4)
     // Expect R1 to become 0
     #10 instruction = {opcode[6:2], `R1, 5'b00000, `R3};
        `assert(seq_core.reg_block[`R0], 0)
     #10`assert(seq_core.reg_block[`R1], 0)
        
     // TC-17: Execute LOADC
     opcode = `LOADC;
     // Expect R0 to become 10
     instruction = {opcode[6:2], `R0, 8'd10};
     #10 `assert(seq_core.reg_block[`R0], 10)
     // Expect R1 to become 10
     instruction = {opcode[6:2], `R1, 8'd10};
     #10 `assert(seq_core.reg_block[`R1], 10)
    
     // TC-18: Execute STORE
     opcode = `STORE;
     seq_core.reg_block[`R0] = 0;
     // Expect at address 0 in MEM to have 10
     instruction = {opcode[6:2], `R0, 5'b00000, `R1};
     #10 `assert(seq_core.mem.mem[seq_core.reg_block[`R0]], seq_core.reg_block[`R1])
     
     // TC-19: Execute JMP
     opcode = `JMP;
     instruction = {opcode[6:3], 9'd0, `R1};
     #10 `assert(seq_core.pc, seq_core.reg_block[`R1]);
     
        
end

endmodule
