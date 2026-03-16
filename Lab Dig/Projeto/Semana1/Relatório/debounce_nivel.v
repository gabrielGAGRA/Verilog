module debounce_nivel #(parameter TEMPO_FILTRO = 500000) ( // 10ms em 50MHz
    input clock,
    input reset,
    input [6:0] botoes_in,
    output reg [6:0] botoes_out
);
    reg [19:0] contadores [6:0];
    reg [6:0] estado_sincronizado;
    integer i;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            botoes_out <= 7'd0;
            estado_sincronizado <= 7'd0;
            for (i=0; i<7; i=i+1) contadores[i] <= 20'd0;
        end else begin
            estado_sincronizado <= botoes_in; // Dois estágios de sync são recomendados para evitar metaestabilidade

            for (i=0; i<7; i=i+1) begin
                if (estado_sincronizado[i] == botoes_out[i]) begin
                    contadores[i] <= 20'd0; // Já está no nível certo
                end else begin
                    contadores[i] <= contadores[i] + 1'b1;
                    if (contadores[i] >= TEMPO_FILTRO) begin
                        botoes_out[i] <= estado_sincronizado[i];
                        contadores[i] <= 20'd0;
                    end
                end
            end
        end
    end
endmodule