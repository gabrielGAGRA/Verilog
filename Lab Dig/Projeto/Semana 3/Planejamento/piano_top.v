// ---------------------------------------------------------------------------
// Modulo: piano_top
// Descricao: Top-Level do MVP do Piano Adaptativo. Interliga Fluxo de Dados e Controle.
// ---------------------------------------------------------------------------
module piano_top #(
    parameter DEBOUNCE_NOTAS = 500_000, // 10ms a 50MHz
    parameter DEBOUNCE_MODO  = 250_000 // 5ms a 50MHz
) (
    input        CLOCK_50,
    input        reset_n,       // Ativo baixo
    input  [6:0] gpio_keys,     // 7 notas
    input        btn_modo,      // Troca os modos
    input        btn_musica,    // Troca as musicas
    
    // Pinos futuros/atuais
    // input  [1:0] sw_oitava, 
    input  [3:0] sw_volume,     // Configura PWM do LED

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

    // Sinais de interligação FSM <-> Fluxo de Dados
    wire fsm_modo_apr, fsm_zera_end, fsm_conta_end;
    wire fd_tem_nota_ativa, fd_acerto_nota, fd_fim_musica;
    wire [4:0] dbg_estado;
    wire [10:0] fd_endereco_ram;
    wire [2:0] fd_id_nota;
    wire [1:0] s_sel_musica;
    wire [6:0] s_db_botoes;
    wire fd_mudou_modo;
    wire s_pwm_out;

    // FSM (RF_MODOS)
    unidade_controle fsm_inst (
        .clock(CLOCK_50),
        .reset(reset),
        .mudou_modo(fd_mudou_modo),
        .tem_nota_ativa(fd_tem_nota_ativa),
        .acerto_nota(fd_acerto_nota),
        .fim_musica(fd_fim_musica),
        .modo_aprendizado(fsm_modo_apr),
        .zera_endereco(fsm_zera_end),
        .conta_endereco(fsm_conta_end),
        .estado_hex(dbg_estado)
    );

    // Caminho de Dados Principal
    fluxo_dados #(
        .DEBOUNCE_NOTAS(DEBOUNCE_NOTAS),
        .DEBOUNCE_MODO(DEBOUNCE_MODO)
    ) fluxo_inst (
        .clock(CLOCK_50),
        .reset(reset),
        .botoes(gpio_keys),
        .btn_modo(btn_modo),
        .btn_musica(btn_musica),
        .sw_oitava(2'd0), 
        .sw_volume(sw_volume), // Configuracao de sensibilidade (PWM)
        .modo_aprendizado(fsm_modo_apr),
        .conta_endereco(fsm_conta_end),
        .zera_endereco(fsm_zera_end),
        .buzzer(buzzer),
        .leds(hex5_cifra),
        .mudou_modo(fd_mudou_modo),
        .tem_nota_ativa(fd_tem_nota_ativa),
        .acerto_nota(fd_acerto_nota),
        .fim_musica(fd_fim_musica),
        .s_endereco_ram(fd_endereco_ram),
        .s_id_para_led(fd_id_nota),
        .out_sel_musica(s_sel_musica),
        .db_botoes(s_db_botoes),
        .pwm_out(s_pwm_out)
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
        .hexa(5'h2), // Valor fixado em 5 para reprensentar Dó5
        .display(hex1_oitava)
    );

    // HEX3 e HEX4: Índice da música
    wire [4:0] uni_idx = (s_sel_musica + 1) % 10;
    wire [4:0] dez_idx = ((s_sel_musica + 1) / 10) % 10;

    hexa7seg disp3_inst (
        .hexa(uni_idx),
        .display(hex3_indice)
    );

    hexa7seg disp4_inst (
        .hexa(dez_idx),
        .display(hex4_indice)
    );

    // HEX5 é acionado diretamente pela saída leds cifra do fluxo_dados. 
    
    // Multiplexador para acender LED pela nota pressionada (Livre) ou pela nota aguardada da RAM (Aprendizado)
    wire [6:0] raw_led = (fsm_modo_apr && fd_id_nota != 0) ? (7'b0000001 << (fd_id_nota - 1)) : s_db_botoes;
    
    // Controle de Sensibilidade: mascara com PWM para alterar itensidade
    assign led_vermelho = raw_led & {7{s_pwm_out}};

endmodule
