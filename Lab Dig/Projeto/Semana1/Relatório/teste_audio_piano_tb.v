`timescale 1ns/1ns

module teste_audio_piano_tb;

    // Sinais de estímulo (entradas)
    reg        CLOCK_50;
    reg        reset_n;
    reg  [6:0] gpio_keys;

    // Sinais de observação (saídas)
    wire       buzzer;

    // Instanciação do módulo Top-Level
    teste_audio_piano dut (
        .CLOCK_50(CLOCK_50),
        .reset_n(reset_n),
        .gpio_keys(gpio_keys),
        .buzzer(buzzer)
    );

    // Gerador de Clock (50MHz -> Periodo = 20ns)
    always #10 CLOCK_50 = ~CLOCK_50;

    // Bloco de estímulos iniciais
    initial begin
        // Inicialização
        CLOCK_50  = 0;
        reset_n   = 0;  // Reset ativo baixo
        gpio_keys = 7'b0000000;

        $display("Iniciando simulacao...");

        // Segura o reset por 100ns
        #100;
        reset_n = 1;
        #100;

        // Cenario 1: Tocar a nota Do (Bit 0)
        $display("[%0t ns] Pressionando a nota: Do", $time);
        gpio_keys[0] = 1'b1;
        #5000000; // Espera 5ms para ver a oscilacao do Do

        // Cenario 2: Override segurando Do e apertando Mi (Bit 2)
        // O audio deve mudar para a frequencia do Mi instantaneamente
        $display("[%0t ns] Override apertando a nota: Mi (Do ainda pressionado)", $time);
        gpio_keys[2] = 1'b1;
        #5000000; // Espera mais 5ms

        // Cenario 3: Soltar o Mi. Como o Do ainda esta pressionado, deve voltar ao Do.
        $display("[%0t ns] Soltando a nota: Mi (Fallback para o Do)", $time);
        gpio_keys[2] = 1'b0;
        #5000000; // Espera 5ms para ver o retorno a nota Do

        // Cenario 4: Tocar um acorde cheio e ver se pega a maior nota
        $display("[%0t ns] Pressionando varias notas ao mesmo tempo", $time);
        gpio_keys = 7'b1010101; // Do, Mi, Sol, Si
        #5000000;

        // Cenario 5: Soltar tudo (Silencio)
        $display("[%0t ns] Soltando todas as teclas", $time);
        gpio_keys = 7'b0000000;
        #2000000; // Espera 2ms para confirmar que ficara mudo

        $display("[%0t ns] Fim da simulacao.", $time);
        $stop; // Para a simulação no ModelSim
    end

endmodule