// ---------------------------------------------------------------------------
// Modulo: decodificador_leds
// Descricao: Converte o ID da nota (1 a 7) para 7 LEDs difusos (one-hot).
// ---------------------------------------------------------------------------
module decodificador_leds (
    input      [2:0] nota_id,
    output reg [6:0] leds
);

    always @(*) begin
        case (nota_id)
            3'd1: leds = 7'b0000001; // Dó
            3'd2: leds = 7'b0000010; // Ré
            3'd3: leds = 7'b0000100; // Mi
            3'd4: leds = 7'b0001000; // Fá
            3'd5: leds = 7'b0010000; // Sol
            3'd6: leds = 7'b0100000; // Lá
            3'd7: leds = 7'b1000000; // Si
            default: leds = 7'b0000000;
        endcase
    end

endmodule