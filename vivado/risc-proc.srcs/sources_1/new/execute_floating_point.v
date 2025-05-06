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
    output reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_3

);

// internal variable to save the result
reg [`I_EXEC_SIZE-1:0] instruction_out;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_0;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_1;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_2;

/*  1. Comparison & decision on how to arrange the numbers
    SCTRL - cel mai mare numar in stanga si sumatorul inverseaza
    
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
reg [`F_SIGNIFICAND_SIZE-1:0] signif1_aligned;
reg [`F_SIGNIFICAND_SIZE-1:0] signif2_aligned;

reg carry;

// define special cases when adding 2 fp numbers
reg [1:0] add_case;
`define F_ADD_OK           (0)
`define F_ADD_INFINITY     (1)
`define F_ADD_NOT_A_NUMBER (2)
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
        signif1_aligned = operand1[`F_SIGNIFICAND];
        signif2_aligned = operand2[`F_SIGNIFICAND] >> (operand1[`F_EXPONENT] - operand2[`F_EXPONENT]);
     end
     else begin
        exp_max  = operand2[`F_EXPONENT];
        signif1_aligned = operand2[`F_SIGNIFICAND];
        signif2_aligned = operand1[`F_SIGNIFICAND] >> (operand2[`F_EXPONENT] - operand1[`F_EXPONENT]);
     end  
     
     // Invert the significands acordingly
     if (operand1[`F_SIGN] == 1'b1) begin
        signif1_aligned = ~signif1_aligned;
        carry = 1;
     end
     
     if (operand2[`F_SIGN] == 1'b1) begin
        signif2_aligned = ~signif2_aligned;
        carry = 1;
     end
end

/* 2. Add the aligned significands
*/
reg [`D_SIZE-1:0] operand1;
reg [`D_SIZE-1:0] operand2;
reg [`F_SIGNIFICAND_SIZE-1:0] signif_sum;
always @(*) begin
    signif_sum = signif1_aligned + signif2_aligned + carry;
end
/* 8 combinatii specifice pentru 
    semn bit    mai mic    |
    semn bit    mai mare   |
    mantissa mai mare      |
    operation              |
    
    ambii operanzi negativi -> considerati pozitivi -> semnul negativ se propaga mai jos
    
    + 1 carry de intrare
 */
/*  3. Invert numbers & PENC
*/
always @(*) begin 
    if 

end

/* 4. Left shift & position adjustment

    rezultat in IEE unde mantissa trebuie aliniata pentru 1,
    
    Period encoder -> pozitia bitului cel mai semnificativ de 1
    
    daca exponentul este -125 se poate shifta la stanga cu -2 maxim
*/
always @(*) begin


end


always @(posedge clk) begin
    instruction_out_exec_floating_0 <= {16'd0, 9'd0, signif1_aligned, 9'd0, signif2_align};
    instruction_out_exec_floating_1 <= instruction_out_exec_floating_0;
    instruction_out_exec_floating_2 <= instruction_out_exec_floating_1;
    instruction_out_exec_floating_3 <= instruction_out_exec_floating_2;
end

endmodule



