`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: %b != %b", signal, value); \
            $finish; \
        end