module bin2bcd #(
  parameter NUMBCDS = 4,
  parameter NUMBIN = 16
) (
  input [NUMBIN-1:0] bin,
  output reg [NUMBCDS*4-1:0] bcd
);

  integer i, j;
  reg [NUMBCDS*4-1:0] bcd_temp;

  always @(bin) begin
    bcd_temp = 0;

    for (i = 0; i < NUMBIN; i = i + 1) begin
      for (j = 0; j < NUMBCDS; j = j + 1) begin
        if (bcd_temp[j*4 +: 4] >= 5)
          bcd_temp[j*4 +: 4] = bcd_temp[j*4 +: 4] + 4'd3;
      end
      
      bcd_temp = {bcd_temp, bin};
    end

    bcd = bcd_temp;
  end

endmodule