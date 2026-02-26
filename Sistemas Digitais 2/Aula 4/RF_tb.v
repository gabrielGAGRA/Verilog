// Gabriel Agra de Castro Motta
// 15452743
// Mateus  Silva de Araujo
// 15497076

`timescale 1ns / 1ps

module rf_tb;

    parameter W = 32;
    reg [4:0] Read1, Read2, WriteReg;
    reg [W-1:0] Writedados;
    reg RegWrite, clk;
    wire [W-1:0] dados1, dados2;

    registerfile #(W) uut (
        .Read1(Read1),
        .Read2(Read2),
        .WriteReg(WriteReg),
        .WriteData(Writedados),   
        .RegWrite(RegWrite),
        .clk(clk),
        .Data1(dados1),           
        .Data2(dados2)            
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        RegWrite = 0; WriteReg = 0; Writedados = 0;
        Read1 = 0; Read2 = 0;

        // escreve no registrador 1
        #10;
        RegWrite = 1; WriteReg = 5'd1; Writedados = 32'hA5A5A5A5;
        #10;
        RegWrite = 0;

        // le do registrador 1
        Read1 = 5'd1;
        #10;
        $display("Read1: addr=%d, dados=%h", Read1, dados1);

        // escreve no 2
        RegWrite = 1; WriteReg = 5'd2; Writedados = 32'h5A5A5A5A;
        #10;
        RegWrite = 0;

        // le do 2
        Read2 = 5'd2;
        #10;
        $display("Read2: addr=%d, dados=%h", Read2, dados2);

        // le um não escrito
        Read1 = 5'd3;
        #10;
        $display("Read1 (nao escrito): addr=%d, dados=%h", Read1, dados1);

        // escreve e le ao mesmo tempo
        RegWrite = 1; WriteReg = 5'd4; Writedados = 32'h12345678;
        Read1 = 5'd4;
        #10;
        $display("Leitura e escrita simultanea: addr=%d, dados=%h", Read1, dados1);

        // finaliza a simulação
        $finish;
    end
endmodule