`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 11:19:27
// Design Name: 
// Module Name: saturate_17to16
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


module saturate_17to16 (
    input  wire signed [16:0] in,
    output reg  signed [15:0] out
);
    always @(*) begin
        if      (in[16] == 1'b0 && in[15] == 1'b1) out = 16'h7FFF; // +overflow
        else if (in[16] == 1'b1 && in[15] == 1'b0) out = 16'h8000; // -overflow
        else                                         out = in[15:0]; // normal
    end
endmodule
