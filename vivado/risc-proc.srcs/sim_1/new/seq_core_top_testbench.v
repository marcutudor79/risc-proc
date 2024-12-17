`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 12:49:42 PM
// Design Name: 
// Module Name: seq_core_top_testbench
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

module seq_core_top_testbench;

reg clk = 0;
reg rst = 1;
reg [`I_SIZE-1:0] instruction;
reg [`D_SIZE-1:0] data_in;
reg [`I_SIZE-1:0] opcode;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

/***************************************
  SEQ_CORE_TOP AND SEQ_CORE_GOLDEN DUT
****************************************/

// risc core 4stage pipeline
seq_core_top seq_core_top
(
    .clk(clk),
    .rst(rst),
    .instruction(instruction)
);

// risc core golden model
seq_core seq_core
(
    .clk(clk),
    .rst(rst),
    .instruction(instruction)
);

/************************************
               TESTS
*************************************/
initial begin

    // TC-1: Reset the chips 
    #10 rst = 0;
    
    // Expect that all registers and PC are cleared
    #10 `assert(seq_core_top.pc, 0)
        `assert(seq_core.pc, 0)
        
        `assert(seq_core_top.regs.reg_block[`R0], 0)
        `assert(seq_core_top.regs.reg_block[`R1], 0)
        `assert(seq_core_top.regs.reg_block[`R2], 0)
        `assert(seq_core_top.regs.reg_block[`R3], 0)
        `assert(seq_core_top.regs.reg_block[`R4], 0)
        `assert(seq_core_top.regs.reg_block[`R5], 0)
        `assert(seq_core_top.regs.reg_block[`R6], 0)
        `assert(seq_core_top.regs.reg_block[`R7], 0)
        
        `assert(seq_core.reg_block[`R0], 0)
        `assert(seq_core.reg_block[`R1], 0)
        `assert(seq_core.reg_block[`R2], 0)
        `assert(seq_core.reg_block[`R3], 0)
        `assert(seq_core.reg_block[`R4], 0)
        `assert(seq_core.reg_block[`R5], 0)
        `assert(seq_core.reg_block[`R6], 0)
        `assert(seq_core.reg_block[`R7], 0)
        
    /*******************************************************************
       TEST THE INSTRUCTION EXECUTION - ARITMHETHIC & LOGIC & NOP & HALT
                    - NO DATA DEPENDECIES -
       TEST THE REGISTER BLOCK - WRITE & READ
    *******************************************************************/
    
    
    // TC-2: Execute NOP instruction
    #10 rst         = 1;
        instruction = {`NOP, `R0, `R0, `R0};
         
    // Expect the registers to remain unchanged
    #100 `assert(seq_core_top.pc, seq_core.pc)
    
        `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0])
        `assert(seq_core_top.regs.reg_block[`R1], seq_core.reg_block[`R1])
        `assert(seq_core_top.regs.reg_block[`R2], seq_core.reg_block[`R2])
        `assert(seq_core_top.regs.reg_block[`R3], seq_core.reg_block[`R3])
        `assert(seq_core_top.regs.reg_block[`R4], seq_core.reg_block[`R4])
        `assert(seq_core_top.regs.reg_block[`R5], seq_core.reg_block[`R5])
        `assert(seq_core_top.regs.reg_block[`R6], seq_core.reg_block[`R6])
        `assert(seq_core_top.regs.reg_block[`R7], seq_core.reg_block[`R7])
        
   // TC-3: Execute ADD instruction
        seq_core_top.regs.reg_block[`R1] = 1;
        seq_core_top.regs.reg_block[`R2] = 2;
        seq_core.reg_block[`R1] = 1;
        seq_core.reg_block[`R2] = 2;
        instruction = {`ADD, `R0, `R1, `R2};
         
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0])        
    
    // TC-4: Execute ADDF instruction
    // Flush the Pipeline    
        rst = 0; 
    #10 rst = 1;   
    
        seq_core_top.regs.reg_block[`R1] = 1;
        seq_core_top.regs.reg_block[`R2] = 2;
        seq_core.reg_block[`R1] = 1;
        seq_core.reg_block[`R2] = 2;
        instruction = {`ADDF, `R0, `R1, `R2};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0]) 
    
    
    // TC-5: EXECUTE SUB instruction
    // Flush the Pipeline
        rst = 0;
    #10 rst = 1;
    
        seq_core_top.regs.reg_block[`R3] = 3;
        seq_core_top.regs.reg_block[`R4] = 4;
        seq_core.reg_block[`R3] = 3;
        seq_core.reg_block[`R4] = 4;
        instruction = {`SUB, `R0, `R4, `R3};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0]) 
    
    // TC-6: EXECUTE SUBF instruction
    // Flush the Pipeline
        rst = 0;
    #10 rst = 1;
    
        seq_core_top.regs.reg_block[`R3] = 3;
        seq_core_top.regs.reg_block[`R4] = 4;
        seq_core.reg_block[`R3] = 3;
        seq_core.reg_block[`R4] = 4;
        instruction = {`SUBF, `R0, `R4, `R3};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0]) 
    
    // TC-7: EXECUTE AND instruction
    // Flush the Pipeline
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R5] = 0;
        seq_core_top.regs.reg_block[`R6] = 1;
        seq_core.reg_block[`R5] = 0;
        seq_core.reg_block[`R6] = 1;
        instruction = {`AND, `R0, `R5, `R6};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0]) 
    
    // TC-8: EXECUTE OR instruction
    // Flush the Pipeline
        rst = 0;
   #10  rst = 1;
        seq_core_top.regs.reg_block[`R7] = 0;
        seq_core_top.regs.reg_block[`R6] = 1;
        seq_core.reg_block[`R7] = 0;
        seq_core.reg_block[`R6] = 1;
        instruction = {`AND, `R0, `R7, `R6};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0]) 
    
    // TC-9: EXECUTE XOR instruction
    // Flush the Pipeline
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R1] = 32'hBABA;
        seq_core_top.regs.reg_block[`R2] = 32'hABAB;
        seq_core.reg_block[`R1] = 32'hBABA;
        seq_core.reg_block[`R2] = 32'hABAB;
        instruction = {`XOR, `R0, `R1, `R2};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0]) 
    
    // TC-10; EXECUTE NAND instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R1] = 32'hBABA;
        seq_core_top.regs.reg_block[`R2] = 32'hABAB;
        seq_core.reg_block[`R1] = 32'hBABA;
        seq_core.reg_block[`R2] = 32'hABAB;
        instruction = {`NAND, `R0, `R1, `R2};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0])
    
    // TC-11: EXECUTE NOR instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R1] = 32'hBABA;
        seq_core_top.regs.reg_block[`R2] = 32'hABAB;
        seq_core.reg_block[`R1] = 32'hBABA;
        seq_core.reg_block[`R2] = 32'hABAB;
        instruction = {`NOR, `R0, `R1, `R2};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0])
    
    // TC-12: EXECUTE NXOR instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R1] = 32'hBABA;
        seq_core_top.regs.reg_block[`R2] = 32'hABAB;
        seq_core.reg_block[`R1] = 32'hBABA;
        seq_core.reg_block[`R2] = 32'hABAB;
        instruction = {`NXOR, `R0, `R1, `R2};
    #60 `assert(seq_core_top.regs.reg_block[`R0], seq_core.reg_block[`R0])
    
    
    // TC-13: EXECUTE SHIFTR instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R4] = 4;
        seq_core.reg_block[`R4]          = 4;
        instruction = {`SHIFTR, `R4, 6'd1};
    // Switch the instruction to NOP -> such that the golden model will report the true value
    // 5 clock cycles diff between golden model and seq_core with pipeline
    #10 instruction = {`NOP, `R0, `R0, `R0};
    #60 `assert(seq_core_top.regs.reg_block[`R4], seq_core.reg_block[`R4])
    
    
    // TC-14: EXECUTE SHIFTRA instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R5] = -4;
        seq_core.reg_block[`R5]          = -4;
        instruction = {`SHIFTRA, `R5, 6'd1};
        // Switch the instruction to NOP -> such that the golden model will report the true value
        // 5 clock cycles diff between golden model and seq_core with pipeline
        #10 instruction = {`NOP, `R0, `R0, `R0};
        #60 `assert(seq_core_top.regs.reg_block[`R5], seq_core.reg_block[`R5])
        
    // TC-15: EXECUTE SHIFTL instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R6] = 2;
        seq_core.reg_block[`R6]          = 2;
        instruction = {`SHIFTL, `R6, 6'd1};
        // Switch the instruction to NOP -> such that the golden model will report the true value
        // 5 clock cycles diff between golden model and seq_core with pipeline
        #10 instruction = {`NOP, `R0, `R0, `R0};
        #60 `assert(seq_core_top.regs.reg_block[`R6], seq_core.reg_block[`R6])
        
    // TC-16: EXECUTE HALT instruction
        rst = 0;
    #10 rst = 1;
        seq_core_top.fetch.pc = 12;
        seq_core.pc           = 12;
        instruction = {`HALT};
    #10 `assert(seq_core_top.pc, seq_core.pc)
    #90 `assert(seq_core_top.pc, seq_core.pc)
    
    /*******************************************************************
       TEST THE INSTRUCTION EXECUTION - ARITMHETHIC & LOGIC & NOP & HALT
                     -WITH 1 DATA DEPENDENCY-       
    *******************************************************************/
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R1] = 1;
        seq_core_top.regs.reg_block[`R2] = 2;
        instruction = {`ADD, `R3, `R2, `R1};
    #10 instruction = {`ADD, `R0, `R1, `R3};
    #50 `assert(seq_core_top.regs.reg_block[`R0], 4) 
    
        rst = 0;
    #10 rst = 1;
        seq_core_top.regs.reg_block[`R1] = 1;
        seq_core_top.regs.reg_block[`R2] = 2;
        instruction = {`SUB, `R3, `R2, `R1};
    #10 instruction = {`SUB, `R3, `R1, `R3};
    #50 `assert(seq_core_top.regs.reg_block[`R3], 0) 
    
     /*******************************************************************
       TEST THE INSTRUCTION EXECUTION - JMP
                     -NO DATA DEPENDENCY-       
    *******************************************************************/
        rst = 0;
    #10 rst = 1;
        opcode = `JMP;
        seq_core_top.regs.reg_block[`R0] = 32'hBA;
        instruction = {opcode[6:3], 9'd0, `R0};
    #10 instruction = {`NOP, `R0, `R0, `R0};
    #20 `assert(seq_core_top.pc, 10'hBA) 
    
        rst = 0;
    #10 rst = 1;
        opcode = `JMPR;
        instruction = {opcode[6:3], 9'd0, 3'd3};
    // Normally PC will be 3 when JMPR is executed
    // 3 + 3 = 6
    #10 instruction = {`NOP, `R0, `R0, `R0};
    #20 `assert(seq_core_top.pc, 5) 
    
        rst = 0;
    #10 rst = 1;
        opcode = `JMPNN;
        // set OP0 to be 1 in order to exec JMP
        seq_core_top.regs.reg_block[`R1] = 32'd1;
        // set OP1 to be BA and check the value of PC
        seq_core_top.regs.reg_block[`R2] = 32'hBA;
        instruction = {opcode[6:3], `NN, `R1, 3'd0, `R2};

    #10 instruction = {`NOP, `R0, `R0, `R0};
    #20 `assert(seq_core_top.pc, 10'hBA) 
    
        rst = 0;
    #10 rst = 1;
        opcode = `JMPRNN;
        // set OP0 to be 1 in order to exec JMP
        seq_core_top.regs.reg_block[`R1] = 32'd1;
        
        instruction = {opcode[6:3], `NN, `R1, 6'd3};

    #10 instruction = {`NOP, `R0, `R0, `R0};
    #20 `assert(seq_core_top.pc, 5) 
    
    
     
    
         
end
endmodule
