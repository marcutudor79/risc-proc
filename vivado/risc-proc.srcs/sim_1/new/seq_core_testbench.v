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

module seq_core_testbench;

reg clk = 0;
reg rst = 1;
reg [`I_SIZE-1:0] instruction;
reg [`D_SIZE-1:0] data_in;

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
     
     // TC-4: Execute ADDF instrcution
     // Expect R2, R3 to double
     #10 instruction = {`ADDF, `R2, `R2, `R2};
     #10 instruction = {`ADDF, `R3, `R3, `R3};
     
     // TC-5: Execute SUB instrcution
     // Expect R2, R3 to have initial value
     #10 instruction = {`SUB, `R2, `R2, `R2};
     #10 instruction = {`SUB, `R3, `R3, `R3};
     
     // TC-6: Execute SUBF instruction
     // Expect R0, R1 to have initial value
     #10 instruction = {`SUBF, `R0, `R0, `R0};
     #10 instruction = {`SUBF, `R1, `R1, `R1};
     
     // TC-7: Execute AND instruction
     // Expect R1 to become 0
     #10 instruction = {`AND, `R1, `R0, `R1};
     // Expect R2 to become 0
     #10 instruction = {`AND, `R2, `R0, `R2};
     
     
     // TC-8: Execute OR instruction
     // Expect R4 to become 7
     #10 instruction = {`OR, `R4, `R3, `R4};
     // Expect R5 to become 7
     #10 instruction = {`OR, `R5, `R3, `R5};
     

end

endmodule
