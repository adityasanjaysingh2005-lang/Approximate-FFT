`timescale 1ns / 1ps

module kogge_stone_11bit(
    input  [10:0] A,
    input  [10:0] B,
    output [11:0] Sum // 11 bits + 1 bit for Carry-Out
    );

    // Stage 0: Pre-processing (Generate and Propagate)
    wire [10:0] g0, p0;
    assign g0 = A & B;
    assign p0 = A ^ B;

    // Stage 1: Level 1 Carry Generation (Dot operator for spacing 1)
    wire [10:0] g1, p1;
    assign g1[0] = g0[0];
    assign p1[0] = p0[0];
    genvar i;
    generate
        for (i = 1; i < 11; i = i + 1) begin : stage1
            assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
            assign p1[i] = p0[i] & p0[i-1];
        end
    endgenerate

    // Stage 2: Level 2 Carry Generation (Spacing 2)
    wire [10:0] g2, p2;
    assign g2[1:0] = g1[1:0];
    assign p2[1:0] = p1[1:0];
    generate
        for (i = 2; i < 11; i = i + 1) begin : stage2
            assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
            assign p2[i] = p1[i] & p1[i-2];
        end
    endgenerate

    // Stage 3: Level 3 Carry Generation (Spacing 4)
    wire [10:0] g3, p3;
    assign g3[3:0] = g2[3:0];
    assign p3[3:0] = p2[3:0];
    generate
        for (i = 4; i < 11; i = i + 1) begin : stage3
            assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
            assign p3[i] = p2[i] & p2[i-4];
        end
    endgenerate

    // Stage 4: Level 4 Carry Generation (Spacing 8)
    wire [10:0] g4, p4;
    assign g4[7:0] = g3[7:0];
    assign p4[7:0] = p3[7:0];
    generate
        for (i = 8; i < 11; i = i + 1) begin : stage4
            assign g4[i] = g3[i] | (p3[i] & g3[i-8]);
            assign p4[i] = p3[i] & p3[i-8];
        end
    endgenerate

    // Post-processing: Final Sum and Carry-Out computation
    // S[i] = P[i] ^ Carry_in[i-1]
    assign Sum[0]  = p0[0];
    assign Sum[1]  = p0[1]  ^ g4[0];
    assign Sum[2]  = p0[2]  ^ g4[1];
    assign Sum[3]  = p0[3]  ^ g4[2];
    assign Sum[4]  = p0[4]  ^ g4[3];
    assign Sum[5]  = p0[5]  ^ g4[4];
    assign Sum[6]  = p0[6]  ^ g4[5];
    assign Sum[7]  = p0[7]  ^ g4[6];
    assign Sum[8]  = p0[8]  ^ g4[7];
    assign Sum[9]  = p0[9]  ^ g4[8];
    assign Sum[10] = p0[10] ^ g4[9];
    assign Sum[11] = g4[10]; // Final Carry-Out (MSB sum)

endmodule