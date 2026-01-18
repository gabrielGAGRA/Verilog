// Gabriel Agra de Castro Motta
// 15452743
// Mateus  Silva de Araujo
// 15497076

// Gabriel Agra de Castro Motta
// 15452743
// Mateus  Silva de Araujo
// 15497076

module alu
#(parameter W = 32)
(
    input  [3:0]   ALUctl,
    input  [W-1:0] A, B,
    output [W-1:0] ALUout,
    output Zero
);

    assign ALUout = (ALUctl == 4'b0000) ? (A & B) : //AND
                    (ALUctl == 4'b0001) ? (A | B) : //OR
                    (ALUctl == 4'b0010) ? (A + B) : //SOMA
                    (ALUctl == 4'b0110) ? (A - B) : //SUBTRACAO
                    (ALUctl == 4'b0111) ? ((A < B) ? {{W-1{1'b0}}, 1'b1} : {W{1'b0}}) : //MENOR QUE
                    (ALUctl == 4'b1100) ? (~(A | B)) //NOR 
                    :  {W{1'bx}}; //enquanto nao precisamos de um default, nao tem como usar operador ternario sem uma condicao de caso nao seja

    //flag zero
    assign Zero = (ALUout == 0) ? 1'b1 : 1'b0;

endmodule