module unidade_controle (
    input      clock,
    input      reset,
    input      iniciar,             // jogar
    input      fim_jogo,            // Limite atingiu o maximo e acabou a sequencia
    input      enderecoIgualLimite, // Fim da sequencia atual
    input      jogada,
    input      igual,
    input      timeout,
    input      timeout_led,
    input      fim_sequencia,
    output reg zera_endereco,       // Zera contador da sequencia
    output reg conta_endereco,      // Incrementa contador da sequencia
    output reg zera_limite,         // Zera contador de rodadas
    output reg conta_limite,        // Incrementa contador de rodadas
    output reg zeraR,
    output reg registrarR,
    output reg registra_modo,
    output reg zera_modo,
    output reg acertou,             // ganhou
    output reg errou,               // perdeu
    output reg pronto,
    output reg [3:0] db_estado,
    output reg db_timeout,
    output reg zera_s_timeout,
    output reg enable_timeout,
    output reg conf_leds,
    output reg registra_jogada,
    output reg zera_s_led,
    output reg enable_led
);

    reg [3:0] Eatual, Eprox;

    // Definição dos estados
    parameter inicial         = 4'b0000; // inicial
    parameter preparacao      = 4'b0001; // inicializa elementos
    parameter carrega_led     = 4'b0010; // carrega a jogada no led
    parameter mostra_led      = 4'b0011; // mostra a jogada no led
    parameter zera_led        = 4'b0100; // após o timer, apaga o led
    parameter mostra_apagado  = 4'b0101; // mostra o led apagado por um tempo
    parameter proximo_led     = 4'b0110; // prepara a proxima jogada no led
    parameter espera          = 4'b0111;
    parameter registra        = 4'b1000;
    parameter comparacao      = 4'b1001;
    parameter proximo         = 4'b1010; // próximo endereco dentro da sequencia
    parameter final_acerto    = 4'b1011;
    parameter final_erro      = 4'b1100;
    parameter adiciona_jogada = 4'b1101; // apos acertar as jogadas, o jogador adiciona uma nova ao final da sequencia 
    parameter proxima_rodada  = 4'b1110; // incrementa limite
    parameter final_timeout   = 4'b1111;

    always @(posedge clock or posedge reset) begin
        if (reset) Eatual <= inicial;
        else Eatual <= Eprox;
    end

    always @* begin
        case (Eatual)
            inicial:        Eprox = iniciar ? preparacao : inicial;
            preparacao:     Eprox = carrega_led;
            carrega_led:    Eprox = mostra_led;
            mostra_led:     Eprox = timeout_led ? zera_led : mostra_led;
            zera_led:       Eprox = mostra_apagado;
            mostra_apagado: Eprox = ~timeout_led ? mostra_apagado : fim_sequencia ? espera : proximo_led;
            proximo_led:    Eprox = carrega_led;
            espera:         if (timeout) Eprox = final_timeout;
                            else Eprox = jogada ? registra : espera;
            registra:       Eprox = comparacao;
            comparacao:     begin
                                if (!igual) 
                                    Eprox = final_erro;
                                else begin
                                    // Se acertou, verifica se terminou a sequencia atual
                                    if (enderecoIgualLimite) begin
                                        // Se terminou sequencia, verifica se era a ULTIMA rodada
                                        if (fim_jogo) Eprox = final_acerto;
                                        else Eprox = adiciona_jogada;
                                    end else begin
                                        // Se nao terminou sequencia, vai para proximo item
                                        Eprox = proximo;
                                    end
                                end
                            end
            adiciona_jogada:Eprox = jogada ? proxima_rodada : adiciona_jogada;
            proximo:        Eprox = espera;
            proxima_rodada: Eprox = carrega_led;
            final_acerto:   Eprox = iniciar ? preparacao : final_acerto;
            final_erro:     Eprox = iniciar ? preparacao : final_erro;
            final_timeout:  Eprox = iniciar ? preparacao : final_timeout;
            default:        Eprox = inicial;
        endcase
    end

    // Sinais de controle do fluxo de dados
    always @* begin        
        // Inicio do jogo OU mudanca de rodada
        zera_endereco = (Eatual == preparacao || Eatual == proxima_rodada);

        // dentro da mesma rodada
        conta_endereco = (Eatual == proximo || Eatual == proximo_led || (Eatual == comparacao && igual && enderecoIgualLimite));
        
        // inicio total do jogo
        zera_limite = (Eatual == preparacao);

        // passar de rodada
        conta_limite = (Eatual == proxima_rodada);

        zeraR      = (Eatual == preparacao || Eatual == proxima_rodada); 
        registrarR = (Eatual == registra);

        // controle do registrador de modo
        zera_modo     = (Eatual == inicial);
        registra_modo = (Eatual == preparacao);

        // reseta o timer toda vez que voltamos a esperar uma nova jogada
        zera_s_timeout = (Eatual == preparacao || Eatual == proximo || Eatual == proxima_rodada || Eatual == inicial);
        enable_timeout = (Eatual == espera);
        
        // sinais de saídas
        acertou    = (Eatual == final_acerto);
        errou      = (Eatual == final_erro);
        pronto     = (Eatual == final_timeout || Eatual == final_acerto || Eatual == final_erro);
        
        // sinais leds
        registra_jogada = (Eatual == adiciona_jogada && jogada);
        zera_s_led = ((Eatual == carrega_led) || (Eatual == zera_led));
        enable_led = ((Eatual == mostra_led) || (Eatual == mostra_apagado));
        conf_leds = (Eatual == zera_led);

        db_estado  = Eatual;
        db_timeout = (Eatual == final_timeout);
    end
endmodule