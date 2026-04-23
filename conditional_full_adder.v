`timescale 1ns/1ps
// FIXED: renamed ports (x,y,z,s,c) -> (a,b,cin,sum,carry)
// to match instantiation in truncation_multiplier_16bit
module conditional_full_adder(
    input  a, b, cin,
    output sum, carry
);
    wire mux1, mux2;
    assign mux1  = b   ? (~a)  : a;
    assign mux2  = mux1 ? cin  : a;
    assign carry = mux2;
    assign sum   = mux1 ^ cin;
endmodule
