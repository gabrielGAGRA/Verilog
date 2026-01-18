`timescale 1ns/1ps
// Somadores para usar no exercício.
// NÃO envie este arquivo para o juiz, ele já tem estes módulos.
module ha (
    input a,
    input b,
    output s,
    output co
);
    assign #3 s = a ^ b;
    assign #3 co = a & b;
    // Atraso total do caminho crítico: 3ps
endmodule

module fa (
    input a,
    input b,
    input ci,
    output s,
    output co
);
    wire axorb, and1, and2;
    assign #3 axorb = a ^ b;
    assign #3 s = axorb ^ ci; // s = axorb + ^ = 3 + 3 = 6ps
    assign #3 and1 = axorb & ci; // and1 = axorb + & = 3 + 3 = 6ps
    assign #3 and2 = a & b;
    assign #3 co = and1 | and2; // and1 + | = 6 + 3 = 9ps
    // Atraso total do caminho crítico: 9ps
    // Atraso em relação ao ci:
    // - para s: tci + 3
    // - para co: tci + 6 
endmodule




