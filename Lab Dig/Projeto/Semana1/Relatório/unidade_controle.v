// ---------------------------------------------------------------------------
// Módulo: unidade_controle
// ---------------------------------------------------------------------------
// FSM (Máquina de Estados Finita) do jogo.
//
// Controla o fluxo do jogo em três fases principais:
//   1. EXIBIÇÃO  – apresenta a sequência de cores nos LEDs RGB, uma a uma,
//                   com intervalo apagado entre cada cor.
//   2. RESPOSTA  – aguarda as jogadas do jogador, registra cada botão
//                   pressionado e compara com a sequência armazenada.
//   3. EXPANSÃO  – após acerto completo, solicita ao jogador um novo
//                   elemento para expandir a sequência (modo cumulativo).
//
// ---------------------------------------------------------------------------
module unidade_controle (
    // -- Sinais globais -------------------------------------------------------
    input      clock,
    input      reset,

    // -- Entradas de controle do jogo -----------------------------------------
    input      iniciar,             // pulso do botão "jogar"
    input      fim_jogo,
    input      enderecoIgualLimite,
    input      jogada,
    input      igual,
    input      timeout,
    input      timeout_habilitado,
    input      timeout_led,
    input      fim_sequencia,

    // -- Saídas de comando para o fluxo de dados ------------------------------
    output reg zera_endereco,
    output reg conta_endereco,
    output reg zera_limite,
    output reg conta_limite,
    output reg zeraR,
    output reg registrarR,
    output reg registra_modo,
    output reg zera_modo,
    output reg zera_s_timeout,
    output reg enable_timeout,
    output reg conf_leds,
    output reg registra_jogada,
    output reg zera_s_led,
    output reg enable_led,

    // -- Sinais de status / resultado -----------------------------------------
    output reg acertou,
    output reg errou,
    output reg pronto,

    // -- Depuração ------------------------------------------------------------
    output reg [4:0] db_estado,
    output reg db_timeout
);

    reg [4:0] Eatual, Eprox;

    parameter inicial         = 5'b00000;
    parameter inicia_musica   = 5'b00001; // registra configuração e zera contadores
    parameter espera_tecla    = 5'b00010;
    parameter registra_tecla  = 5'b00011;
    parameter compara_notas   = 5'b00100;
    parameter final           = 5'b00101;
    parameter proxima_nota    = 5'b00110;
    parameter espera          = 5'b00111; // com timeout opcional
	parameter erro_verilog    = 5'b01111;

    // =========================================================================
    // Registrador de estado (com reset assíncrono)
    // =========================================================================
    always @(posedge clock or posedge reset) begin
        if (reset) Eatual <= inicial;
        else       Eatual <= Eprox;
    end

    // =========================================================================
    // Lógica de próximo estado
    // =========================================================================
    always @* begin
        case (Eatual)
            inicial:        Eprox = inicia_musica;
            inicia_musica:  Eprox = espera_tecla;
            espera_tecla:   Eprox = jogada ? registra_tecla : espera_tecla;
            registra_tecla: Eprox = compara_notas;
            compara_notas:  begin
                                if (igual)    
                                    if (enderecoIgualLimite)
                                        Eprox = fim_jogo ? final : proxima_nota;
                                    else
                                        Eprox = espera_tecla;
                            end
            proxima_nota:   Eprox = espera_tecla;
            final:          Eprox = iniciar ? inicia_musica : final;
            default:        Eprox = erro_verilog;
        endcase
    end

    // =========================================================================
    // Lógica de saída
    // =========================================================================
    always @* begin
        zera_endereco  = (Eatual == inicial);

        conta_endereco = (Eatual == proxima_nota);

        zera_limite    = (Eatual == inicia_musica);
        conta_limite   = (Eatual == proxima_nota);

        zeraR          = (Eatual == inicial);
        registrarR     = (Eatual == registra_tecla);

        zera_modo      = (Eatual == inicial);
        registra_modo  = (Eatual == preparacao);

        // Zerado em todos os predecessores de espera para evitar
        // timeout residual acumulado de rodadas anteriores.
        zera_s_timeout = 1'b0;
        
        // TODO: Timeout também está valendo para escolher a nova cor. Não sei se era o intencionado. Verificar.
        enable_timeout = 1'b0;
			
        acertou = 1'b0;
        errou   = 1'b0;
        pronto  = (Eatual == final);

        // Condicionada ao pulso de jogada para evitar escrita
        // na borda de entrada do estado.
        registra_jogada = 1'b0;

        zera_s_led = 1'b0;
        enable_led = 1'b0;
        conf_leds  = 1'b0;

        db_estado  = Eatual;
        db_timeout = 1'b0;
    end
endmodule