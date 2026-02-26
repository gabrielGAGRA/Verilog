module adder_rc 
    #(parameter N=4)
     (input [N-1:0] a,
      input [N-1:0] b,
      input ci,
      output [N-1:0] s,
      output co);
    // Escreva sua solução a partir daqui

    genvar i;
    wire [N:0] carry;

    assign carry[0] = ci;

    generate
      for (i = 0; i < N; i = i + 1) begin
        fa fa_inst (
          .a(a[i]),
          .b(b[i]),
          .ci(carry[i]),
          .s(s[i]),
          .co(carry[i+1])
        );
      end
    endgenerate

    assign co = carry[N];

endmodule