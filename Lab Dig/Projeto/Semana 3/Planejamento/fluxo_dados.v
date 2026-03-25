// ---------------------------------------------------------------------------
// Modulo: fluxo_dados
// Descricao: Caminho de dados unificado para Modo Livre e Aprendizado.
// ---------------------------------------------------------------------------
module fluxo_dados #(
    parameter DEBOUNCE_NOTAS = 500_000,
    parameter DEBOUNCE_MODO  = 250_000
) (
    input        clock,
    input        reset,

    // -- Entradas Físicas (Hardware) --
    input  [6:0] botoes,       // 7 notas
    input        btn_modo,     // Troca de modo
    input        btn_musica,   // Troca de musica
    input  [1:0] sw_oitava,    // Switches de transposição
    input  [3:0] sw_volume,    // Switches de PWM

    // -- Comandos da Unidade de Controle (FSM) --
    input        modo_aprendizado, // 1 = Aprendizado, 0 = Livre
    input        conta_endereco,
    input        zera_endereco,

    // -- Saídas Físicas (Hardware) --
    output       buzzer,
    output [6:0] leds,

    // -- Status para a Unidade de Controle (FSM) ou Top-Level --
    output       mudou_modo,       // Pulso de troca de modo
    output       tem_nota_ativa,   // Vai para 1 quando há alguma tecla pressionada
    output       acerto_nota,      // Vai para 1 quando a nota batida for igual a nota lida na RAM
    output       fim_musica,       // Vai para 1 quando o endereço chega no limite
    output [10:0] s_endereco_ram,   // Exportado para visualizacao (HEX)
    output [2:0] s_id_para_led,    // ID da nota atual para visualizacao (HEX cifrado)
    output [1:0] out_sel_musica,   // Seletor exportado pro display
    output [6:0] db_botoes,        // Botoes debounced para os LEDs
    output       pwm_out           // Sinal PWM para intensidade visual
);

    wire [6:0] s_botoes_db;
    wire s_btn_modo_db, s_btn_musica_db;
    
    // Debouncers
    debounce #(.WIDTH(7), .TEMPO_FILTRO(DEBOUNCE_NOTAS)) db_notas (
        .clock(clock), .reset(reset), .in(botoes), .out(s_botoes_db)
    );
    debounce #(.WIDTH(1), .TEMPO_FILTRO(DEBOUNCE_MODO)) db_modo (
        .clock(clock), .reset(reset), .in(btn_modo), .out(s_btn_modo_db)
    );
    debounce #(.WIDTH(1), .TEMPO_FILTRO(DEBOUNCE_MODO)) db_musica (
        .clock(clock), .reset(reset), .in(btn_musica), .out(s_btn_musica_db)
    );

    // Edge Detectors
    edge_detector ed_modo (
        .clock(clock), .reset(reset), .sinal(s_btn_modo_db), .pulso(mudou_modo)
    );
    wire s_btn_musica_pulse;
    edge_detector ed_musica (
        .clock(clock), .reset(reset), .sinal(s_btn_musica_db), .pulso(s_btn_musica_pulse)
    );

    // Registrador seletor de musica transformado em contador
    wire [1:0] s_sel_musica;
    contador_m #(.M(4), .N(2)) contador_musica (
        .clock(clock),
        .zera_as(1'b0),
        .zera_s(reset),
        .conta(s_btn_musica_pulse),
        .Q(s_sel_musica),
        .fim(),
        .meio()
    );

    assign out_sel_musica = s_sel_musica;
    assign db_botoes = s_botoes_db;

    wire [2:0] s_nota_tocada;
    wire       s_tem_nota;
    wire [17:0] s_n_ticks;
    
    wire [3:0] s_dado_ram;
    wire [2:0] s_nota_esperada = s_dado_ram[2:0]; // Ignora o MSB, usa só 1 a 7

    // 1. Logica de Áudio (Tempo Real)
    logica_notas_prioridade logic_inst (
        .clock(clock), .reset(reset),
        .botoes(s_botoes_db), .nota_id(s_nota_tocada), .tem_nota(s_tem_nota)
    );

    frequency_lut lut_inst (
        .nota_id(s_nota_tocada), 
        .n_ticks(s_n_ticks)
    );

    gerador_audio audio_inst (
        .clock(clock), .reset(reset),
        .fim_contagem(s_n_ticks), .habilitar(s_tem_nota),
        .buzzer(buzzer)
    );

    // 2. Logica de Memória e Endereçamento
    wire cont_fim;
    contador_m #(
        .M(2048), // Tamanho da musica / ROM maximo
        .N(11)
    ) contador_addr (
        .clock(clock),
        .zera_as(1'b0),
        .zera_s(zera_endereco),
        .conta(conta_endereco),
        .Q(s_endereco_ram),
        .fim(cont_fim),
        .meio()
    );

    wire [3:0] s_dado_ram1, s_dado_ram2;

    sync_rom #(
        .DATA_WIDTH(4),
        .ADDR_WIDTH(11),
        .INIT_FILE("do_re_mi.txt")
    ) memoria1 (
        .clock(clock),
        .address(s_endereco_ram),
        .data_out(s_dado_ram1)
    );

    sync_rom #(
        .DATA_WIDTH(4),
        .ADDR_WIDTH(11),
        .INIT_FILE("au_clair_de_la_lune.txt")
    ) memoria2 (
        .clock(clock),
        .address(s_endereco_ram),
        .data_out(s_dado_ram2)
    );

    // Mux de musicas
    assign s_dado_ram = (s_sel_musica == 2'd0) ? s_dado_ram1 : s_dado_ram2;

    // Multiplexador de LEDs.
    // No Modo Aprendizado: Mostra a nota vinda da memoria.
    // No Modo Livre: Mostra a nota vinda do teclado (botoes).
    assign s_id_para_led = (modo_aprendizado) ? s_nota_esperada : s_nota_tocada;

    // 3. Logica Visual e Comparação
    decodificador_cifra decoder_cifra_inst (
        .nota_id(s_id_para_led),
        .display(leds)
    );

    // O sinal de match fica em nível alto enquanto a nota certa for segurada
    wire s_match_cru = (s_nota_tocada == s_nota_esperada) && s_tem_nota && modo_aprendizado;

    // Exportação direta dos níveis lógicos para a máquina de estado (FSM)
    assign tem_nota_ativa = s_tem_nota;
    assign acerto_nota = s_match_cru;

    // 4. Modulação de Intensidade Visual (PWM) p/ Sensibilidade
    gerador_pwm pwm_inst (
        .clock(clock),
        .reset(reset),
        .duty_cycle(sw_volume),
        .pwm_out(pwm_out)
    );

endmodule