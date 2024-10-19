`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: Marculescu Tudor
//
// Create Date: 10/19/2024 12:35:41 PM
// Design Name: seq_core
// Module Name: seq_core
// Project Name: DSD project ACES
// Target Devices: -
// Tool Versions: vivado 2023.2
// Description: golden model of a seq_core
//
// Dependencies: https://users.dcae.pub.ro/~zhascsi/courses/dsd/golden_model.txt
//
// Revision: 1.0
// Revision 1.0 - File Created
// Additional Comments: -
//
//////////////////////////////////////////////////////////////////////////////////
/********** INCLUDES **********/
`include "seq_core.vh"

module seq_core(
    // general
    input 		rst,   // active 0
    input		clk,
    // program memory
    output reg [`A_SIZE-1:0] pc,
    input  [`I_SIZE-1:0] instruction,
    // data memory
    output 		read,  // active 1
    output 		write, // active 1
    output [`A_SIZE-1:0]	address,
    input  [`D_SIZE-1:0]	data_in,
    output reg [`D_SIZE-1:0]data_out
);


reg [`D_SIZE-1:0] reg_block [0:`REG_BLOCK_SIZE-1];

always @(posedge clk) begin
    if (0 == rst) begin
        pc <= 0;
        reg_block[0] <= 0;
        reg_block[1] <= 1;
        reg_block[2] <= 2;
        reg_block[3] <= 3;
        reg_block[4] <= 4;
        reg_block[5] <= 5;
        reg_block[6] <= 6;
        reg_block[7] <= 7;
    end
    else begin    
        pc <= pc + 1;
        
        // based on the instrcution type go to the specific case
        // casex()
        case(instruction[15:9])
        `NOP:       data_out = 0;
        `ADD:       reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] + reg_block[instruction[2:0]];
        `ADDF:      reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] + reg_block[instruction[2:0]];
        `SUB:       reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] - reg_block[instruction[2:0]];
        `SUBF:      reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] - reg_block[instruction[2:0]];
        `AND:       reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] & reg_block[instruction[2:0]];
        `OR:        reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] | reg_block[instruction[2:0]];
        `XOR:       reg_block[instruction[8:6]] <= reg_block[instruction[5:3]] ^ reg_block[instruction[2:0]];
        `NAND:      reg_block[instruction[8:6]] <= ~(reg_block[instruction[5:3]] & reg_block[instruction[2:0]]);
        `NOR:       reg_block[instruction[8:6]] <= ~(reg_block[instruction[5:3]] | reg_block[instruction[2:0]]);
        `NXOR:      reg_block[instruction[8:6]] <= ~(reg_block[instruction[5:3]] ^ reg_block[instruction[2:0]]);
        `SHIFTR:    reg_block[instruction[8:6]] <= reg_block[instruction[8:6]] >> instruction[5:0];
        `SHIFTL:    reg_block[instruction[8:6]] <= reg_block[instruction[8:6]] << instruction[5:0];
        endcase
    end
end

always @(*) begin 
    
end


endmodule