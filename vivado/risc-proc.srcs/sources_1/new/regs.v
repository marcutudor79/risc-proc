`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 12:02:12 AM
// Design Name: 
// Module Name: regs
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


/*  
    Register block memory used by the read pipeline to fetch 
    data and by the write back stage to set the results
*/
module regs (
    input clk,
    input rst,
    
    // input signals read stage
    input [`REG_A_SIZE-1:0] sel_op1,
    input [`REG_A_SIZE-1:0] sel_op2,
    
    // input signals write_back stage
    input [`REG_A_SIZE:0] destination,
    input [`D_SIZE-1:0]   result,
    
    // output signals 
    output reg [`D_SIZE-1:0] val_op1,
    output reg [`D_SIZE-1:0] val_op2
);

// define the registers memory
reg [`D_SIZE-1:0] reg_block [0:`REG_BLOCK_SIZE];

// instantaneous reply from registers
always @(*) begin
    // send the values of the selected operands
    val_op1 = reg_block[sel_op1];
    val_op2 = reg_block[sel_op2];    
end

always @(posedge clk) begin
    if (1'b0 == rst) begin
        reg_block[0] <= 32'd0;
        reg_block[1] <= 32'd0;
        reg_block[2] <= 32'd0;
        reg_block[3] <= 32'd0;
        reg_block[4] <= 32'd0;
        reg_block[5] <= 32'd0;
        reg_block[6] <= 32'd0;
        reg_block[7] <= 32'd0;
    end
    else if (destination != `OUT_OF_BOUND_REG) begin
        // fetch the value from the write_back module
        // and store it in the appropriate register
        reg_block[destination] <= result;        
    end 
end

endmodule 
