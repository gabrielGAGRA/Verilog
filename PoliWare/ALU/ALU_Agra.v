module ALU(
    input  [63:0] operando1,
    input  [63:0] operando2,
    input  [3:0]  operador,
    output reg [63:0] resultado
);

    always @(*) begin
        case (operador)
            4'b0000: begin 
                resultado = operando1 + operando2; //Adiciona
            end

            4'b0001: begin 
                resultado = operando1 - operando2; //Subtrai
            end

            4'b0010: begin
                resultado = operando1 << operando2[5:0]; //Shift esquerda
            end

            4'b0011: begin
                resultado = (operando1 < operando2) ? 64'd1 : 64'd0; //Compara
            end

            4'b0100: begin
                resultado = operando1 ^ operando2; //XOR
            end

            4'b0101: begin
                resultado = operando1 >> operando2[5:0]; //Shift direita
            end

            4'b0110: begin
                resultado = operando1 >>> operando2[5:0]; //Shift direita aritmetico
            end

            4'b0111: begin
                resultado = operando1 | operando2; //OR
            end

            4'b1000: begin
                resultado = operando1 & operando2; //AND
            end
        endcase        
    end
endmodule