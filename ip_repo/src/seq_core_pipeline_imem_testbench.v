`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/14/2025 07:52:32 PM
// Design Name: 
// Module Name: seq_core_pipeline_imem_testbench
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

module seq_core_pipeline_imem_testbench;

reg clk = 0;
reg rst = 1;
reg [6:0] opcode;

// have a clock with 10ns perios
initial begin
    forever #5 clk = ~clk;
end

/***************************************
    MEMORIES DATA & INSTRUCTION
****************************************/
wire write_mem_pipeline;
wire [`I_SIZE-1:0] instruction_pipeline;
wire [`A_SIZE-1:0] address_out_pipeline;
wire [`D_SIZE-1:0] data_pipeline_in;
wire [`D_SIZE-1:0] data_pipeline_out;
wire [`A_SIZE-1:0] pc_pipeline;

wire wire_mem;
wire [`I_SIZE-1:0] instruction;
wire [`A_SIZE-1:0] address_out;
wire [`D_SIZE-1:0] data_in;
wire [`D_SIZE-1:0] data_out;
wire [`A_SIZE-1:0] pc;


seq_core_dmem dmem_pipeline
(
    .clk(clk),
    .address(address_out_pipeline),
    .write_mem(write_mem_pipeline),
    .data_in(data_pipeline_out),
    .data_out(data_pipeline_in)
);

seq_core_dmem dmem
(
    .clk(clk),
    .address(address),
    .write_mem(write_mem),
    .data_in(data_out),
    .data_out(data_in)
);


seq_core_imem imem_pipeline
(
    .pc(pc_pipeline),
    .instruction(instruction_pipeline)
);


seq_core_imem imem
(
    .pc(pc),
    .instruction(instruction)
);
/***************************************
  SEQ_CORE_TOP AND SEQ_CORE_GOLDEN DUT
****************************************/

// risc core 4stage pipeline
seq_core_pipeline seq_core_pipeline
(
    .clk(clk),
    .rst(rst),
    .pc(pc_pipeline),
    .instruction(instruction_pipeline),
    .write_mem(write_mem_pipeline),
    .address(address_pipeline),
    .data_in(data_in_pipeline),
    .data_out(data_out_pipeline)
);

// risc core golden model
seq_core seq_core
(
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .write(write_mem),
    .address(address),
    .data_in(data_in),
    .data_out(data_out)
);

/************************************
               TESTS
*************************************/
initial begin
    rst = 0;
    
    /*
        1.a. Test sequence of independent integer arithmetic&logic instructions
    */
    opcode = `LOADC;
    imem_pipeline.mem[0] = {opcode[6:2], `R1, 8'd1};
    imem_pipeline.mem[1] = {opcode[6:2], `R2, 8'd2};
    imem_pipeline.mem[2] = {opcode[6:2], `R3, 8'd3};
    imem_pipeline.mem[3] = {opcode[6:2], `R4, 8'd4};
    imem_pipeline.mem[4] = {opcode[6:2], `R5, 8'd5};
    
    imem_pipeline.mem[5] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[6] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[7] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[8] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[9] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[10] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[11] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[12] = {`NOP, `R0, `R0, `R0};
    
    // expect R1 == 2
    imem_pipeline.mem[13] = {`ADD, `R1, `R1, `R1};
    
    // expect R2 == 0
    imem_pipeline.mem[14] = {`SUB, `R2, `R2, `R2};
    
    // expect R3 == 0
    imem_pipeline.mem[15] = {`AND, `R3, `R3, `R6};
    
    // expect R4 == 8
    imem_pipeline.mem[16] = {`SHIFTL, `R4, 6'd1};
    
    imem_pipeline.mem[17] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[18] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[19] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[20] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[21] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[22] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[23] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[24] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[25] = {`HALT, 9'd0};
    
    #10
    // start executing
    rst = 1;
    
    // check results
    #240
    `assert(seq_core_pipeline.regs.reg_block[`R1], 2)
    `assert(seq_core_pipeline.regs.reg_block[`R2], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R3], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R4], 8)
    
    /*
       1.b. Test sequence of independent floating point arithmetic instructions
    */
    rst = 0;
    opcode = `LOADC;
    imem_pipeline.mem[0] = {opcode[6:2], `R1, 8'd1};
    imem_pipeline.mem[1] = {opcode[6:2], `R2, 8'd2};
    imem_pipeline.mem[2] = {opcode[6:2], `R3, 8'd3};
    imem_pipeline.mem[3] = {opcode[6:2], `R4, 8'd4};
    
    imem_pipeline.mem[5] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[6] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[7] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[8] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[9] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[10] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[11] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[12] = {`NOP, `R0, `R0, `R0};
    
    // expect R1 == 2
    imem_pipeline.mem[13] = {`ADDF, `R1, `R1, `R1};
    
    // expect R2 == 0
    imem_pipeline.mem[14] = {`SUBF, `R2, `R2, `R2};
    
    // expect R3 == 6
    imem_pipeline.mem[15] = {`ADDF, `R3, `R3, `R3};
    
    // expect R4 == 0
    imem_pipeline.mem[16] = {`SUBF, `R4, `R4, `R4};
    
    imem_pipeline.mem[17] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[18] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[19] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[20] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[21] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[22] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[23] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[24] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[25] = {`HALT, 9'd0};
    
    #10
    // start executing
    rst = 1;
    
    // check results
    #240
    `assert(seq_core_pipeline.regs.reg_block[`R1], 2)
    `assert(seq_core_pipeline.regs.reg_block[`R2], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R3], 6)
    `assert(seq_core_pipeline.regs.reg_block[`R4], 0)
    
    /*
        1.c. Test sequence of independent mixed floating point arithmetic and integer arithmetic&logic instructions
    */
    rst = 0;
    opcode = `LOADC;
    imem_pipeline.mem[0] = {opcode[6:2], `R1, 8'd1};
    imem_pipeline.mem[1] = {opcode[6:2], `R2, 8'd2};
    imem_pipeline.mem[2] = {opcode[6:2], `R3, 8'd3};
    imem_pipeline.mem[3] = {opcode[6:2], `R4, 8'd4};
    
    imem_pipeline.mem[5] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[6] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[7] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[8] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[9] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[10] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[11] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[12] = {`NOP, `R0, `R0, `R0};
    
    // expect R1 == 2
    imem_pipeline.mem[13] = {`ADDF, `R1, `R1, `R1};
    
    // expect R2 == 0
    imem_pipeline.mem[14] = {`SUB, `R2, `R2, `R2};
    
    // expect R3 == 6
    imem_pipeline.mem[15] = {`ADDF, `R3, `R3, `R3};
    
    // expect R4 == 0
    imem_pipeline.mem[16] = {`SUB, `R4, `R4, `R4};
    
    imem_pipeline.mem[17] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[18] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[19] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[20] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[21] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[22] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[23] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[24] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[25] = {`HALT, 9'd0};
    
    #10
    // start executing
    rst = 1;
    
    // check results
    #300
    `assert(seq_core_pipeline.regs.reg_block[`R1], 2)
    `assert(seq_core_pipeline.regs.reg_block[`R2], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R3], 6)
    `assert(seq_core_pipeline.regs.reg_block[`R4], 0)
    
    /* 
        2.a. Test sequence of integer arithmetic&logic instructions
    */
    rst = 0;
    opcode = `LOADC;
    imem_pipeline.mem[0] = {opcode[6:2], `R1, 8'd1};
    imem_pipeline.mem[1] = {opcode[6:2], `R2, 8'd2};
    imem_pipeline.mem[2] = {opcode[6:2], `R3, 8'd3};
    imem_pipeline.mem[3] = {opcode[6:2], `R4, 8'd4};
    
    imem_pipeline.mem[5] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[6] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[7] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[8] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[9] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[10] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[11] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[12] = {`NOP, `R0, `R0, `R0};
    
    // expect R1 == 2
    imem_pipeline.mem[13] = {`ADD, `R1, `R1, `R1};
    
    // expect R2 == 0 (dependecy R1)
    imem_pipeline.mem[14] = {`SUB, `R2, `R2, `R1};
    
    // expect R3 == 0 (depedency R2)
    imem_pipeline.mem[15] = {`AND, `R3, `R3, `R2};
    
    // expect R4 == 8
    imem_pipeline.mem[16] = {`SHIFTL, `R4, 6'd1};
    
    imem_pipeline.mem[17] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[18] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[19] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[20] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[21] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[22] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[23] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[24] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[25] = {`HALT, 9'd0};
    
    #10
    // start executing
    rst = 1;
    
    // check results
    #240
    `assert(seq_core_pipeline.regs.reg_block[`R1], 2)
    `assert(seq_core_pipeline.regs.reg_block[`R2], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R3], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R4], 8)
    
    /*
       2.b. Test sequence of floating point arithmetic instructions
    */
    rst = 0;
    opcode = `LOADC;
    imem_pipeline.mem[0] = {opcode[6:2], `R1, 8'd1};
    imem_pipeline.mem[1] = {opcode[6:2], `R2, 8'd2};
    imem_pipeline.mem[2] = {opcode[6:2], `R3, 8'd3};
    imem_pipeline.mem[3] = {opcode[6:2], `R4, 8'd4};
    
    imem_pipeline.mem[5] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[6] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[7] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[8] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[9] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[10] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[11] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[12] = {`NOP, `R0, `R0, `R0};
    
    // expect R1 == 2
    imem_pipeline.mem[13] = {`ADDF, `R1, `R1, `R1};
    
    // expect R2 == 0 (dependecy R1)
    imem_pipeline.mem[14] = {`SUBF, `R2, `R2, `R1};
    
    // expect R3 == 3 (dependecy R2)
    imem_pipeline.mem[15] = {`ADDF, `R3, `R3, `R2};
    
    // expect R4 == 1
    imem_pipeline.mem[16] = {`SUBF, `R4, `R4, `R3};
    
    imem_pipeline.mem[17] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[18] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[19] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[20] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[21] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[22] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[23] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[24] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[25] = {`HALT, 9'd0};
    
    #10
    // start executing
    rst = 1;
    
    // check results
    #400
    `assert(seq_core_pipeline.regs.reg_block[`R1], 2)
    `assert(seq_core_pipeline.regs.reg_block[`R2], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R3], 3)
    `assert(seq_core_pipeline.regs.reg_block[`R4], 1)
    
    /*
        2.c. Test sequence of mixed floating point arithmetic and integer arithmetic&logic instructions
    */
    rst = 0;
    opcode = `LOADC;
    imem_pipeline.mem[0] = {opcode[6:2], `R1, 8'd1};
    imem_pipeline.mem[1] = {opcode[6:2], `R2, 8'd2};
    imem_pipeline.mem[2] = {opcode[6:2], `R3, 8'd3};
    imem_pipeline.mem[3] = {opcode[6:2], `R4, 8'd4};
    
    imem_pipeline.mem[5] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[6] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[7] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[8] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[9] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[10] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[11] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[12] = {`NOP, `R0, `R0, `R0};
    
    // expect R1 == 2
    imem_pipeline.mem[13] = {`ADDF, `R1, `R1, `R1};
    
    // expect R2 == 0 (dependcy R1)
    imem_pipeline.mem[14] = {`SUB, `R2, `R2, `R1};
    
    // expect R3 == 3 (depdency R2)
    imem_pipeline.mem[15] = {`ADDF, `R3, `R3, `R2};
    
    // expect R4 == 0
    imem_pipeline.mem[16] = {`SUB, `R4, `R4, `R4};
    
    imem_pipeline.mem[17] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[18] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[19] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[20] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[21] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[22] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[23] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[24] = {`NOP, `R0, `R0, `R0};
    imem_pipeline.mem[25] = {`HALT, 9'd0};
    
    // check results
    #300
    `assert(seq_core_pipeline.regs.reg_block[`R1], 2)
    `assert(seq_core_pipeline.regs.reg_block[`R2], 0)
    `assert(seq_core_pipeline.regs.reg_block[`R3], 3)
    `assert(seq_core_pipeline.regs.reg_block[`R4], 1)
    
end
endmodule
