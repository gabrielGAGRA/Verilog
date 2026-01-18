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
    initial CLK = 0;
    always #5 CLK = ~CLK; // Clock period of 10 units

    // Monitor internal signals
    initial begin
        $monitor("Time=%0t | CLK=%b | RESET=%b | G=%b | LOADB=%b | LOADQ=%b | MULT_IN=%b | MULT_OUT=%b | MULT_FINISH=%b",
                 $time, CLK, RESET, G, LOADB, LOADQ, MULT_IN, MULT_OUT, MULT_FINISH);
    end

    initial begin
        // Initialize inputs
        RESET = 1;
        G = 0;
        LOADB = 0;
        LOADQ = 0;
        MULT_IN = 0;

        // Wait for a few clock cycles
        #20;
        RESET = 0;

        // Test Case 1: Multiply 3 * 2
        test_multiply(4'd3, 4'd2);

        // Wait before next test case
        #50;

        // Test Case 2: Multiply 7 * 5
        test_multiply(4'd7, 4'd5);

        // Wait before next test case
        #50;

        // Test Case 3: Multiply 15 * 15
        test_multiply(4'd15, 4'd15);

        // Finish simulation after all test cases
        #100;
        $finish;
    end

    task test_multiply;
        input [N-1:0] multiplicand;
        input [N-1:0] multiplier;
        begin
            // Display test case info
            $display("\nStarting multiplication: %d * %d", multiplicand, multiplier);

            // Load multiplicand (B)
            @(negedge CLK);
            LOADB = 1;
            MULT_IN = multiplicand;
            @(negedge CLK);
            LOADB = 0;

            // Load multiplier (Q)
            @(negedge CLK);
            LOADQ = 1;
            MULT_IN = multiplier;
            @(negedge CLK);
            LOADQ = 0;

            // Start multiplication
            @(negedge CLK);
            G = 1;
            @(negedge CLK);
            G = 0;

            // Wait for multiplication to finish
            wait (MULT_FINISH == 1);

            // Display result
            $display("Result of %d * %d = %d (Expected %d)", multiplicand, multiplier, MULT_OUT, multiplicand * multiplier);
        end
    endtask

endmodule