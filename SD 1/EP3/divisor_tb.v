`timescale 1ns/1ps

module bcd_divider_tb;

    reg clk;
    reg rst;
    reg start;
    reg [15:0] dividend;
    reg [15:0] divisor;
    wire [15:0] quotient;
    wire [15:0] remainder;
    wire end_division;

    integer cycle_count;
    time start_time;
    time end_time;

    // Instantiate the BCD divider
    bcd_divider uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .end_division(end_division)
    );

    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Task to measure runtime
    task measure_runtime;
        input [15:0] test_dividend;
        input [15:0] test_divisor;
        integer local_cycle_count;
        time local_start_time;
        time local_end_time;
    begin
        // Apply reset before starting
        rst = 1;
        #15;
        rst = 0;
        @(posedge clk);

        // Apply test inputs
        dividend = test_dividend;
        divisor  = test_divisor;
        start = 1;
        local_cycle_count = 0;
        local_start_time = $time;

        @(posedge clk);
        start = 0;

        // Count clock cycles
        while (!end_division) begin
            @(posedge clk);
            local_cycle_count = local_cycle_count + 1;
        end
        local_end_time = $time;

        #10;
        $display("\nDividend = %h, Divisor = %h", test_dividend, test_divisor);
        $display("Quotient = %h, Remainder = %h", quotient, remainder);
        $display("Clock cycles taken = %0d", local_cycle_count);
        $display("Simulation time taken = %0t ns", local_end_time - local_start_time);
    end
    endtask

    // Stimuli
    initial begin
        // Initial reset
        rst = 1;
        start = 0;
        dividend = 16'h0000;
        divisor = 16'h0000;
        #15;
        rst = 0;

        // Wait for a clock edge to ensure reset is processed
        @(posedge clk);

        // Test Case 1: 144 / 9 = 16 R0
        measure_runtime(16'h0144, 16'h0009); // 144 / 9

        // Test Case 2: 150 / 4 = 37 R2
        measure_runtime(16'h0150, 16'h0004); // 150 / 4

        // Test Case 3: 200 / 2 = 100 R0
        measure_runtime(16'h0200, 16'h0002); // 200 / 2

        // Test Case 4: 50 / 3 = 16 R2
        measure_runtime(16'h0050, 16'h0003); // 50 / 3

        // Test Case 5: 99 / 9 = 11 R0
        measure_runtime(16'h0099, 16'h0009); // 99 / 9

        // Test Case 6: 123 / 4 = 30 R3
        measure_runtime(16'h0123, 16'h0004); // 123 / 4

        // Test Case 7: 150 / 5 = 30 R0
        measure_runtime(16'h0150, 16'h0005); // 150 / 5

        // Test Case 8: 25 / 7 = 3 R4
        measure_runtime(16'h0025, 16'h0007); // 25 / 7

        // Test Case 9: 100 / 0 = Undefined
        measure_runtime(16'h0100, 16'h0000); // 100 / 0

        // Test Case 10: 0 / 5 = 0 R0
        measure_runtime(16'h0000, 16'h0005); // 0 / 5

        $finish;
    end

endmodule