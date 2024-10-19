`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/19/2024 01:10:39 PM
// Design Name:
// Module Name: seq_core_reg
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

module seq_core_reg
(
    input wire clock,
    input wire reset, /// active 0 - to be uniform with core
    input wire we,    // write enable signal 0 - write, 1 - read
    input wire [`REG_A_SIZE:0] sel_reg,
    input wire [`D_SIZE-1:0]  data_in,
    output reg [`D_SIZE-1:0]  data_out
);

reg [`D_SIZE-1:0] reg_block [0:`REG_BLOCK_SIZE-1];

always@(*) 
begin
	data_out = reg_block[sel_reg]; 
end


always@(posedge clock)
begin

    // if reset is active == 0, then reset the register
    if(1'b0 == reset) begin
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
        // if we is active == 0, then write the data to reg
        if(1'b0 == we) begin
            reg_block[sel_reg] <= data_in;
        end
    end
end

endmodule


