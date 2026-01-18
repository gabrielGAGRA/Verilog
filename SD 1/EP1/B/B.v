module ep01B (a, b, c, d, f);
    input a, b, c, d;
    output f;

    // coloque aqui a descricao do circuito
    assign f = (a & b) | (a & c) | (b & c) | (b & d);
endmodule
