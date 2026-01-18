module adder(
    input [31:0] operand_1, operand_2,
    input clk, en,
    output reg [31:0] sum = 32'bz
);
    // IEEE 754 components extraction
    wire sign_a = operand_1[31];
    wire sign_b = operand_2[31];
    wire [7:0] exp_a = operand_1[30:23];
    wire [7:0] exp_b = operand_2[30:23];
    wire [22:0] frac_a = operand_1[22:0];
    wire [22:0] frac_b = operand_2[22:0];
    
    // Internal variables for calculation
    reg sign_result;
    reg [7:0] exp_result;
    reg [22:0] frac_result;
    reg [24:0] frac_a_extended, frac_b_extended;
    reg [24:0] frac_larger, frac_smaller;
    reg [24:0] aligned_smaller;
    reg [24:0] sum_fractions;
    reg [7:0] exp_larger;
    reg [7:0] shift_amount;
    
    // FP addition on enable signal
    always @(posedge clk) begin
        if (en) begin
            // Handle special cases
            if (exp_a == 0 && frac_a == 0) begin
                // If a is zero, result is b
                sum <= operand_2;
            end
            else if (exp_b == 0 && frac_b == 0) begin
                // If b is zero, result is a
                sum <= operand_1;
            end
            else begin
                // Normal case - simplified floating point addition
                
                // Step 1: Extend fractions with implicit bit and guard bit
                frac_a_extended = {|exp_a, frac_a, 1'b0};
                frac_b_extended = {|exp_b, frac_b, 1'b0};
                
                // Step 2: Determine which exponent is larger
                if (exp_a > exp_b) begin
                    exp_larger = exp_a;
                    frac_larger = frac_a_extended;
                    frac_smaller = frac_b_extended;
                    shift_amount = exp_a - exp_b;
                end
                else begin
                    exp_larger = exp_b;
                    frac_larger = frac_b_extended;
                    frac_smaller = frac_a_extended;
                    shift_amount = exp_b - exp_a;
                end
                
                // Step 3: Align fractions
                aligned_smaller = frac_smaller >> shift_amount;
                
                // Step 4: Add/subtract fractions based on signs
                if (sign_a == sign_b) begin
                    // Same sign: add fractions
                    sum_fractions = frac_larger + aligned_smaller;
                    sign_result = sign_a;
                end
                else begin
                    // Different signs: subtract smaller from larger
                    if (frac_larger >= aligned_smaller) begin
                        sum_fractions = frac_larger - aligned_smaller;
                        sign_result = (exp_a > exp_b) ? sign_a : sign_b;
                    end
                    else begin
                        sum_fractions = aligned_smaller - frac_larger;
                        sign_result = (exp_a > exp_b) ? ~sign_a : ~sign_b;
                    end
                end
                
                // Step 5: Normalize result
                exp_result = exp_larger;
                frac_result = sum_fractions[23:1]; // Extract the 23 bits of fraction
                
                // Handle overflow
                if (sum_fractions[24]) begin
                    frac_result = sum_fractions[24:2];
                    exp_result = exp_result + 1;
                end
                
                // Normalize for leading zeros (simplified)
                if (sum_fractions[23:1] == 0) begin
                    exp_result = 0; // Result is zero
                end
                
                // Combine sign, exponent and fraction
                sum = {sign_result, exp_result, frac_result};
            end
        end
    end
endmodule

module fpa_tb;
    // Outputs from DUT
    wire [31:0] ram_out;
    wire done;
    
    // Inputs to DUT
    reg [1:0] ram_addr;
    
    // Instantiate the DUT
    fpa dut (
        .ram_addr(ram_addr),
        .ram_out(ram_out),
        .done(done)
    );
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t | State=%0d | rom_addr=%0d | ram_addr=%0d | op1=%h | op2=%h | sum=%h | done=%b",
                 $time, dut.state, dut.rom_addr, dut.ram_addr_mux, dut.operand_1, dut.operand_2, 
                 dut.adder_sum, done);
    end
    
    // Test sequence
    initial begin
        $dumpfile("fpa_tb.vcd");
        $dumpvars(0, fpa_tb);
        
        // Initialize inputs
        ram_addr = 2'b00;
        
        // Wait for the FPA to complete its operations
        wait(done);
        
        // Read values from RAM
        #10;
        ram_addr = 2'b00;
        #10;
        $display("RAM[0] = %h", ram_out);
        
        ram_addr = 2'b01;
        #10;
        $display("RAM[1] = %h", ram_out);
        
        ram_addr = 2'b10;
        #10;
        $display("RAM[2] = %h", ram_out);
        
        ram_addr = 2'b11;
        #10;
        $display("RAM[3] = %h", ram_out);
        
        #10;
        $finish;
    end
endmodule