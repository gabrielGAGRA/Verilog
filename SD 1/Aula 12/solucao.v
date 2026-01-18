module solucao (m, inta, intb, intc, intd, sa, sb, sc, sd, y);
    input m;
    input inta, intb, intc, intd;
    input sa, sb, sc, sd;
    output y;

    wire [1:0] prioridade;
    wire [3:0] sensores;
    wire int_selecionado_0, int_selecionado_1, int_selecionado_2;

    assign sensores = {sd, sc, sb, sa};

    codprisimples codificador (
        .i(sensores),
        .en(1'b1),
        .y(prioridade)
    );

    muxsimples mux0 (
        .a(inta),
        .b(intb),
        .s(prioridade[0]),
        .y(int_selecionado_0)
    );
    muxsimples mux1(
        .a(intc),
        .b(intd),
        .s(prioridade[0]),
        .y(int_selecionado_1)
    );
    muxsimples mux2(
        .a(int_selecionado_0),
        .b(int_selecionado_1),
        .s(prioridade[1]),
        .y(int_selecionado_2)
    );

    assign y = (m == 0) ? inta : int_selecionado_2;

endmodule

// Não inclua os módulos na sua solução!
// O juiz contém os módulos codprisimples e muxsimples fornecidos com este arquivo