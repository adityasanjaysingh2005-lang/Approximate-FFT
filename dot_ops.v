`timescale 1ns/1ps
// dot_ops: Kogge-Stone parallel prefix operator
// g_out = g_high | (p_high & g_low)
// p_out = p_high & p_low
module dot_ops(
    input  g_high, p_high,
    input  g_low,  p_low,
    output g_out,  p_out
);
    assign g_out = g_high | (p_high & g_low);
    assign p_out = p_high & p_low;
endmodule
 
