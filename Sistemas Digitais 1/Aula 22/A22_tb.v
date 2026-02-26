`timescale 1ns / 1ps

module binary_multiplier_tb;

    parameter N = 4;

    reg CLK;
    reg RESET;
    reg G;
    reg LOADB;
    reg LOADQ;
    reg [N-1:0] MULT_IN;

    wire [2*N-1:0] MULT_OUT;
    wire MULT_FINISH;

    // Instantiate the multiplier
    binary_multiplier #(N) uut (
        .CLK(CLK),
        .RESET(RESET),
        .G(G),
        .LOADB(LOADB),
        .LOADQ(LOADQ),
        .MULT_IN(MULT_IN),
        .MULT_OUT(MULT_OUT),
        .MULT_FINISH(MULT_FINISH)
    );

    // Clock generation
    always begin
        #5 CLK = ~CLK; // 100MHz clock
    end

    initial begin
        // Initialize inputs
        CLK = 0;
        RESET = 1;
        G = 0;
        LOADB = 0;
        LOADQ = 0;
        MULT_IN = 0;

        // Reset sequence
        #10;
        RESET = 0;

        // Test case 1: Multiply 3 * 2
        #10;
        LOADB = 1;
        MULT_IN = 4'b0011; // Load 3 into B
        #10;
        LOADB = 0;
        LOADQ = 1;
        MULT_IN = 4'b0010; // Load 2 into Q
        #10;
        LOADQ = 0;
        G = 1; // Start multiplication
        #10;
        G = 0;

        // Wait for multiplication to finish
        wait (MULT_FINISH == 1);

        // Display result
        $display("Result of 3 * 2 = %d", MULT_OUT);

        // Finish simulation
        #20;
        $finish;
    end

endmodule