`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2026 15:45:31
// Design Name: 
// Module Name: CSA_3bit
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


module CSA_8bit(
    input [2:0] a,
    input [2:0] b,
    input [2:0] c,
    output [3:0] s,
    output c_out

    );
    
    FullAdder FA(.x(),
                 .y(),
                 .z(),
                 .s(),
                 .c()   )
endmodule
