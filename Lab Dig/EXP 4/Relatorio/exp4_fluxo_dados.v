module exp4_fluxo_dados (
    input        clock,
    input        zeraC,
    input        contaC,
    input        zeraR,
    input reset,
    input        registrarR,
    input  [3:0] chaves,
    output       igual,
    output       fimC,
    output       jogada_feita,      // Pulso do edge_detector
    output       db_tem_jogada,     // Saída da porta OR
    output db_enable_timeout,
    output [3:0] db_contagem,
    output [3:0] db_memoria,
    output timeout,
    output [3:0] db_jogada,
    output db_zera_s_timeout
);
    wire [3:0] s_endereco;
    wire [3:0] s_dado, s_chaves;
    wire       s_tem_jogada;
    wire enable_timeout;
    wire zera_s_timeout;

    // porta OR para detectar se qualquer chave foi pressionada
    assign s_tem_jogada = |chaves; 
    assign db_tem_jogada = s_tem_jogada;
    // enable timeout quando nao tem jogada
    assign enable_timeout = ~s_tem_jogada;
    assign db_enable_timeout = enable_timeout;

    // detector de borda para gerar pulso de 1 clock
    edge_detector detector (
        .clock(clock),
        .reset(reset), // reset global
        .sinal(s_tem_jogada),
        .pulso(jogada_feita)
    );

    contador_m #(
        .M(3000),
        .N(12)
    ) contador_timeout (
        .clock(clock),
        .zera_as(1'b0),
        .zera_s(zera_s_timeout), //sinal proprio de zera s
        .conta(enable_timeout), //se nao tem jogada
        .Q(),
        .fim(timeout),
        .meio()
    );

    contador_163 contador (
        .clock(clock),
        .clr(~zeraC),
        .ld(1'b1),
        .ent(1'b1),
        .enp(contaC),
        .D(4'b0000),
        .Q(s_endereco),
        .rco(fimC)
    );

    comparador_85 comparador (
        .A(s_dado),
        .B(s_chaves),
        .ALBi(1'b0), .AGBi(1'b0), .AEBi(1'b1),
        .AEBo(igual)
    );

    registrador_4 registrador (
        .clock(clock),
        .clear(zeraR),
        .enable(registrarR),
        .D(chaves),
        .Q(s_chaves)
    );

    sync_rom_16x4 memoria (
        .clock(clock),
        .address(s_endereco),
        .data_out(s_dado)
    );

    assign db_contagem = s_endereco;
    assign db_jogada   = s_chaves;
    assign db_memoria  = s_dado;
    assign db_zera_s_timeout = zera_s_timeout;

endmodule