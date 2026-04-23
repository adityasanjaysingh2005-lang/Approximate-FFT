`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 11:18:07
// Design Name: 
// Module Name: twiddle_lut
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


module twiddle_lut #(
    parameter N = 8
)(
    input  wire [$clog2(N/2)-1:0] k,
    output reg  signed [15:0]     W_r,
    output reg  signed [15:0]     W_i
);
    always @(*) begin
        case (k)
            3'd0: begin W_r =  16'sd4096; W_i =  16'sd0;    end
            3'd1: begin W_r =  16'sd2896; W_i = -16'sd2896; end
            3'd2: begin W_r =  16'sd0;    W_i = -16'sd4096; end
            3'd3: begin W_r = -16'sd2896; W_i = -16'sd2896; end
            default: begin W_r = 16'sd4096; W_i = 16'sd0;   end
        endcase
    end
endmodule
