`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2025 11:34:36 AM
// Design Name:
// Module Name: execute_floating_point
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

module execute_floating_point(
    input clk,
    input rst,

    // pipeline in/out
    input [`I_EXEC_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_3,
    output reg [`D_SIZE-1:0] result_out

);

// temp save buffer for instruction
reg [`I_EXEC_SIZE-1:0] instruction_out;

/*  1. Comparison & decision on how to arrange the numbers
    SCTRL - biggest number on the left and the adder inverts

    0. Check for special cases
        - if exp field is 111...111 and significand field is 000...000 -> infinity
        - if exp field is 111...111 and significand field is non-zero  -> NaN

    1. Compare the exponents, they can be directly compared as unsigned integers
        - if exponents are equal, compare the significands
       -> decide which fp number is bigger

    2. Adjust the smaller mantissa
*/
reg [`D_SIZE-1:0] operand1;
reg [`D_SIZE-1:0] operand2;

reg [`F_EXP_SIZE-1:0] exp_max;
reg [`F_EXP_SIZE-1:0] exp_diff;
reg [`F_SIGNIFICAND_SIZE+1:0] signif1_aligned;
reg [`F_SIGNIFICAND_SIZE+1:0] signif2_aligned;

reg carry;

// define special cases when adding 2 fp numbers
reg [1:0] add_case;
`define F_ADD_OK           (0)
`define F_ADD_INFINITY     (1)
`define F_ADD_NOT_A_NUMBER (2)

// to be sampled by the sequantial block
reg [`F_SIGNIFICAND_SIZE+1:0] signif1_aligned_stable;
reg [`F_SIGNIFICAND_SIZE+1:0] signif2_aligned_stable;
reg carry_stable;
reg [`F_EXP_SIZE-1:0] exp_max_stable;
always @(*) begin

     // Assume addition of fp numbers can be done
     add_case = `F_ADD_OK;
     operand1 = instruction_in[`I_EXEC_DAT1];
     operand2 = instruction_in[`I_EXEC_DAT2];
     carry    = 0;

     // Check for special cases
     if ( ((operand1[`F_EXPONENT] == `F_MAX_EXPONENT) && (operand1[`F_SIGNIFICAND] == 0))
        ||((operand2[`F_EXPONENT] == `F_MAX_EXPONENT) && (operand2[`F_SIGNIFICAND] == 0)) )
     begin
        add_case = `F_ADD_INFINITY;
     end

     if ( ((operand1[`F_EXPONENT] == `F_MAX_EXPONENT) && (operand1[`F_SIGNIFICAND] != 0))
        ||((operand2[`F_EXPONENT] == `F_MAX_EXPONENT) && (operand2[`F_SIGNIFICAND] != 0)) )
     begin
        add_case = `F_ADD_NOT_A_NUMBER;
     end

     // Compute max exponent
     if (operand1[`F_EXPONENT] > operand2[`F_EXPONENT]) begin
        exp_max  = operand1[`F_EXPONENT];
        // have additional 2 bits that are used for rounding
        // 10, 11 -> lead to addition on the other bits
        // 01, 00 -> are just 0
        signif1_aligned = {operand1[`F_SIGNIFICAND], 2'b00};
        signif2_aligned = {operand2[`F_SIGNIFICAND], 2'b00} >> (operand1[`F_EXPONENT] - operand2[`F_EXPONENT]);
     end
     else begin
        exp_max  = operand2[`F_EXPONENT];
        signif1_aligned = {operand2[`F_SIGNIFICAND], 2'b00};
        signif2_aligned = {operand1[`F_SIGNIFICAND], 2'b00} >> (operand2[`F_EXPONENT] - operand1[`F_EXPONENT]);
     end

     // ToDo: Invert significand in 2's complement for substraction
end


/* 2. Add the aligned significands
*/
// 1 additional bit from IEEE standard 1.bbb
// 1 additional bit to see the actual overflow
reg [`F_SIGNIFICAND_SIZE+3:0] signif_sum;

// to be sampled by the sequential block
reg [`F_SIGNIFICAND_SIZE+3:0] signif_sum_stable; // have 2 additional bits at left
                                               // 2 bits at right for rounding
always @(*) begin
    signif_sum = {1'b1, signif1_aligned_stable} + {1'b1, signif2_aligned_stable};
end

/*  3. Invert numbers & PENC
*/
// Store position of the most significand 1
reg [4:0] shift_pos;
reg [4:0] pos;
reg [`F_SIGNIFICAND_SIZE-1:0] normalized_significand;
reg [`F_EXP_SIZE-1:0]         result_exp;

// to be sampled by sequential stage
reg [4:0] shift_pos_stable;
reg [`F_EXP_SIZE-1:0] result_exp_stable;
always @(*) begin

    // priority encoder - checkout all the bits besides the last 2 - which are used rounding
    casex (signif_sum_stable[26:3])
        24'b1xxxxxxxxxxxxxxxxxxxxxxx: pos = 5'd23;
        24'b01xxxxxxxxxxxxxxxxxxxxxx: pos = 5'd22;
        24'b001xxxxxxxxxxxxxxxxxxxxx: pos = 5'd21;
        24'b0001xxxxxxxxxxxxxxxxxxxx: pos = 5'd20;
        24'b00001xxxxxxxxxxxxxxxxxxx: pos = 5'd19;
        24'b000001xxxxxxxxxxxxxxxxxx: pos = 5'd18;
        24'b0000001xxxxxxxxxxxxxxxxx: pos = 5'd17;
        24'b00000001xxxxxxxxxxxxxxxx: pos = 5'd16;
        24'b000000001xxxxxxxxxxxxxxx: pos = 5'd15;
        24'b0000000001xxxxxxxxxxxxxx: pos = 5'd14;
        24'b00000000001xxxxxxxxxxxxx: pos = 5'd13;
        24'b000000000001xxxxxxxxxxxx: pos = 5'd12;
        24'b0000000000001xxxxxxxxxxx: pos = 5'd11;
        24'b00000000000001xxxxxxxxxx: pos = 5'd10;
        24'b000000000000001xxxxxxxxx: pos = 5'd9;
        24'b0000000000000001xxxxxxxx: pos = 5'd8;
        24'b00000000000000001xxxxxxx: pos = 5'd7;
        24'b000000000000000001xxxxxx: pos = 5'd6;
        24'b0000000000000000001xxxxx: pos = 5'd5;
        24'b00000000000000000001xxxx: pos = 5'd4;
        24'b000000000000000000001xxx: pos = 5'd3;
        24'b0000000000000000000001xx: pos = 5'd2;
        24'b00000000000000000000001x: pos = 5'd1;
        24'b000000000000000000000001: pos = 5'd0;
        default: pos = 5'd0;
    endcase

    /* Compute how much LSHIFT should do to the signif_sum_stable

       Special case: LSHIFT == -1
    */
    shift_pos = `F_SIGNIFICAND_SIZE - pos - 1;

    /*
       Correct the exponent
       - overflow when adding significands -> shift_pos == -1 -> result_exp += 1
       - no overflow occured, but, result is not in 1.bbb format, but in 0.001bbb
         format -> shift_pos > 0 -> result_exp = exp_max - shift_pos
    */
    if (-1 == $signed(shift_pos))
        result_exp = exp_max_stable + 1;
    else if (exp_max_stable >= shift_pos)
        result_exp = exp_max_stable - shift_pos;
    else
        result_exp = 0;

end


/* 4. Left shift the significand & compute result
*/
reg [`D_SIZE-1:0] result;
always @(*) begin

    // shift significand until it gets into format 1.bbbb
    if (-1 == $signed(shift_pos))
        normalized_significand = signif_sum_stable[26:2] >> 1;
    else
        normalized_significand = signif_sum_stable[26:2] << shift_pos_stable;

    case (add_case)
        `F_ADD_OK: begin
            result = {operand1[`F_SIGN], result_exp_stable, normalized_significand};
        end
        `F_ADD_INFINITY: begin
            result = {operand1[`F_SIGN], `F_MAX_EXPONENT, {`F_SIGNIFICAND_SIZE{1'b0}}};
        end
        `F_ADD_NOT_A_NUMBER: begin
            result = {1'b0, `F_MAX_EXPONENT, {1'b1, {(`F_SIGNIFICAND_SIZE-1){1'b0}}}};
        end
    endcase
end

/* Sequantial sampling for each stage */
always @(posedge clk) begin
    // 1st stage sampling
    // internal variable to save the values
    instruction_out        <= instruction_in;
    signif1_aligned_stable <= signif1_aligned;
    signif2_aligned_stable <= signif2_aligned;
    carry_stable           <= carry;
    exp_max_stable         <= exp_max;

    // 2nd stage sampling
    signif_sum_stable      <= signif_sum;

    // 3rd stage sampling
    shift_pos_stable       <= shift_pos;
    result_exp_stable      <= result_exp;

    // 4th stage sampling
    result_out                      <= result;
    instruction_out_exec_floating_3 <= {instruction_in[`I_EXEC_INSTR], 32'd0, result};
end

endmodule



