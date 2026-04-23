`timescale 1ns/1ps
// FIXED: renamed output "clt_out" -> "ctl_out" (was a typo)
module modified_xor_adder(
    input  a, b,
    input  ctl_in,
    output ctl_out,   // was "clt_out" -- typo fixed
    output sum
);
    assign ctl_out = ctl_in | (a & b);
    assign sum     = ctl_in ? 1'b1 : (a ^ b);
endmodule
