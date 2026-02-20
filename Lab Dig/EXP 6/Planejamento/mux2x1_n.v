module mux2x1_n #(
    parameter N = 4
) (
    input  [N-1:0] D0,
    input  [N-1:0] D1,
    input          S,
    output [N-1:0] Y
);
    assign Y = (S) ? D1 : D0;
endmodule
