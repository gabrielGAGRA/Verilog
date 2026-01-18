module bcd_subtractor_1digit (
    input [3:0] a, // Minuend A de 1 dígito BCD
    input [3:0] b, // Subtraendo B de 1 dígito BCD
    input bin, // Borrow-in
    output [3:0] diff, // Diferença de 1 dígito BCD
    output bout // Borrow-out
);

    wire [4:0] raw_diff;
    wire [3:0] corrected_diff;
    wire borrow_out;

    assign raw_diff = {1'b0, a} - {1'b0, b} - bin;

    assign corrected_diff = (raw_diff[4] == 1) ? (raw_diff + 10) : raw_diff[3:0];
    assign borrow_out = (raw_diff[4] == 1) ? 1 : 0;

    assign diff = corrected_diff;
    assign bout = borrow_out;

endmodule

module bcd_subtractor_4digits (
    input [15:0] a, // Minuend A de 4-digitos BCD
    input [15:0] b, // Subtraendo B de 4-digitos BCD
    input bin, // Borrow-in
    output [15:0] diff, // Diferenca de 4-digit0s BCD
    output bout // Borrow-out
);
    wire [3:0] digit_diff [3:0];
    wire digit_bout [3:0];
    wire [15:0] corrected_diff;

    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin : BCD_SUBTRACTORS
            if (i == 0) begin
                bcd_subtractor_1digit subtractor (
                    .a(a[3:0]),
                    .b(b[3:0]),
                    .bin(bin),
                    .diff(corrected_diff[3:0]),
                    .bout(digit_bout[0])
                );
            end else begin
                bcd_subtractor_1digit subtractor (
                    .a(a[i*4 +: 4]),
                    .b(b[i*4 +: 4]),
                    .bin(digit_bout[i-1]),
                    .diff(corrected_diff[i*4 +: 4]),
                    .bout(digit_bout[i])
                );
            end
        end
    endgenerate

    assign diff = corrected_diff;
    assign bout = digit_bout[3];

endmodule