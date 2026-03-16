// ---------------------------------------------------------------------------
// Modulo: audio_generator
// Descricao: Gera frequencias musicais com controle de volume via PWM.
// ---------------------------------------------------------------------------
module audio_generator (
    input        clock,         // 50MHz
    input        reset,
    input [17:0] fim_contagem,  // Periodo da nota (calculado para 50MHz)
    input [3:0]  volume,        // 0-15 (Controle de Intensidade/Duty Cycle)
    input        habilitar,     // Toca apenas se nota estiver pressionada
    output       buzzer
);

    reg [17:0] contador;
    reg        s_buzzer;

    // O volume maximo (15) corresponde a ~50% de duty cycle (onda quadrada).
    // Volumes menores geram pulsos mais estreitos, reduzindo a potencia no buzzer.
    wire [17:0] threshold = (fim_contagem >> 5) * volume; 

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            contador <= 18'd0;
            s_buzzer <= 1'b0;
        end else if (habilitar) begin
            if (contador >= fim_contagem) begin
                contador <= 18'd0;
            end else begin
                contador <= contador + 1'b1;
            end
            
            // Define o sinal de saida (PWM)
            s_buzzer <= (contador < threshold);
        end else begin
            contador <= 18'd0;
            s_buzzer <= 1'b0;
        end
    end

    assign buzzer = s_buzzer;

endmodule