`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 03:54:48
// Design Name: 
// Module Name: half_adder
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


`timescale 1ns/1ps
// FIXED: added ports "sum" and "carry" as aliases
// truncation_multiplier_16bit connects .sum and .carry
module half_adder(
    input  a, b,
    output sum,   // was "s"
    output carry  // was "c"
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule
 