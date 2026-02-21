`timescale 1ns/1ns

module jogo_desafio_memoria_tb;

    // =========================================================================
    // Declaração de Sinais
    // =========================================================================
    reg clock;
    reg reset;
    reg jogar;
    reg [1:0] configuracao;
    reg [3:0] botoes;

    wire [2:0] leds_rgb;
    wire ganhou;
    wire perdeu;
    wire pronto;
    wire timeout;
    wire [3:0] leds;

    // Sinais de depuração
    wire db_igual;
    wire [6:0] db_contagem;
    wire [6:0] db_memoria;
    wire [6:0] db_estado;
    wire [6:0] db_jogadafeita;
    wire db_clock;
    wire db_iniciar;
    wire db_enderecoIgualLimite;
    wire db_timeout;
    wire db_modo;
    wire [6:0] db_limite_rodada;

    // =========================================================================
    // Instanciação do DUT (Device Under Test)
    // =========================================================================
    jogo_desafio_memoria dut (
        .clock(clock),
        .reset(reset),
        .jogar(jogar),
        .configuracao(configuracao),
        .botoes(botoes),
        .leds_rgb(leds_rgb),
        .ganhou(ganhou),
        .perdeu(perdeu),
        .pronto(pronto),
        .timeout(timeout),
        .leds(leds),
        .db_igual(db_igual),
        .db_contagem(db_contagem),
        .db_memoria(db_memoria),
        .db_estado(db_estado),
        .db_jogadafeita(db_jogadafeita),
        .db_clock(db_clock),
        .db_iniciar(db_iniciar),
        .db_enderecoIgualLimite(db_enderecoIgualLimite),
        .db_timeout(db_timeout),
        .db_modo(db_modo),
        .db_limite_rodada(db_limite_rodada)
    );

    // =========================================================================
    // Geração de Clock (50 MHz -> Período de 20ns)
    // =========================================================================
    always #10 clock = ~clock;

    // =========================================================================
    // Tarefas Auxiliares para Simulação
    // =========================================================================
    
    // Tarefa para aguardar a exibição da sequência de LEDs
    task wait_leds;
        input integer num_leds;
        integer i;
        begin
            for (i = 0; i < num_leds; i = i + 1) begin
                // Aguarda o LED acender (estado mostra_led = 4'b0011)
                wait(dut.unidade_controle.Eatual == 4'b0011);
                // Aguarda o LED apagar (estado mostra_apagado = 4'b0101)
                wait(dut.unidade_controle.Eatual == 4'b0101);
            end
            // Aguarda a máquina ir para o estado de espera (4'b0111)
            wait(dut.unidade_controle.Eatual == 4'b0111);
            #100; // Pequeno atraso para estabilidade
        end
    endtask

    // Tarefa para simular o pressionamento de um botão
    task press_button;
        input [3:0] btn;
        begin
            botoes = btn;
            #200; // Mantém o botão pressionado por 200ns (10 ciclos de clock)
            botoes = 4'b0000;
            #200; // Aguarda 200ns antes da próxima ação
        end
    endtask

    // =========================================================================
    // Bloco Principal de Teste
    // =========================================================================
    initial begin
        // Configuração inicial para o ModelSim
        $display("==================================================");
        $display("Iniciando Testbench: Jogo Desafio Memoria");
        $display("==================================================");

        // Inicialização dos sinais
        clock = 0;
        reset = 0;
        jogar = 0;
        configuracao = 2'b00;
        botoes = 4'b0000;

        // Aplica o Reset
        $display("[%0t] Aplicando Reset...", $time);
        #10 reset = 1;
        #40 reset = 0;
        #40;

        // ---------------------------------------------------------------------
        // TESTE 1: Jogo Completo (Modo Demonstração - 4 rodadas) sem timeout
        // ---------------------------------------------------------------------
        $display("\n[%0t] ---> INICIANDO TESTE 1: Vitoria no Modo Demonstracao", $time);
        // configuracao[0] = 1 (modo demonstração: 4 rodadas)
        // configuracao[1] = 0 (timeout desabilitado)
        configuracao = 2'b01; 
        
        // Pulso no botão jogar
        jogar = 1;
        #40 jogar = 0;

        // Rodada 1 (Limite = 0)
        $display("[%0t] Rodada 1: Aguardando LEDs...", $time);
        wait_leds(1);
        $display("[%0t] Rodada 1: Inserindo jogada (0001)...", $time);
        press_button(4'b0001); // Acerta a cor inicial da RAM
        
        // Aguarda estado de adicionar nova cor (adiciona_jogada = 4'b1101)
        wait(dut.unidade_controle.Eatual == 4'b1101); 
        $display("[%0t] Rodada 1: Adicionando nova cor (0010)...", $time);
        press_button(4'b0010); // Adiciona azul

        // Rodada 2 (Limite = 1)
        $display("[%0t] Rodada 2: Aguardando LEDs...", $time);
        wait_leds(2);
        $display("[%0t] Rodada 2: Inserindo jogadas (0001, 0010)...", $time);
        press_button(4'b0001);
        press_button(4'b0010);
        
        wait(dut.unidade_controle.Eatual == 4'b1101);
        $display("[%0t] Rodada 2: Adicionando nova cor (0100)...", $time);
        press_button(4'b0100); // Adiciona amarelo

        // Rodada 3 (Limite = 2)
        $display("[%0t] Rodada 3: Aguardando LEDs...", $time);
        wait_leds(3);
        $display("[%0t] Rodada 3: Inserindo jogadas (0001, 0010, 0100)...", $time);
        press_button(4'b0001);
        press_button(4'b0010);
        press_button(4'b0100);
        
        wait(dut.unidade_controle.Eatual == 4'b1101);
        $display("[%0t] Rodada 3: Adicionando nova cor (1000)...", $time);
        press_button(4'b1000); // Adiciona verde

        // Rodada 4 (Limite = 3) - Última rodada
        $display("[%0t] Rodada 4: Aguardando LEDs...", $time);
        wait_leds(4);
        $display("[%0t] Rodada 4: Inserindo jogadas finais (0001, 0010, 0100, 1000)...", $time);
        press_button(4'b0001);
        press_button(4'b0010);
        press_button(4'b0100);
        press_button(4'b1000);

        // Aguarda estado de vitória (final_acerto = 4'b1011)
        wait(ganhou == 1);
        $display("[%0t] TESTE 1 CONCLUIDO: Vitoria detectada com sucesso!", $time);
        #1000;

        // ---------------------------------------------------------------------
        // TESTE 2: Erro do jogador
        // ---------------------------------------------------------------------
        $display("\n[%0t] ---> INICIANDO TESTE 2: Erro do jogador", $time);
        
        // Inicia um novo jogo
        jogar = 1;
        #40 jogar = 0;

        // Rodada 1
        $display("[%0t] Rodada 1: Aguardando LEDs...", $time);
        wait_leds(1);
        $display("[%0t] Rodada 1: Inserindo jogada ERRADA (1000)...", $time);
        press_button(4'b1000); // Erra de propósito (esperado era 0001)

        // Aguarda estado de erro (final_erro = 4'b1100)
        wait(perdeu == 1);
        $display("[%0t] TESTE 2 CONCLUIDO: Erro detectado corretamente!", $time);
        #1000;

        // ---------------------------------------------------------------------
        // TESTE 3: Timeout
        // ---------------------------------------------------------------------
        $display("\n[%0t] ---> INICIANDO TESTE 3: Timeout", $time);
        // configuracao[0] = 1 (modo demonstração)
        // configuracao[1] = 1 (timeout habilitado)
        configuracao = 2'b11; 
        
        // Inicia um novo jogo
        jogar = 1;
        #40 jogar = 0;

        // Rodada 1
        $display("[%0t] Rodada 1: Aguardando LEDs...", $time);
        wait_leds(1);
        
        $display("[%0t] Rodada 1: Aguardando estourar o tempo (timeout)...", $time);
        // Não pressiona nenhum botão e aguarda o sinal de timeout
        wait(dut.timeout == 1);
        $display("[%0t] TESTE 3 CONCLUIDO: Timeout detectado corretamente!", $time);
        #1000;

        // Fim da simulação
        $display("\n==================================================");
        $display("[%0t] TODOS OS TESTES FORAM CONCLUIDOS COM SUCESSO!", $time);
        $display("==================================================");
        $stop;
    end

endmodule