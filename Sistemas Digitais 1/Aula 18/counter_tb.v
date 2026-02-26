module tb_counter;
    reg clk;
    reg reset;
    wire [3:0] Q;

    // Instantiate the counter module
    counter uut (
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    // Generate clock signal
    always #5 clk = ~clk; // Clock period is 10 time units

    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;

        // Apply reset
        reset = 1;
        #10;
        reset = 0;

        // Observe the counter for a few clock cycles
        #100;

        // Finish simulation
        $finish;
    end

    initial begin
        // Monitor the signals
        $monitor("Time = %0t, clk = %b, reset = %b, Q = %b", $time, clk, reset, Q);
    end
endmodule