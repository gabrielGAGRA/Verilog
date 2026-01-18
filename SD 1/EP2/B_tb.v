`timescale 1ns / 1ps

module bcd_subtractor_4digits_tb;

    // Inputs
    reg [15:0] a;
    reg [15:0] b;
    reg bin;

    // Outputs
    wire [15:0] diff;
    wire bout;

    // Instantiate the Unit Under Test (UUT)
    bcd_subtractor_4digits uut (
        .a(a), 
        .b(b), 
        .bin(bin), 
        .diff(diff), 
        .bout(bout)
    );

    initial begin
        // Initialize Inputs
        a = 16'h0000;
        b = 16'h0000;
        bin = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Apply test vectors
        a = 16'h1234; b = 16'h5678; bin = 0; #100;
        $display("a = %h, b = %h, bin = %b -> diff = %h, bout = %b", a, b, bin, diff, bout);

        a = 16'h9999; b = 16'h0001; bin = 0; #100;
        $display("a = %h, b = %h, bin = %b -> diff = %h, bout = %b", a, b, bin, diff, bout);

        a = 16'h4321; b = 16'h8765; bin = 1; #100;
        $display("a = %h, b = %h, bin = %b -> diff = %h, bout = %b", a, b, bin, diff, bout);

        a = 16'h0000; b = 16'h0000; bin = 1; #100;
        $display("a = %h, b = %h, bin = %b -> diff = %h, bout = %b", a, b, bin, diff, bout);

        a = 16'h9999; b = 16'h9999; bin = 1; #100;
        $display("a = %h, b = %h, bin = %b -> diff = %h, bout = %b", a, b, bin, diff, bout);

        // Add more test vectors as needed

        // Finish simulation
        $finish;
    end
      
endmodule