module shift_register #(
    parameter N = 4 // Default width of the shift register is 4 bits
)(
    input clk,              // Clock input
    input reset,            // Asynchronous reset input
    input data_in,          // Data input to be shifted in
    output reg [N-1:0] Q    // N-bit output representing
                            // the shift register content
);


   integer         i;

   generate
      always @(posedge clk) begin
         for (i = 1; i < N; i = i + 1) begin
            if (reset == 1) Q[i] = 0;
            if (reset == 0) Q[i] <= Q[i-1];
         end
         Q[0] <= data_in;
      end
   endgenerate
endmodule // shift_register
