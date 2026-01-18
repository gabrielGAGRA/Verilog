`timescale 1ns / 1ps

module bcd_adder_4digits_tb;

    // Inputs
    reg [15:0] a;
    reg [15:0] b;
    reg cin;

    // Outputs
    wire [15:0] sum;
    wire cout;

    // Instantiate the Unit Under Test (UUT)
    bcd_adder_4digits uut (
        .a(a), 
        .b(b), 
        .cin(cin), 
        .sum(sum), 
        .cout(cout)
    );

    initial begin
        // Initialize Inputs
        a = 16'h0000;
        b = 16'h0000;
        cin = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Apply test vectors
        a = 16'h1234; b = 16'h5678; cin = 0; #100;
        $display("a = %h, b = %h, cin = %b -> sum = %h, cout = %b", a, b, cin, sum, cout);

        a = 16'h9999; b = 16'h0001; cin = 0; #100;
        $display("a = %h, b = %h, cin = %b -> sum = %h, cout = %b", a, b, cin, sum, cout);

        a = 16'h4321; b = 16'h8765; cin = 1; #100;
        $display("a = %h, b = %h, cin = %b -> sum = %h, cout = %b", a, b, cin, sum, cout);

        a = 16'h0000; b = 16'h0000; cin = 1; #100;
        $display("a = %h, b = %h, cin = %b -> sum = %h, cout = %b", a, b, cin, sum, cout);

        a = 16'h9999; b = 16'h9999; cin = 1; #100;
        $display("a = %h, b = %h, cin = %b -> sum = %h, cout = %b", a, b, cin, sum, cout);

        // Add more test vectors as needed

        // Finish simulation
        $finish;
    end
      
endmodule