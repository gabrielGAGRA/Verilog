module ep01A (a, b, c, f);
    input a, b, c;
    output f;

    // coloque aqui a descricao do circuito
    assign f = ((b | c) & a) | (b & c);
endmodule