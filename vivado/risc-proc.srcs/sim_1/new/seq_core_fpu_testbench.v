`timescale 1ns / 1ps

`include "seq_core.vh"
`include "seq_core_testbench.vh"

module seq_core_fpu_testbench;

reg clk, rst;
reg [`I_EXEC_SIZE-1:0] instruction_in;
wire [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_3;

/***************************************
         EXECUTE FP STAGE DUT
****************************************/
execute_floating_point execute_fp (
    .clk(clk),
    .rst(rst),
    .instruction_in(instruction_in),
    .instruction_out_exec_floating_3(instruction_out_exec_floating_3)
);

// have a clock with 10ns perios
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

/************************************
               TESTS
*************************************/
initial begin
    rst = 1;
    #10 rst = 0;

    // Test: 1.0 + 1.0 (assuming IEEE-754 single precision)
    instruction_in[`I_EXEC_DAT1] = 32'h3F800000; // 1.0
    instruction_in[`I_EXEC_DAT2] = 32'h3F800000; // 1.0
    
    #50; // EXPECT 40000000

    // Test: 1.0 + 1.5 (assuming IEEE-754 single precision)
    instruction_in[`I_EXEC_DAT1] = 32'h3F800000; // 1.0
    instruction_in[`I_EXEC_DAT2] = 32'h3FC00000; // 1.5

    #50;

end

endmodule
