`timescale 1ns / 1ps

module bcd_comparator_4digits_tb;

    // Inputs
    reg [15:0] a;
    reg [15:0] b;

    // Outputs
    wire a_ge_b;

    // Instantiate the Unit Under Test (UUT)
    bcd_comparator_4digits uut (
        .a(a), 
        .b(b), 
        .a_ge_b(a_ge_b)
    );

    initial begin
        // Initialize Inputs
        a = 16'h0000;
        b = 16'h0000;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Apply test vectors
        a = 16'h1234; b = 16'h5678; #100;
        $display("a = %h, b = %h -> a_ge_b = %b", a, b, a_ge_b);

        a = 16'h9999; b = 16'h0001; #100;
        $display("a = %h, b = %h -> a_ge_b = %b", a, b, a_ge_b);

        a = 16'h4321; b = 16'h8765; #100;
        $display("a = %h, b = %h -> a_ge_b = %b", a, b, a_ge_b);

        a = 16'h0000; b = 16'h0000; #100;
        $display("a = %h, b = %h -> a_ge_b = %b", a, b, a_ge_b);

        a = 16'h9999; b = 16'h9999; #100;
        $display("a = %h, b = %h -> a_ge_b = %b", a, b, a_ge_b);

        // Add more test vectors as needed

        // Finish simulation
        $finish;
    end
      
endmodule