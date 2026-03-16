module teste_audio_piano (
    input        CLOCK_50,   // Pin AF14
    input        reset_n,    // KEY0 da placa (reset e ativo baixo)
    input  [6:0] gpio_keys,  // 7 pinos vindos do Waveforms (Dó a Si)
    input  [1:0] sw_oitava,  // Switches SW[1:0] para testar transposição
    input  [3:0] sw_volume,  // Switches SW[5:2] para controle de volume
    output       buzzer      // Pino de saída para o Buzzer Passivo
);

    wire [2:0] s_nota_id;
    wire [17:0] s_n_ticks;
    wire s_tem_nota;
    wire reset = !reset_n;
    wire [6:0] s_botoes_limpos; // Sinal sem "trepidação"

    debounce_nivel debouncer (
        .clock(CLOCK_50),
        .reset(reset),
        .botoes_in(gpio_keys),
        .botoes_out(s_botoes_limpos)
    );

    // 1. Lógica de Prioridade (Override)
    note_priority_logic logic_inst (
        .clock(CLOCK_50),
        .reset(reset),
        .botoes(s_botoes_limpos),
        .nota_id(s_nota_id),
        .tem_nota(s_tem_nota)
    );

    // 2. Tabela de Frequências (Software/LUT)
    frequency_lut lut_inst (
        .nota_id(s_nota_id),
        .oitava(sw_oitava),
        .n_ticks(s_n_ticks)
    );

    // 3. Gerador de Áudio (PWM)
    audio_generator audio_inst (
        .clock(CLOCK_50),
        .reset(reset),
        .fim_contagem(s_n_ticks),
        .volume(sw_volume),
        .habilitar(s_tem_nota),
        .buzzer(buzzer)
    );

endmodule