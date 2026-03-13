module multiplexer_32 (
    input wire[31:0] in1,
    input wire[31:0] in2,
    input wire sel,
    output wire[31:0] out
);

    // If sel = 1, then in2, else in1
    assign out = sel ? in2 : in1;
    
endmodule