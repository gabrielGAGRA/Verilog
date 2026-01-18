module adder_cl 
    #(parameter N=4)
     (input [N-1:0] a,
      input [N-1:0] b,
      input ci,
      output [N-1:0] s,
      output co);
    // Escreva sua solução a partir daqui

    wire [N:0] c;
    wire [N-1:0] p, g;

    generate
    assign c[0] = ci;
    genvar i;
    for (i = 0; i < N; i = i + 1) begin
      assign #3 p[i] = a[i] | b[i];
      assign #3 g[i] = a[i] & b[i];
      assign #6 c[i + 1] = g[i] | p[i] & c[i];
    end
    endgenerate

    assign co = c[N];

    generate
    for (i = 0; i < N; i = i + 1) begin
        fa fa_instantaneo (
          .a(a[i]),
          .b(b[i]),
          .ci(c[i]),
          .s(s[i]),
          .co(c[i+1])
        );
      end
    endgenerate
endmodule