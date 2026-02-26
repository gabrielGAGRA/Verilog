module solucao (m, int, s, y);
    input m;
    input [31:0] int;
    input [15:0] s;
    output reg [1:0] y;
    // m é a chave geral (sempre da prioridade para o int a, que nesse desafio
    //     corresponde ao int[1:0]).
    // int são os comandos dos interruptores, o vetor está "packed", ou seja, 
    //     int[1:0]=inta, int[3:2]=intb e assim por diante. No total, são 16 
    //     interruptores de 2 bits.
    // s são os sensores, s[0] corresponde ao sensor s a.
    // y é a saída, note que o int é de 2 bits, então a saída também é.

    // Escreva sua solução a partir aqui
    always @(*) 
    begin 
        y = (m == 0) ? int[1:0] :
              (s[15] == 1 ? int[31:30] :
               (s[14] == 1 ? int[29:28] :
               (s[13] == 1 ? int[27:26] :
               (s[12] == 1 ? int[25:24] :
               (s[11] == 1 ? int[23:22] :
               (s[10] == 1 ? int[21:20] :
               (s[9] == 1 ? int[19:18] :
               (s[8] == 1 ? int[17:16] :
               (s[7] == 1 ? int[15:14] :
               (s[6] == 1 ? int[13:12] :
               (s[5] == 1 ? int[11:10] :
               (s[4] == 1 ? int[9:8] :
               (s[3] == 1 ? int[7:6] :
               (s[2] == 1 ? int[5:4] :
               (s[1] == 1 ? int[3:2] :
               (s[0] == 1 ? int[1:0] :
               int[1:0]))))))))))))))));
    end
endmodule