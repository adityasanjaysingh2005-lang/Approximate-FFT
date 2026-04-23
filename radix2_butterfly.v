`timescale 1ns / 1ps
// ============================================================================
// radix2_butterfly.v  (FIXED - Structural Signed/Unsigned Alignment)
//
// Data format: 1.3.12 signed two's complement, 16 bits
//   Bit[15]=sign | Bits[14:12]=integer | Bits[11:0]=fractional
//   Scale = 2^12 = 4096
//
// Butterfly equations:
//   P   = B * W  (complex multiply)
//   C   = A + P  (sum  output)
//   D   = A - P  (diff output)
// ============================================================================
module radix2_butterfly #(
    parameter N = 8
)(
    input  wire signed [15:0]         A_r,
    input  wire signed [15:0]         A_i,
    input  wire signed [15:0]         B_r,
    input  wire signed [15:0]         B_i,
    input  wire [$clog2(N/2)-1:0]     k,
    output wire signed [15:0]         C_r,
    output wire signed [15:0]         C_i,
    output wire signed [15:0]         D_r,
    output wire signed [15:0]         D_i
);

// ------------------------------------------------------------------
// 1. Twiddle factor lookup
// ------------------------------------------------------------------
wire signed [15:0] W_r, W_i;
twiddle_lut #(.N(N)) u_lut (
    .k   (k),
    .W_r (W_r),
    .W_i (W_i)
);

// ------------------------------------------------------------------
// 2. Four real multiplications
// ------------------------------------------------------------------
wire signed [15:0] m_BrWr, m_BiWi, m_BrWi, m_BiWr;
truncation_multiplier_16bit u_m0 ( .X(B_r), .Y(W_r), .P(m_BrWr) );
truncation_multiplier_16bit u_m1 ( .X(B_i), .Y(W_i), .P(m_BiWi) );
truncation_multiplier_16bit u_m2 ( .X(B_r), .Y(W_i), .P(m_BrWi) );
truncation_multiplier_16bit u_m3 ( .X(B_i), .Y(W_r), .P(m_BiWr) );

// ------------------------------------------------------------------
// 3. Complex multiply accumulation
// ------------------------------------------------------------------
wire signed [16:0] add_Pr_raw, add_Pi_raw;

error_tolerant_adder u_add_Pr (
    .a   (m_BrWr),
    .b   (-m_BiWi),  // FIXED: Unary minus preserves signedness
    .sum (add_Pr_raw)
);

error_tolerant_adder u_add_Pi (
    .a   (m_BrWi),
    .b   (m_BiWr),
    .sum (add_Pi_raw)
);

wire signed [15:0] P_r, P_i;
saturate_17to16 u_sat_Pr ( .in(add_Pr_raw), .out(P_r) );
saturate_17to16 u_sat_Pi ( .in(add_Pi_raw), .out(P_i) );

// ------------------------------------------------------------------
// 4. Butterfly add / subtract
// ------------------------------------------------------------------
wire signed [16:0] add_Cr_raw, add_Ci_raw, sub_Dr_raw, sub_Di_raw;

// C_r = A_r + P_r
error_tolerant_adder u_add_Cr (
    .a   (A_r),
    .b   (P_r),
    .sum (add_Cr_raw)
);

// C_i = A_i + P_i
error_tolerant_adder u_add_Ci (
    .a   (A_i),
    .b   (P_i),
    .sum (add_Ci_raw)
);

// D_r = A_r - P_r
error_tolerant_adder u_sub_Dr (
    .a   (A_r),
    .b   (-P_r),     // FIXED: Unary minus preserves signedness
    .sum (sub_Dr_raw)
);

// D_i = A_i - P_i
error_tolerant_adder u_sub_Di (
    .a   (A_i),
    .b   (-P_i),     // FIXED: Unary minus preserves signedness
    .sum (sub_Di_raw)
);

// ------------------------------------------------------------------
// 5. Saturate all four outputs to 16-bit 1.3.12
// ------------------------------------------------------------------
saturate_17to16 u_sat_Cr ( .in(add_Cr_raw), .out(C_r) );
saturate_17to16 u_sat_Ci ( .in(add_Ci_raw), .out(C_i) );
saturate_17to16 u_sat_Dr ( .in(sub_Dr_raw), .out(D_r) );
saturate_17to16 u_sat_Di ( .in(sub_Di_raw), .out(D_i) );

endmodule