`timescale 1ns/1ns

module tb_cenario_vi;
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

    initial begin
        clock = 0; reset = 0; jogar = 0; botoes = 0; configuracao = 0;
        #10 reset = 1; #40 reset = 0; #40;

        // ------------ Cenário vi: Dois jogos simultâneos sem reset (Consecutivos sem reset) ------------
        $display(">>> CENARIO vi: Dois jogos seguidos SEM reset entre eles");
        
        // Jogo 1: Erro rapido
        configuracao = 2'b00;
        jogar = 1; #40 jogar = 0;
        wait_leds(1);
        press_button(4'b1111); // Erro
        wait(perdeu);
        #500;
        
        // Jogo 2: Iniciar imediatamente sem pulso de RESET
        $display(">>> Iniciando Jogo 2 apenas com botao jogar...");
        jogar = 1; #40 jogar = 0;
        
        // Se o sistema reiniciou corretamente, deve estar esperando a sequencia
        wait(dut.unidade_controle.Eatual == 5'b00010); // carrega_led (indica que saiu dos estados finais)
        $display(">>> Jogo 2 iniciou corretamente!");
        
        wait_leds(1);
        press_button(4'b0001); // Acerto da primeira jogada
        
        #1000;
        if (dut.unidade_controle.Eatual != 5'b01100 && dut.unidade_controle.Eatual != 5'b01111) 
             $display(">>> Sucesso: Jogo fluiu normalmente.");
        else 
             $display(">>> FALHA: Jogo travado ou em erro.");
             
        $stop;
    end
endmodule
