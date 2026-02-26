module tb_bin2bcd;

  reg [13:0] bin;
  wire [15:0] bcd;

  bin2bcd #(.NUMBCDS(4), .NUMBIN(14)) uut (
    .bin(bin),
    .bcd(bcd)
  );

  initial begin
    // Test case 1: 0
    bin = 16'b00000000000000;
    #10;
    $display("bin: %h, bcd: %h", bin, bcd);

    // Test case 2: 10
    bin = 16'b00000000001010;
    #10;
    $display("bin: %h, bcd: %h", bin, bcd);

    // Test case 3: 255
    bin = 16'b00000011111111;
    #10;
    $display("bin: %h, bcd: %h", bin, bcd);

    // Test case 4: 9999
    bin = 16'd9999;
    #10;
    $display("bin: %h, bcd: %h", bin, bcd);

    // Test case 5: 16383 (excede o limite para NUMBCDS=4)
    bin = 16'b11111111111111;
    #10;
    $display("bin: %h, bcd: %h", bin, bcd);

    $finish;
  end

endmodule