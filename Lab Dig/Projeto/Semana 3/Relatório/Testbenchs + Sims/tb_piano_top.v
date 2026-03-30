`timescale 1ns/1ns

module tb_piano_top;

    reg CLOCK_50;
    reg reset_n;
    reg [6:0] gpio_keys;
    reg btn_modo;
    reg btn_musica;
    reg btn_intensidade;
    reg btn_oitava_up;
    reg btn_oitava_down;
    reg btn_sustenido;

    wire buzzer;
    wire [6:0] led_vermelho;
    wire led_sustenido;
    wire led_oitava_up;
    wire led_oitava_down;
    wire [6:0] hex5_modo;
    wire [6:0] hex4_oitava;
    wire [6:0] hex3_musica_dezena;
    wire [6:0] hex2_musica_unidade;
    wire [6:0] hex1_nota;
    wire [6:0] hex0_sustenido;

    // Instancia o top-level sobrescrevendo os parametros de tempo de debounce para agilizar a simulacao
    piano_top #(
        .DEBOUNCE_TECLA(2),
        .DEBOUNCE_CONTROLE(2)
    ) dut (
        .CLOCK_50(CLOCK_50),
        .reset_n(reset_n),
        .gpio_keys(gpio_keys),
        .btn_modo(btn_modo),
        .btn_musica(btn_musica),
        .btn_intensidade(btn_intensidade),
        .btn_oitava_up(btn_oitava_up),
        .btn_oitava_down(btn_oitava_down),
        .btn_sustenido(btn_sustenido),
        .buzzer(buzzer),
        .led_vermelho(led_vermelho),
        .led_sustenido(led_sustenido),
        .led_oitava_up(led_oitava_up),
        .led_oitava_down(led_oitava_down),
        .hex5_modo(hex5_modo),
        .hex4_oitava(hex4_oitava),
        .hex3_musica_dezena(hex3_musica_dezena),
        .hex2_musica_unidade(hex2_musica_unidade),
        .hex1_nota(hex1_nota),
        .hex0_sustenido(hex0_sustenido)
    );

    // Clock gen 50MHz (periodo 20ns)
    always #10 CLOCK_50 = ~CLOCK_50;

    // Reaproveitado do tb da semana 1 para medição de frequência gerada
    time tempo_borda_anterior = 0;
    real periodo_em_ns;
    real frequencia_atual_hz;

    // Sempre que o buzzer subir, calculamos a freq baseada no tempo decorrido
    always @(posedge buzzer) begin
        if (tempo_borda_anterior != 0) begin
            periodo_em_ns = $time - tempo_borda_anterior;
            frequencia_atual_hz = 1_000_000_000.0 / periodo_em_ns;
        end
        tempo_borda_anterior = $time;
    end

    // Task para conferência
    task check_freq(input real freq_esperada, input [255:0] nome_nota);
        begin
            #4000000; // Aguarda 4ms para estabilizar a medição (frequências menores precisam de mais tempo)
            // Tolerância de 1%
            if (frequencia_atual_hz > freq_esperada * 0.99 && frequencia_atual_hz < freq_esperada * 1.01) begin
                $display("[%0t ns] [PASS] %s detectada: %0.2f Hz", $time, nome_nota, frequencia_atual_hz);
            end else begin
                $display("[%0t ns] [FAIL] %s INCORRETA! Esperado: %0.2f Hz | Lido: %0.2f Hz", 
                         $time, nome_nota, freq_esperada, frequencia_atual_hz);
            end
        end
    endtask

    initial begin
        $display("Iniciando Testbench de Integracao: piano_top...");
        $dumpfile("tb_piano_top.vcd");
        $dumpvars(0, tb_piano_top);

        // Inicializacao
        CLOCK_50 = 0;
        reset_n = 0; // Ativo baixo
        gpio_keys = 0;
        // Botões grandes agora são pull-up (1 = não pressionado, 0 = pressionado)
        btn_modo = 1;
        btn_musica = 1;
        btn_intensidade = 1;
        btn_oitava_up = 1;
        btn_oitava_down = 1;
        btn_sustenido = 1;

        // Libera do reset
        #50 reset_n = 1;
        #50;

        // Testa Modo Livre
        $display("Testando Modo Livre - Pressionando C (Do4)");
        gpio_keys = 7'b0000001; 
        #200; // Tempo pro debounce contabilizar
        check_freq(261.63, "Do4 (Modo Livre)");
        
        $display("Adicionando Sustenido...");
        btn_sustenido = 0; // Pressiona o botão (pull-up)
        #200;
        check_freq(277.18, "Do#4 (Modo Livre)"); // (1000000000 / (180386 * 20)) = 277.18
        
        btn_sustenido = 1; // Solta o botão
        gpio_keys = 0; 
        #200;

        $display("Aumentando Oitava...");
        btn_oitava_up = 0; #100 btn_oitava_up = 1; #200;
        
        $display("Pressionando C (Do5)");
        gpio_keys = 7'b0000001; 
        #200; 
        check_freq(523.25, "Do5 (Modo Livre)");

        $display("Testando alteracao de intensidade do LED (PWM)...");
        btn_intensidade = 0; #100; btn_intensidade = 1; // ~75%
        #200;

        $display("Mudando para Modo Aprendizado...");
        btn_modo = 0; #100 btn_modo = 1; #200; 

        // Tinha musica escolhida? Tenta tocar primeira nota de Acerto!
        // A musica 1 (do_re_mi) deve exigir certas oitavas (verificar no txt real)
        // Se zelda.txt esta na rom, o primeiro eh 100 0 100 => oitava 4, nao sustenido, fa (4)
        // Vamos apenas enviar os sinais em sequencia para simular mudancas
        $display("Teste Inicial finalizado. Finalizando...");
        $finish;
    end

endmodule
