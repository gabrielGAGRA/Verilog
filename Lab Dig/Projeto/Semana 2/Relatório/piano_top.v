// ---------------------------------------------------------------------------
// Modulo: piano_top
// Descricao: Top-Level do MVP do Piano Adaptativo. Interliga Fluxo de Dados e Controle.
// ---------------------------------------------------------------------------
module piano_top (
    input        CLOCK_50,
    input        reset_n,       // Ativo baixo
    input  [6:0] gpio_keys,     // 7 notas
    input        btn_modo,      // Troca os modos
    
    // Pinos futuros
    // input  [1:0] sw_oitava, 
    // input  [3:0] sw_volume, 

    // Saídas Físicas
    output       buzzer,        // Sai no pino pro buzzer (Onda quadrada)
    output [6:0] led_vermelho,  // Feedback de notas na placa (LEDR)
    
    // RF_STATUS_HEX
    output [6:0] hex0_estado,   // Modo atual (0, 1, 2)
    output [6:0] hex1_oitava,   // Oitava atual (1, 2, 3)
    output [6:0] hex3_indice,   // Índice da música (Unidade)
    output [6:0] hex4_indice,   // Índice da música (Dezena)
    output [6:0] hex5_cifra     // Cifra da nota atual (A - G)
);

    wire reset = ~reset_n; // Inverte para ativo alto para os modulos internos

    // Fios Debounced
    wire [6:0] s_gpio_keys_db;
    wire       s_btn_modo_db;

    // Debouncers unificados (NF_DEBOUNCING_NIVEL)
    // Instancia generica para as teclas do piano (7 bits)
    debounce #(.WIDTH(7), .TEMPO_FILTRO(50_000)) db_notas (
        .clock(CLOCK_50),
        .reset(reset),
        .in(gpio_keys),
        .out(s_gpio_keys_db)
    );

    // Instancia generica para o botao de modo (1 bit)
    debounce #(.WIDTH(1), .TEMPO_FILTRO(250_000)) db_modo (
        .clock(CLOCK_50),
        .reset(reset),
        .in(btn_modo),
        .out(s_btn_modo_db)
    );

    // Sinais de interligação FSM <-> Fluxo de Dados
    wire fsm_modo_apr, fsm_zera_end, fsm_conta_end;
    wire fd_tem_nota_ativa, fd_acerto_nota, fd_fim_musica;
    wire [4:0] dbg_estado;
    wire [3:0] fd_endereco_ram;
    wire [2:0] fd_id_nota;

    // FSM (RF_MODOS)
    unidade_controle fsm_inst (
        .clock(CLOCK_50),
        .reset(reset),
        .btn_modo(s_btn_modo_db),
        .tem_nota_ativa(fd_tem_nota_ativa),
        .acerto_nota(fd_acerto_nota),
        .fim_musica(fd_fim_musica),
        .modo_aprendizado(fsm_modo_apr),
        .zera_endereco(fsm_zera_end),
        .conta_endereco(fsm_conta_end),
        .estado_hex(dbg_estado)
    );

    // Caminho de Dados Principal
    fluxo_dados fluxo_inst (
        .clock(CLOCK_50),
        .reset(reset),
        .botoes(s_gpio_keys_db),
        .sw_oitava(2'd0), 
        .sw_volume(4'd8), // Nao usado, PWM é 50%
        .modo_aprendizado(fsm_modo_apr),
        .conta_endereco(fsm_conta_end),
        .zera_endereco(fsm_zera_end),
        .buzzer(buzzer),
        .leds(hex5_cifra),
        .tem_nota_ativa(fd_tem_nota_ativa),
        .acerto_nota(fd_acerto_nota),
        .fim_musica(fd_fim_musica),
        .s_endereco_ram(fd_endereco_ram),
        .s_id_para_led(fd_id_nota)
    );

    // ==========================================
    // DECODIFICADORES PARA DISPLAYS (RF_STATUS_HEX)
    // ==========================================

    // HEX0: Modo atual (0=Inicio, 1=Livre, 2=Aprendizado)
    hexa7seg disp0_inst (
        .hexa(dbg_estado),
        .display(hex0_estado)
    );

    // HEX1: Oitava atual (fixamos exibir o valor 5 no display baseando na Oitava 5 central do Verilog)
    hexa7seg disp1_inst (
        .hexa(5'h5), // Valor fixado em 5 para reprensentar Dó5
        .display(hex1_oitava)
    );

    // HEX3 e HEX4: Índice da música (Endereco da RAM)
    wire [4:0] uni_idx = fd_endereco_ram % 10;
    wire [4:0] dez_idx = fd_endereco_ram / 10;

    hexa7seg disp3_inst (
        .hexa(uni_idx),
        .display(hex3_indice)
    );

    hexa7seg disp4_inst (
        .hexa(dez_idx),
        .display(hex4_indice)
    );

    // HEX5 é acionado diretamente pela saída leds cifra do fluxo_dados. 
    assign led_vermelho = gpio_keys;

endmodule
