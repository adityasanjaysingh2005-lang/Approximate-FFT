`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Design Name: Error Tolerant Adder (ETA) 
// Target Precision: 1.3.12 Fixed Point (Accurate bits [15:5])
//////////////////////////////////////////////////////////////////////////////////

module error_tolerant_adder(
    input  signed [15:0] a, b,  // Added signed keyword
    output signed [16:0] sum    // Added signed keyword
    );
    
    wire [4:0] ctl_chain;
    wire [4:0] lsb_sum;
    wire [11:0] msb_sum; // 11-bit sum + 1-bit carry-out
    
    // --- INACCURATE PART (LSBs: 0 to 4) ---
    // Processed left-to-right starting from the demarcation line.
    // If a (1,1) pair is detected, all subsequent bits to the right are set to 1.
    modified_xor_adder i4 (.a(a[4]), .b(b[4]), .ctl_in(1'b0),         .ctl_out(ctl_chain[4]), .sum(lsb_sum[4]));
    modified_xor_adder i3 (.a(a[3]), .b(b[3]), .ctl_in(ctl_chain[4]), .ctl_out(ctl_chain[3]), .sum(lsb_sum[3]));
    modified_xor_adder i2 (.a(a[2]), .b(b[2]), .ctl_in(ctl_chain[3]), .ctl_out(ctl_chain[2]), .sum(lsb_sum[2]));
    modified_xor_adder i1 (.a(a[1]), .b(b[1]), .ctl_in(ctl_chain[2]), .ctl_out(ctl_chain[1]), .sum(lsb_sum[1]));
    modified_xor_adder i0 (.a(a[0]), .b(b[0]), .ctl_in(ctl_chain[1]), .ctl_out(ctl_chain[0]), .sum(lsb_sum[0]));
    
    // --- ACCURATE PART (MSBs: 5 to 15) ---
    // Conventional high-speed addition using Kogge-Stone logic.
    kogge_stone_11bit accurate_adder (
        .A(a[15:5]), 
        .B(b[15:5]), 
        .Sum(msb_sum)
    );

    // Final result assembly: [16:5] Accurate, [4:0] Inaccurate
    assign sum = {msb_sum, lsb_sum};

endmodule

// (The rest of your kogge_stone_11bit and modified_xor_adder logic remains identical)