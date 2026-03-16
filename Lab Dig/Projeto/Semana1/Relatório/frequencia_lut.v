// ---------------------------------------------------------------------------
// Modulo: frequency_lut
// Descricao: Converte nota e oitava no limite do contador (N_ticks).
// Base: Clock de 50MHz.
// ---------------------------------------------------------------------------
module frequency_lut (
    input  [2:0] nota_id,    // 1=Do, 2=Re, ..., 7=Si
    input  [1:0] oitava,     // 0=Oitava5, 1=Oitava6, 2=Oitava7
    output reg [17:0] n_ticks
);

    reg [17:0] base_freq;

    // Valores calculados para a Oitava 5 (Base > 500Hz)
    // Formula: N = 50.000.000 / Freq_Nota
    always @(*) begin
        case (nota_id)
            3'd1: base_freq = 18'd95557;  // Do5 (523.25 Hz)
            3'd2: base_freq = 18'd85131;  // Re5 (587.33 Hz)
            3'd3: base_freq = 18'd75844;  // Mi5 (659.25 Hz)
            3'd4: base_freq = 18'd71586;  // Fa5 (698.46 Hz)
            3'd5: base_freq = 18'd63776;  // Sol5(783.99 Hz)
            3'd6: base_freq = 18'd56818;  // La5 (880.00 Hz)
            3'd7: base_freq = 18'd50619;  // Si5 (987.77 Hz)
            default: base_freq = 18'd0;
        endcase

        // Transposicao de Oitava via Shift Right (Dividir periodo por 2^n)
        // Isso dobra a frequencia a cada incremento de oitava.
        n_ticks = base_freq >> oitava;
    end
endmodule