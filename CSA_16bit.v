`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2026 16:13:57
// Design Name: 
// Module Name: CSA_16bit
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


module CSA_16bit(
    input [15:0] a,
    input [15:0] b,
    input [15:0] c,
    output [16:0] s,
    output c_out

    );
    wire [15:0] s_int; //intermediate sum from individual bit addition
    wire [15:0] c_int;
    wire [15:0] c_int_prop;//carry which is propagated in the final stage
    
    genvar i;
    //Parallel full adders
    generate
        for(i=0;i<16;i=i+1) begin: loop1
        FullAdder FA_inst1(.x(a[i]),
                 .y(b[i]),
                 .z(c[i]),
                 .s(s_int[i]),
                 .c(c_int[i]));
        
        end 
    endgenerate
    
    assign s[0]=s_int[0];
    assign c_int_prop[0]=0;
    
    //Ripple Carry Adders
    generate 
        for(i=0;i<15;i=i+1) begin :loop2
            FullAdder FA_inst2(.x(c_int[i]),
                 .y(s_int[i+1]),
                 .z(c_int_prop[i]),
                 .s(s[i+1]),
                 .c(c_int_prop[i+1]));
        end
        
    endgenerate
    
    FullAdder FA_inst3(.x(c_int[15]),
                 .y(0),
                 .z(c_int_prop[15]),
                 .s(s[16]),
                 .c(c_out));
    
    
endmodule
