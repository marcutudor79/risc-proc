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
    output reg read,  // active 1
    output reg write, // active 1
    output reg[`A_SIZE-1:0]	address,
    input  [`D_SIZE-1:0]	data_in,
    output reg [`D_SIZE-1:0]data_out
);

// instantiate registers of seq_core
reg [`D_SIZE-1:0] reg_block [0:`REG_BLOCK_SIZE-1];

// ALU instructions, JMPs, LOADs and HALT here
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
        
        casex(instruction[15:9])
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
        `SHIFTRA:   reg_block[instruction[8:6]] <= reg_block[instruction[8:6]] >>> instruction[5:0]; 
        `SHIFTL:    reg_block[instruction[8:6]] <= reg_block[instruction[8:6]] << instruction[5:0];
        `JMP:       pc <= pc +  reg_block[instruction[2:0]];
        `JMPR:      pc <= pc + instruction[5:0];
        `JMPcond:   case (instruction[11:9])
                        `N: if (reg_block[instruction[8:6]] < 0) begin
                            pc <= pc + reg_block[instruction[2:0]];
                            end
                        `NN: if (reg_block[instruction[8:6]] >= 0) begin
                            pc <= pc + reg_block[instruction[2:0]];
                            end
                        `Z: if (reg_block[instruction[8:6]] == 0) begin
                            pc <= pc + reg_block[instruction[2:0]];
                            end
                        `NZ: if (reg_block[instruction[8:6]] != 0) begin
                             pc <= pc + reg_block[instruction[2:0]];
                             end            
                    endcase
        `JMPRcond:  case (instruction[11:9])
                        `N: if (reg_block[instruction[8:6]] < 0) begin
                            pc <= pc + instruction[2:0];
                            end
                        `NN: if (reg_block[instruction[8:6]] >= 0) begin
                            pc <= pc + instruction[2:0];
                            end
                         `Z: if (reg_block[instruction[8:6]] == 0) begin
                             pc <= pc + instruction[2:0];
                             end
                         `NZ: if (reg_block[instruction[8:6]] != 0) begin
                              pc <= pc + instruction[2:0];
                              end            
                    endcase
         `LOAD:     reg_block[instruction[10:8]] <= data_in;
         `LOADC:    begin
                    // concatenate the first 24 bits from selected register with 8 bit constant
                    reg_block[instruction[10:8]] <= {reg_block[instruction[10:8]][`D_SIZE - 1:0], instruction[7:0]};
                    end
         `HALT:     pc <= pc;
        endcase
    end
end

// LOAD and STORE external memory control here
always @(*) begin 
    casex(instruction[15:9]) 
       `LOAD: begin
              read    = `READ_ACTIVE;
              write   = `WRITE_DISABLED;
              // select only the last A_SIZE bits from the register
              address = reg_block[instruction[2:0]][`A_SIZE - 1:0];
              end
              
       `STORE: begin
               read     = `READ_DISABLED;
               write    = `WRITE_ACTIVE;
               // select only the last A_SIZE bits from the register
               address  = reg_block[instruction[10:8]][`A_SIZE - 1:0];
               data_out = reg_block[instruction[2:0]];
               end
    endcase
end

// connect the seq_core to seq_core_mem
seq_core_mem mem (
    .clk(clk),
    .read(read),
    .write(write),
    .address(address),
    .data_out(data_in),
    .data_in(data_out)
);
 
endmodule