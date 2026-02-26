module bcd_adder_1digit (
    input [3:0] a, // Adendo A de 1 dígito BCD
    input [3:0] b, // Adendo B de 1 dígito BCD
    input cin, // Carry-in BCD
    output [3:0] sum, // Soma de 1 dígito BCD
    output cout // Carry-out BCD
);

    wire [4:0] soma_inicial;
    wire [3:0] soma_corrigida;
    wire carry_out;

    assign soma_inicial = a + b + cin;

    assign soma_corrigida = (soma_inicial > 9) ? (soma_inicial + 6) : soma_inicial;
    assign carry_out = (soma_inicial > 9) ? 1 : 0;

    assign sum = soma_corrigida[3:0];
    assign cout = carry_out;

endmodule

module bcd_adder_4digits (
    input [15:0] a, // Adendo A de 4 dígitos BCD
    input [15:0] b, // Adendo B de 4 dígitos BCD
    input cin, // Carry-in BCD
    output [15:0] sum, // Soma de 4 dígitos BCD
    output cout // Carry-out BCD
);

    wire [3:0] digito_soma [3:0];
    wire digito_cout [3:0];
    wire [15:0] soma_corrigida;

    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin : BCD_ADDERS
            if (i == 0) begin
                bcd_adder_1digit adder (
                    .a(a[3:0]),
                    .b(b[3:0]),
                    .cin(cin),
                    .sum(soma_corrigida[3:0]),
                    .cout(digito_cout[0])
                );
            end else begin
                bcd_adder_1digit adder (
                    .a(a[i*4 +: 4]),
                    .b(b[i*4 +: 4]),
                    .cin(digito_cout[i-1]),
                    .sum(soma_corrigida[i*4 +: 4]),
                    .cout(digito_cout[i])
                );
            end
        end
    endgenerate

    assign sum = soma_corrigida;
    assign cout = digito_cout[3];

endmodule