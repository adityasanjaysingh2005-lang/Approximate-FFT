`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2026 17:34:03
// Design Name: 
// Module Name: Dot_Operator
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


module dot_op (
    input g_high, p_high, // Signals from the current/higher bits
    input g_low,  p_low,  // Signals from the previous/lower bits
    output g_out, p_out
);
    assign g_out = g_high | (p_high & g_low);
    assign p_out = p_high & p_low;
endmodule
