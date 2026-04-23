`timescale 1ns / 1ps

module truncation_multiplier_16bit (
    input  wire signed [15:0] X,
    input  wire signed [15:0] Y,
    output wire [15:0] P
);

    // ------------------------------------------------------------------
    // 1. Partial Product Generation (Baugh-Wooley for Signed Math)
    //    We only generate pp[i][j] where 11 <= i+j <= 27.
    //    Columns < 11 are truncated to save area. 
    //    Columns > 27 are unnecessary for a 1.3.12 output.
    // ------------------------------------------------------------------
    wire pp [15:0][15:0];

    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin : row_gen
            for (j = 0; j < 16; j = j + 1) begin : col_gen
                if ((i + j >= 11) && (i + j <= 27)) begin
                    // Baugh-Wooley Signed Logic
                    if (i == 15 && j == 15)
                        assign pp[i][j] = X[i] & Y[j];
                    else if (i == 15 || j == 15)
                        assign pp[i][j] = ~(X[i] & Y[j]);
                    else
                        assign pp[i][j] = X[i] & Y[j];
                end else begin
                    assign pp[i][j] = 1'b0;
                end
            end
        end
    endgenerate

    // ------------------------------------------------------------------
    // 2. Summing by Column (11 to 27)
    // ------------------------------------------------------------------
    wire [5:0] col_sum [27:11];

    genvar k, n;
    generate
        for (k = 11; k <= 27; k = k + 1) begin : col_sum_gen
            wire [15:0] col_bits;

            for (n = 0; n < 16; n = n + 1) begin : bit_collect
                // n is the row index (i). j = k - n.
                if ((k - n >= 0) && (k - n <= 15)) begin
                    assign col_bits[n] = pp[n][k - n];
                end else begin
                    assign col_bits[n] = 1'b0;
                end
            end

            // Apply compensation biases 
            if (k == 11) begin
                // Truncation rounding bias to compensate for omitted bits < 11
                assign col_sum[k] = col_bits[0] + col_bits[1] + col_bits[2] + col_bits[3] +
                                    col_bits[4] + col_bits[5] + col_bits[6] + col_bits[7] +
                                    col_bits[8] + col_bits[9] + col_bits[10] + col_bits[11] +
                                    col_bits[12] + col_bits[13] + col_bits[14] + col_bits[15] +
                                    6'd1; 
            end else if (k == 15) begin
                // Baugh-Wooley constants added at column 15: X[15] and Y[15]
                assign col_sum[k] = col_bits[0] + col_bits[1] + col_bits[2] + col_bits[3] +
                                    col_bits[4] + col_bits[5] + col_bits[6] + col_bits[7] +
                                    col_bits[8] + col_bits[9] + col_bits[10] + col_bits[11] +
                                    col_bits[12] + col_bits[13] + col_bits[14] + col_bits[15] +
                                    X[15] + Y[15];
            end else begin
                // Standard summation
                assign col_sum[k] = col_bits[0] + col_bits[1] + col_bits[2] + col_bits[3] +
                                    col_bits[4] + col_bits[5] + col_bits[6] + col_bits[7] +
                                    col_bits[8] + col_bits[9] + col_bits[10] + col_bits[11] +
                                    col_bits[12] + col_bits[13] + col_bits[14] + col_bits[15];
            end
        end
    endgenerate

    // ------------------------------------------------------------------
    // 3. Final Carry-Propagate Addition (CPA)
    //    Aligning col_sum[11] to bit 0 of the accumulator.
    // ------------------------------------------------------------------
    wire [21:0] stage_val [27:11];

    assign stage_val[11] = {16'b0, col_sum[11]};

    generate
        for (k = 12; k <= 27; k = k + 1) begin : cpa_gen
            // Shift the column sum by (k - 11) for accurate alignment
            assign stage_val[k] = stage_val[k-1] + ({16'b0, col_sum[k]} << (k - 11));
        end
    endgenerate

    // ------------------------------------------------------------------
    // 4. Extract Output
    //    We need bits [27:12] of the exact product for the 1.3.12 format.
    //    Since column 11 maps to index 0, column 12 maps to index 1.
    //    We slice from index 1 to 16.
    // ------------------------------------------------------------------
    assign P = stage_val[27][16:1];

endmodule