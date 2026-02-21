module jogo_desafio_memoria(
     input clock,
    input reset,
    input jogar,
    input [1:0] configuracao,
    input [3:0] botoes,
    input        conf_leds,
    output [2:0] leds_rgb,
    output ganhou,
    output perdeu,
    output pronto,
    output timeout
    output [3:0] leds,
    //db
    output       db_igual,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado,
    output [6:0] db_jogadafeita,
    output       db_clock,
    output       db_iniciar,
    output       db_enderecoIgualLimite,
    output       db_timeout,
    output       db_modo,
    output [6:0] db_limite_rodada, // ver a rodada nos displays
);

    wire zera_endereco, conta_endereco, zera_limite, conta_limite;
    wire zeraR, registraR, igual, tem_jogada, jogada_feita, enable_timeout, zera_s_timeout, s_pulso_timeout;
    wire registra_modo, zera_modo, s_modo;
    wire enderecoIgualLimite, fim_jogo;
    wire timout_led, fim_sequencia, conf_leds, registra_jogada, zera_s_led, enable_led;
    wire [6:0] hexa0, hexa1, hexa2, hexa3, hexa5;
    wire [3:0] s_contagem, s_memoria, s_estado, s_jogada, s_limite;
	 
    fluxo_dados fluxo_dados(
        .clock(clock),
        .zera_endereco(zera_endereco),
        .conta_endereco(conta_endereco),
        .zera_limite(zera_limite),
        .conta_limite(conta_limite),
        .zeraR(zeraR),
        .reset(reset),
        .registrarR(registraR),
        .zera_s_timeout(zera_s_timeout),
        .enable_timeout(enable_timeout),
        .botoes(botoes),
        .modo(modo),
        .registra_modo(registra_modo),
        .zera_modo(zera_modo),
        .conf_leds(conf_leds),
        .registra_jogada(registra_jogada),
        .zera_s_led(zera_s_led),
        .enable_led(enable_led),
        .igual(igual),
        .fim_jogo(fim_jogo),
        .enderecoIgualLimite(enderecoIgualLimite),
        .jogada_feita(jogada_feita),
        .db_tem_jogada(tem_jogada),
        .db_enable_timeout(),
        .db_contagem(s_contagem),
        .db_memoria(s_memoria),
        .db_limite(s_limite),
        .timeout(s_pulso_timeout),
        .db_jogada(s_jogada),
        .db_modo(s_modo),
        .leds_rgb(leds_rgb),
        .timeout_led(timeout_led),
        .fim_sequencia(fim_sequencia)
    );

    unidade_controle unidade_controle(
        .clock(clock),
        .reset(reset),
        .iniciar(jogar),              
        .fim_jogo(fim_jogo),
        .enderecoIgualLimite(enderecoIgualLimite),
        .jogada(jogada_feita),
        .igual(igual),
        .timeout(s_pulso_timeout),
        .timeout_led(timeout_led),
        .fim_sequencia(fim_sequencia),
        .zera_endereco(zera_endereco),
        .conta_endereco(conta_endereco),
        .zera_limite(zera_limite),
        .conta_limite(conta_limite),
        .zeraR(zeraR),
        .registrarR(registraR),
        .registra_modo(registra_modo),
        .zera_modo(zera_modo),
        .acertou(ganhou),              
        .errou(perdeu),                
        .pronto(pronto),
        .db_estado(s_estado),
        .db_timeout(timeout),
        .zera_s_timeout(zera_s_timeout),
        .enable_timeout(enable_timeout),
        .conf_leds(conf_leds),
        .registra_jogada(registra_jogada),
        .zera_s_led(zera_s_led),
        .enable_led(enable_led)
    );

    hexa7seg HEX0 ( .hexa(s_contagem), .display(hexa0) );
    hexa7seg HEX1 ( .hexa(s_memoria),  .display(hexa1) );
    hexa7seg HEX2 ( .hexa(s_jogada),   .display(hexa2) );
    hexa7seg HEX3 ( .hexa(s_limite),   .display(hexa3) );
    hexa7seg HEX5 ( .hexa(s_estado),   .display(hexa5) );

    assign db_iniciar = jogar;
    assign db_contagem = hexa0; 
    assign db_memoria = hexa1;
    assign db_jogadafeita = hexa2;
    assign db_limite_rodada = hexa3;
    assign db_estado = hexa5;
    assign db_enderecoIgualLimite = enderecoIgualLimite; 
    assign db_igual = igual;
    assign db_clock = clock;
    assign db_modo = s_modo;
    assign db_timeout = timeout;

endmodule