`include "defines.vh"

module alu (
    input  [`CSIZE-1:0] opcode, 
    input  [`DSIZE-1:0] datain,
    output reg [`DSIZE-1:0] dataout,
    output sign
);

always @(*) begin
    if (opcode == `ADD) 
        begin 
        dataout = datain + datain;
        end
    
    else if (opcode == `SUB)
        begin
        
        end
end

assign sign = dataout[`SIGN];

endmodule
