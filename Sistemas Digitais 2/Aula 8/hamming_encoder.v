module hamming_enc (
    input [4:1] data,
    output [7:1] code
);

    wire d7 = data[4];
    wire d6 = data[3];
    wire d5 = data[2];
    wire d3 = data[1];

    wire p1 = d3 ^ d5 ^ d7;
    wire p2 = d3 ^ d6 ^ d7;
    wire p4 = d5 ^ d6 ^ d7;

    assign code[7] = d7;
    assign code[6] = d6;
    assign code[5] = d5;
    assign code[4] = p4;
    assign code[3] = d3;
    assign code[2] = p2;
    assign code[1] = p1;

endmodule