`timescale 1ns / 1ps
// FIXED: output port renamed from "sum" -> "Sum" (uppercase S)
// to match instantiation in error_tolerant_adder:
//   kogge_stone_8bit accurate_adder (.A(...), .B(...), .Sum(msb_sum));
 
module kogge_stone_8bit(
    input  [7:0] A, B,
    output [8:0] Sum        // was "sum" -- causes VRFC 10-3180 in error_tolerant_adder
);
 
    wire [7:0] g [0:3];
    wire [7:0] p [0:3];
 
    genvar i;
 
    // pre-processing
    generate
        for (i = 0; i < 8; i = i+1) begin : preprocessing
            assign g[0][i] = A[i] & B[i];
            assign p[0][i] = A[i] ^ B[i];
        end
    endgenerate
 
    // stage 1
    generate
        for (i = 0; i < 1; i = i+1) begin : stage1_pass
            assign g[1][i] = g[0][i];
            assign p[1][i] = p[0][i];
        end
        for (i = 1; i < 8; i = i+1) begin : stage1_dot
            dot_ops d1 (.g_high(g[0][i]), .p_high(p[0][i]),
                        .g_low (g[0][i-1]), .p_low(p[0][i-1]),
                        .g_out (g[1][i]),   .p_out(p[1][i]));
        end
    endgenerate
 
    // stage 2
    generate
        for (i = 0; i < 2; i = i+1) begin : stage2_pass
            assign g[2][i] = g[1][i];
            assign p[2][i] = p[1][i];
        end
        for (i = 2; i < 8; i = i+1) begin : stage2_dot
            dot_ops d1 (.g_high(g[1][i]), .p_high(p[1][i]),
                        .g_low (g[1][i-2]), .p_low(p[1][i-2]),
                        .g_out (g[2][i]),   .p_out(p[2][i]));
        end
    endgenerate
 
    // stage 3
    generate
        for (i = 0; i < 4; i = i+1) begin : stage3_pass
            assign g[3][i] = g[2][i];
            assign p[3][i] = p[2][i];
        end
        for (i = 4; i < 8; i = i+1) begin : stage3_dot
            dot_ops d1 (.g_high(g[2][i]), .p_high(p[2][i]),
                        .g_low (g[2][i-4]), .p_low(p[2][i-4]),
                        .g_out (g[3][i]),   .p_out(p[3][i]));
        end
    endgenerate
 
    // post-processing
    assign Sum[0] = p[0][0];
    generate
        for (i = 1; i < 8; i = i+1) begin : postprocess
            assign Sum[i] = p[0][i] ^ g[3][i-1];
        end
    endgenerate
    assign Sum[8] = g[3][7];
 
endmodule