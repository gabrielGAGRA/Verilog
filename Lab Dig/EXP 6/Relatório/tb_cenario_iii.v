`timescale 1ns/1ns

module tb_cenario_iii;

    reg clock, reset, jogar;
    reg [1:0] configuracao;
    reg [3:0] botoes;
    wire [2:0] leds_rgb;
    wire ganhou, perdeu, pronto, timeout;
    wire [3:0] leds;
    
    // Debug signals
    wire db_igual, db_clock, db_iniciar, db_enderecoIgualLimite, db_timeout, db_modo, db_configuracao, db_escrita;
    wire [6:0] db_contagem, db_memoria, db_estado, db_jogadafeita, db_limite_rodada;

    jogo_desafio_memoria dut (
        .clock(clock), .reset(reset), .jogar(jogar), .configuracao(configuracao), .botoes(botoes),
        .leds_rgb(leds_rgb), .ganhou(ganhou), .perdeu(perdeu), .pronto(pronto), .timeout(timeout), .leds(leds),
        .db_igual(db_igual), .db_contagem(db_contagem), .db_memoria(db_memoria), .db_estado(db_estado),
        .db_jogadafeita(db_jogadafeita), .db_clock(db_clock), .db_iniciar(db_iniciar), .db_enderecoIgualLimite(db_enderecoIgualLimite),
        .db_timeout(db_timeout), .db_modo(db_modo), .db_configuracao(db_configuracao), .db_escrita(db_escrita), .db_limite_rodada(db_limite_rodada)
    );

    always #500 clock = ~clock;

    // Tasks duplicate for standalone file execution
    reg [3:0] sequencia [0:15];
    integer k;

    task wait_leds;
        input integer num_leds;
        integer i;
        begin
            for (i = 0; i < num_leds; i = i + 1) begin
                wait(dut.unidade_controle.Eatual == 5'b00011);
                wait(dut.unidade_controle.Eatual == 5'b00101);
            end
            wait(dut.unidade_controle.Eatual == 5'b00111);
            #100;
        end
    endtask

    task press_button;
        input [3:0] btn;
        begin
            botoes = btn; #200; botoes = 0; #200;
        end
    endtask

    task play_round;
        input integer n_rod;
        input integer is_last;
        integer j;
        begin
            $display("Rodada %0d", n_rod+1);
            wait_leds(n_rod + 1);
            for (j = 0; j <= n_rod; j = j + 1) begin
                press_button(sequencia[j]);
            end
            if (!is_last) begin
                wait(dut.unidade_controle.Eatual == 5'b01101);
                press_button(sequencia[n_rod+1]);
            end
        end
    endtask

    initial begin
        sequencia[0] = 4'b0001; sequencia[1] = 4'b0010; sequencia[2] = 4'b0100; sequencia[3] = 4'b1000;
        sequencia[4] = 4'b0001; sequencia[5] = 4'b0010; sequencia[6] = 4'b0100; sequencia[7] = 4'b1000;
        sequencia[8] = 4'b0001; sequencia[9] = 4'b0010; sequencia[10] = 4'b0100; sequencia[11] = 4'b1000;
        sequencia[12] = 4'b0001; sequencia[13] = 4'b0010; sequencia[14] = 4'b0100; sequencia[15] = 4'b1000;

        clock = 0; reset = 0; jogar = 0; botoes = 0; configuracao = 0;
        #10 reset = 1; #40 reset = 0; #40;

        // ------------ Cenário iii: Vitória no modo normal sem timeout (modo 00) ------------
        $display(">>> CENARIO iii: Vitoria Modo Normal (00)");
        configuracao = 2'b00; 
        jogar = 1; #40 jogar = 0;

        for (k = 0; k < 16; k = k + 1) begin
            play_round(k, (k==15));
        end

        wait(ganhou);
        $display(">>> Vitoria 16 rodadas confirmada!");
        $stop;
    end
endmodule
