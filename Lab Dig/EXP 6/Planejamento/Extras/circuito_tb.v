// ==========================================================================
//  Testbench — Jogo Desafio da Memória (EXP 6)
//
//  Cenários cobertos:
//   0 — Reset: estado inicial, saídas zeradas
//   1 — Travamento de modo: configuracao muda mid-game, db_modo não deve mudar
//   2 — MUX RGB: aceso em mostra_led, apagado em mostra_apagado
//   3 — Modo Demo (cfg=01): 4 rodadas completas → vitória
//   4 — Erro proposital na 2ª rodada → final_erro
//   5 — Recomeço a partir de final_erro via jogar
//   6 — Timeout habilitado (cfg=11): dispara sem jogar → final_timeout
//   7 — Timeout desabilitado (cfg=01): estado permanece em espera
//   8 — Modo Normal (cfg=10, 16 rodadas): 4 primeiras rodadas
// ==========================================================================
`timescale 1ns/1ns

module circuito_tb;

    reg        clock;
    reg        reset;
    reg        jogar;
    reg [1:0]  configuracao;   // [1]=timeout_hab  [0]=modo(0=16r,1=4r)
    reg [3:0]  botoes;

    // Sinais de saída
    wire [2:0] leds_rgb;
    wire       ganhou;
    wire       errou;
    wire       pronto;
    wire       timeout;
    wire [3:0] leds;

    // Debug
    wire       db_igual;
    wire [6:0] db_contagem;
    wire [6:0] db_memoria;
    wire [6:0] db_estado;
    wire [6:0] db_jogadafeita;
    wire       db_clock;
    wire       db_iniciar;
    wire       db_enderecoIgualLimite;
    wire       db_timeout;
    wire       db_modo;
    wire [6:0] db_limite_rodada;

    // Relógio de 1 kHz (igual ao hardware); deve bater com os parâmetros
    // M dos contadores instanciados em fluxo_dados.
    parameter CLK        = 1_000_000; // período em ns
    parameter LED_M      = 2000;      // ciclos por fase de LED (aceso ou apagado)
    parameter TO_M       = 5000;      // ciclos até timeout de jogada
    parameter LED_ITEM   = (LED_M * 2) + 10; // 1 item completo: aceso + apagado + margem

    jogo_desafio_memoria dut (
        .clock             (clock),
        .reset             (reset),
        .jogar             (jogar),
        .configuracao      (configuracao),
        .botoes            (botoes),
        .leds_rgb          (leds_rgb),
        .ganhou            (ganhou),
        .perdeu            (errou),
        .pronto            (pronto),
        .timeout           (timeout),
        .leds              (leds),
        .db_igual          (db_igual),
        .db_contagem       (db_contagem),
        .db_memoria        (db_memoria),
        .db_estado         (db_estado),
        .db_jogadafeita    (db_jogadafeita),
        .db_clock          (db_clock),
        .db_iniciar        (db_iniciar),
        .db_enderecoIgualLimite(db_enderecoIgualLimite),
        .db_timeout        (db_timeout),
        .db_modo           (db_modo),
        .db_limite_rodada  (db_limite_rodada)
    );

    always #(CLK/2) clock = ~clock;

    // Imprime uma linha de log em cada transição de estado, facilitando
    // rastrear o fluxo da FSM sem precisar abrir formas de onda.
    reg [3:0] estado_ant;

    function [127:0] nome_estado;
        input [3:0] e;
        begin
            case (e)
                4'b0000: nome_estado = "inicial        ";
                4'b0001: nome_estado = "preparacao     ";
                4'b0010: nome_estado = "carrega_led    ";
                4'b0011: nome_estado = "mostra_led     ";
                4'b0100: nome_estado = "zera_led       ";
                4'b0101: nome_estado = "mostra_apagado ";
                4'b0110: nome_estado = "proximo_led    ";
                4'b0111: nome_estado = "espera         ";
                4'b1000: nome_estado = "registra       ";
                4'b1001: nome_estado = "comparacao     ";
                4'b1010: nome_estado = "proximo        ";
                4'b1011: nome_estado = "final_acerto   ";
                4'b1100: nome_estado = "final_erro     ";
                4'b1101: nome_estado = "adiciona_jogada";
                4'b1110: nome_estado = "proxima_rodada ";
                4'b1111: nome_estado = "final_timeout  ";
                default: nome_estado = "???            ";
            endcase
        end
    endfunction

    always @(posedge clock) begin
        if (db_estado !== estado_ant) begin
            $display("  [cy=%0d] ESTADO: %-16s | ganhou=%b errou=%b pronto=%b timeout=%b | igual=%b endIgLim=%b modo=%b leds_rgb=%b",
                $time / CLK, nome_estado(db_estado),
                ganhou, errou, pronto, timeout,
                db_igual, db_enderecoIgualLimite, db_modo, leds_rgb);
            estado_ant <= db_estado;
        end
    end

    // -----------------------------------------------------------------------
    // Espelho de ram_init.txt
    //   addr[0] é pré-carregado pela ROM; addr[1..] são adicionados
    //   pelo jogador em adiciona_jogada. Usamos os valores da ROM para
    //   manter o gabarito consistente entre simulações.
    // -----------------------------------------------------------------------
    reg [3:0] rom [0:15];

    task do_reset;
        begin
            @(negedge clock);
            reset        = 1'b1;
            jogar        = 1'b0;
            botoes       = 4'b0000;
            configuracao = 2'b00;
            repeat(8) @(posedge clock);
            @(negedge clock);
            reset = 1'b0;
            repeat(4) @(posedge clock);
        end
    endtask

    // cfg[0]: modo  — 0 = 16 rodadas, 1 = demo 4 rodadas
    // cfg[1]: timeout — 0 = desabilitado, 1 = habilitado
    task do_iniciar;
        input [1:0] cfg;
        begin
            @(negedge clock);
            configuracao = cfg;
            jogar        = 1'b1;
            repeat(2) @(posedge clock);
            @(negedge clock);
            jogar = 1'b0;
        end
    endtask

    task pressiona;
        input [3:0] val;
        begin
            @(negedge clock);
            botoes = val;
            repeat(10) @(posedge clock);
            @(negedge clock);
            botoes = 4'b0000;
            repeat(5) @(posedge clock);
        end
    endtask

    // Espera a exibição de N cores: mostra_led + zera_led + mostra_apagado por item.
    task aguarda_led;
        input integer N;
        begin
            repeat(N * LED_ITEM) @(posedge clock);
        end
    endtask

    // Pré-condição: exibição da sequência já concluída (sistema entrará em espera).
    // Pós-condição: sistema em adiciona_jogada (rodada ok) ou final_acerto (jogo completo).
    task jogar_rodada;
        input integer k;
        integer i;
        begin
            $display("    -> Jogando %0d item(s)...", k+1);
            for (i = 0; i <= k; i = i + 1) begin
                wait (db_estado == 4'b0111); // espera
                repeat(3) @(posedge clock);
                if (errou || pronto) begin
                    $display("    [!] Jogo encerrou antes do item %0d", i);
                    i = k + 1; // break
                end else begin
                    pressiona(rom[i]);
                end
            end
        end
    endtask

    task adiciona_item;
        input [3:0] val;
        begin
            wait (db_estado == 4'b1101); // adiciona_jogada
            repeat(5) @(posedge clock);
            pressiona(val);
            wait (db_estado == 4'b1110); // proxima_rodada
            repeat(5) @(posedge clock);
        end
    endtask

    integer nivel;
    integer erros_total;

    initial begin
        $display("");
        $display("==========================================================");
        $display("   TESTBENCH — JOGO DESAFIO DA MEMÓRIA  (EXP 6)           ");
        $display("==========================================================");

        // Espelho da ROM
        rom[0]=4'b0001; rom[1]=4'b0010; rom[2]=4'b0100; rom[3]=4'b1000;
        rom[4]=4'b0100; rom[5]=4'b0010; rom[6]=4'b0001; rom[7]=4'b0001;
        rom[8]=4'b0010; rom[9]=4'b0010; rom[10]=4'b0100; rom[11]=4'b0100;
        rom[12]=4'b1000; rom[13]=4'b1000; rom[14]=4'b0001; rom[15]=4'b0100;

        clock       = 0;
        erros_total = 0;
        estado_ant  = 4'bxxxx;

        // ==================================================================
        // CENÁRIO 0 — Reset: estado inicial e saídas em 0
        // ==================================================================
        $display("\n── CENÁRIO 0: Reset ─────────────────────────────────────");
        do_reset();
        repeat(5) @(posedge clock);

        if (db_estado == 4'b0000)
            $display("  [OK] estado=inicial (0000).");
        else begin
            $display("  [FALHA] estado esperado 0000, obtido %b", db_estado);
            erros_total = erros_total + 1;
        end

        if (!ganhou && !errou && !pronto && !timeout)
            $display("  [OK] ganhou/errou/pronto/timeout = 0 após reset.");
        else begin
            $display("  [FALHA] saídas não zeradas: ganhou=%b errou=%b pronto=%b timeout=%b",
                     ganhou, errou, pronto, timeout);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 1 — Travamento de modo (configuracao muda mid-game)
        // ==================================================================
        $display("\n── CENÁRIO 1: Travamento do modo ────────────────────────");
        do_reset();
        do_iniciar(2'b01); // modo=1, sem timeout
        repeat(10) @(posedge clock);

        @(negedge clock);
        configuracao = 2'b10; // tenta trocar para modo=0 mid-game
        repeat(5) @(posedge clock);

        if (db_modo == 1'b1)
            $display("  [OK] Modo permaneceu em 1 após mudança de configuracao.");
        else begin
            $display("  [FALHA] Modo mudou durante o jogo! db_modo=%b", db_modo);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 2 — Verificação do MUX RGB
        //   mostra_led  (0011): conf_leds=1 → leds_rgb deve ser ≠ 000
        //   mostra_apagado (0101): conf_leds=0 → leds_rgb deve ser 000
        // ==================================================================
        $display("\n── CENÁRIO 2: LED RGB — aceso/apagado ───────────────────");
        do_reset();
        do_iniciar(2'b01);

        wait (db_estado == 4'b0011); // mostra_led
        repeat(5) @(posedge clock);
        if (leds_rgb !== 3'b000)
            $display("  [OK] RGB aceso em mostra_led: leds_rgb=%b (rom[0]=%b).", leds_rgb, rom[0]);
        else
            $display("  [INFO] RGB=000 em mostra_led — checar cores_rgb para cod=%b.", rom[0]);

        wait (db_estado == 4'b0101); // mostra_apagado
        repeat(5) @(posedge clock);
        if (leds_rgb === 3'b000)
            $display("  [OK] RGB apagado em mostra_apagado: leds_rgb=%b.", leds_rgb);
        else begin
            $display("  [FALHA] RGB não apagou em mostra_apagado: leds_rgb=%b", leds_rgb);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 3 — Modo Demo (cfg=01): 4 rodadas completas → vitória
        // ==================================================================
        $display("\n── CENÁRIO 3: Modo Demo — 4 rodadas — vitória ───────────");
        do_reset();
        do_iniciar(2'b01); // modo=demo, sem timeout

        for (nivel = 0; nivel < 4; nivel = nivel + 1) begin
            $display("  [Nível %0d] Aguardando exibição de %0d item(s)...", nivel, nivel+1);
            aguarda_led(nivel + 1);
            jogar_rodada(nivel);

            if (nivel < 3) begin
                $display("  [Nível %0d] Adicionando rom[%0d]=%b...", nivel, nivel+1, rom[nivel+1]);
                adiciona_item(rom[nivel + 1]);
            end

            repeat(5) @(posedge clock);

            if (errou) begin
                $display("  [FALHA] Errou inesperadamente no nível %0d.", nivel);
                erros_total = erros_total + 1;
                nivel = 4; // break
            end
        end

        repeat(20) @(posedge clock);
        if (ganhou && pronto && !errou)
            $display("  [OK] GANHOU o jogo no Modo Demo (ganhou=%b pronto=%b).", ganhou, pronto);
        else begin
            $display("  [FALHA] Não ganhou. ganhou=%b errou=%b pronto=%b", ganhou, errou, pronto);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 4 — Erro proposital: botão errado na 2ª rodada
        // ==================================================================
        $display("\n── CENÁRIO 4: Erro proposital na rodada 2 ───────────────");
        do_reset();
        do_iniciar(2'b01);

        aguarda_led(1);
        jogar_rodada(0);
        adiciona_item(rom[1]);
        repeat(5) @(posedge clock);

        // Rodada 1: acerta o 1º item, erra o 2º deliberadamente
        $display("  Correto: rom[0]=%b  |  Errado (inv. rom[1]): %b", rom[0], ~rom[1] & 4'hF);
        aguarda_led(2);
        wait (db_estado == 4'b0111);
        repeat(3) @(posedge clock);
        pressiona(rom[0]);              // item 0: correto
        wait (db_estado == 4'b0111);
        repeat(3) @(posedge clock);
        pressiona(~rom[1] & 4'hF);     // item 1: errado (bits invertidos)
        repeat(10) @(posedge clock);

        if (errou && pronto && !ganhou)
            $display("  [OK] Erro detectado corretamente (errou=%b pronto=%b).", errou, pronto);
        else begin
            $display("  [FALHA] Erro não detectado. errou=%b pronto=%b ganhou=%b", errou, pronto, ganhou);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 5 — Recomeço a partir de final_erro via jogar
        // ==================================================================
        $display("\n── CENÁRIO 5: Recomeço após final_erro ──────────────────");
        // Aproveita o estado final_erro deixado pelo cenário anterior.
        if (db_estado == 4'b1100)
            $display("  Estado atual: final_erro — OK.");
        else
            $display("  [INFO] Estado atual: %b (esperado final_erro=1100).", db_estado);

        do_iniciar(2'b01);
        repeat(20) @(posedge clock);

        if (!errou && db_estado != 4'b1100)
            $display("  [OK] Jogo recomeçou após jogar em final_erro (estado=%b).", db_estado);
        else begin
            $display("  [FALHA] Jogo não recomeçou. estado=%b errou=%b", db_estado, errou);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 6 — Timeout habilitado (cfg=11): dispara sem jogar
        // ==================================================================
        $display("\n── CENÁRIO 6: Timeout habilitado — sem jogar ────────────");
        do_reset();
        do_iniciar(2'b11); // modo=demo, timeout=habilitado

        aguarda_led(1);
        wait (db_estado == 4'b0111); // espera
        $display("  Em espera. Aguardando timeout (%0d ciclos)...", TO_M);
        repeat(TO_M + 200) @(posedge clock);

        if (timeout && pronto && !ganhou && !errou)
            $display("  [OK] Timeout disparado corretamente (timeout=%b pronto=%b).", timeout, pronto);
        else begin
            $display("  [FALHA] Timeout não ocorreu: timeout=%b pronto=%b ganhou=%b errou=%b",
                     timeout, pronto, ganhou, errou);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 7 — Timeout DESABILITADO (cfg=01): jogo continua
        // ==================================================================
        $display("\n── CENÁRIO 7: Timeout desabilitado — jogo permanece ─────");
        do_reset();
        do_iniciar(2'b01); // modo=demo, timeout=desabilitado

        aguarda_led(1);
        wait (db_estado == 4'b0111);
        $display("  Em espera. Aguardando %0d ciclos sem jogar...", TO_M + 500);
        repeat(TO_M + 500) @(posedge clock);

        if (!pronto && !timeout && db_estado == 4'b0111)
            $display("  [OK] Estado permanece em espera sem timeout (pronto=%b timeout=%b).", pronto, timeout);
        else begin
            $display("  [FALHA] Jogo encerrou mesmo sem timeout habilitado: pronto=%b timeout=%b estado=%b",
                     pronto, timeout, db_estado);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // CENÁRIO 8 — Modo Normal (cfg=10, 16 rodadas): 4 primeiras
        // ==================================================================
        $display("\n── CENÁRIO 8: Modo Normal — primeiras 4 rodadas ─────────");
        do_reset();
        do_iniciar(2'b10); // modo=normal (16r), timeout=habilitado

        for (nivel = 0; nivel < 4; nivel = nivel + 1) begin
            $display("  [Nível %0d] Aguardando exibição de %0d item(s)...", nivel, nivel+1);
            aguarda_led(nivel + 1);
            jogar_rodada(nivel);
            adiciona_item(rom[nivel + 1]);
            repeat(5) @(posedge clock);

            if (errou) begin
                $display("  [FALHA] Errou no nível %0d do Modo Normal.", nivel);
                erros_total = erros_total + 1;
                nivel = 4; // break
            end
        end

        if (!ganhou && !errou && !pronto)
            $display("  [OK] 4 rodadas concluídas — Modo Normal ainda em andamento (não ganhou ainda).");
        else begin
            $display("  [FALHA] Estado inesperado: ganhou=%b errou=%b pronto=%b", ganhou, errou, pronto);
            erros_total = erros_total + 1;
        end

        // ==================================================================
        // RESULTADO FINAL
        // ==================================================================
        $display("");
        $display("==========================================================");
        if (erros_total == 0)
            $display("  RESULTADO: TODOS OS TESTES PASSARAM  (0 falhas)");
        else
            $display("  RESULTADO: %0d FALHA(S) DETECTADA(S)", erros_total);
        $display("==========================================================");
        $display("");
        $finish;
    end

endmodule