`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2026 18:06:31
// Design Name: 
// Module Name: kogge_stone_16bit
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


module kogge_stone_16bit (
    input  [15:0] A,
    input  [15:0] B,
    input         cin,
    output [15:0] Sum,
    output        cout
);

    wire [15:0] g [0:4];
    wire [15:0] p [0:4];
    wire [16:0] carry;
    genvar i;

    // --- STAGE 0: Pre-processing ---
    generate
        for (i = 0; i < 16; i = i + 1) begin : pre_proc
            assign g[0][i] = A[i] & B[i];
            assign p[0][i] = A[i] ^ B[i];
        end
    endgenerate

    // --- STAGE 1: Stride 1 ---
    generate
        for (i = 0; i < 1; i = i + 1) begin : s1_pass
            assign g[1][i] = g[0][i];
            assign p[1][i] = p[0][i];
        end
        for (i = 1; i < 16; i = i + 1) begin : s1_dot
            dot_op u1 (g[0][i], p[0][i], g[0][i-1], p[0][i-1], g[1][i], p[1][i]);
        end
    endgenerate

    // --- STAGE 2: Stride 2 ---
    generate
        for (i = 0; i < 2; i = i + 1) begin : s2_pass
            assign g[2][i] = g[1][i];
            assign p[2][i] = p[1][i];
        end
        for (i = 2; i < 16; i = i + 1) begin : s2_dot
            dot_op u2 (g[1][i], p[1][i], g[1][i-2], p[1][i-2], g[2][i], p[2][i]);
        end
    endgenerate

    // --- STAGE 3: Stride 4 ---
    generate
        for (i = 0; i < 4; i = i + 1) begin : s3_pass
            assign g[3][i] = g[2][i];
            assign p[3][i] = p[2][i];
        end
        for (i = 4; i < 16; i = i + 1) begin : s3_dot
            dot_op u3 (g[2][i], p[2][i], g[2][i-4], p[2][i-4], g[3][i], p[3][i]);
        end
    endgenerate

    // --- STAGE 4: Stride 8 ---
    generate
        for (i = 0; i < 8; i = i + 1) begin : s4_pass
            assign g[4][i] = g[3][i];
            assign p[4][i] = p[3][i];
        end
        for (i = 8; i < 16; i = i + 1) begin : s4_dot
            dot_op u4 (g[3][i], p[3][i], g[3][i-8], p[3][i-8], g[4][i], p[4][i]);
        end
    endgenerate

    // --- Post-processing: Sum and Carry Out ---
    assign carry[0] = cin;
    generate
        for (i = 0; i < 16; i = i + 1) begin : final_sum
            // Each carry into bit i+1 is the cumulative generate from the prefix tree
            assign carry[i+1] = g[4][i] | (p[4][i] & cin);
            assign Sum[i]     = p[0][i] ^ carry[i];
        end
    endgenerate

    assign cout = carry[16];

endmodule
