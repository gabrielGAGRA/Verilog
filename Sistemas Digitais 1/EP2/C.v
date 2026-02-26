module bcd_comparator_4digits (
    input [15:0] a, // A: número BCD de 4 dígitos
    input [15:0] b, // B: número BCD de 4 dígitos
    output a_ge_b   // Saída: se A >= B então 1, senão 0
);

    wire [3:0] a3 = a[15:12];
    wire [3:0] a2 = a[11:8];
    wire [3:0] a1 = a[7:4];
    wire [3:0] a0 = a[3:0];

    wire [3:0] b3 = b[15:12];
    wire [3:0] b2 = b[11:8];
    wire [3:0] b1 = b[7:4];
    wire [3:0] b0 = b[3:0];

    assign a_ge_b = (a3 > b3) ? 1'b1 :
                    (a3 < b3) ? 1'b0 :
                    (a2 > b2) ? 1'b1 :
                    (a2 < b2) ? 1'b0 :
                    (a1 > b1) ? 1'b1 :
                    (a1 < b1) ? 1'b0 :
                    (a0 >= b0) ? 1'b1 : 1'b0;

endmodule