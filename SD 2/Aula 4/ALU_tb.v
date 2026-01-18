// Gabriel Agra de Castro Motta
// 15452743
// Mateus  Silva de Araujo
// 15497076

`timescale 1ns / 1ps

module alu_tb;

    parameter W = 32;
    reg [W-1:0] A, B;
    reg [3:0] ALUctl;
    wire [W-1:0] ALUout;
    wire Zero;

    alu #(W) uut (
        .A(A),
        .B(B),
        .ALUctl(ALUctl),
        .ALUout(ALUout),
        .Zero(Zero)
    );

    initial begin
        //AND
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; ALUctl = 4'b0000;
        #10;
        $display("AND: A=%h, B=%h, ALUout=%h, Zero=%b", A, B, ALUout, Zero);
        
        //AND com resultado zero
        A = 32'hFF00FF00; B = 32'h00000000; ALUctl = 4'b0000;
        #10;
        $display("Flag zero no AND: A=%h, B=%h, ALUout=%h, Zero=%b", A, B, ALUout, Zero);

        //OR
        A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; ALUctl = 4'b0001;
        #10;
        $display("OR: A=%h, B=%h, ALUout=%h, Zero=%b", A, B, ALUout, Zero);
        
        //OR com resultado zero
        A = 32'h00000000; B = 32'h00000000; ALUctl = 4'b0001;
        #10;
        $display("Flag zero no OR: A=%h, B=%h, ALUout=%h, Zero=%b", A, B, ALUout, Zero);

        //SOMA
        A = 32'd15; B = 32'd10; ALUctl = 4'b0010;
        #10;
        $display("Soma: A=%d, B=%d, ALUout=%d, Zero=%b", A, B, ALUout, Zero);
        
        //SUBTRACAO
        A = 32'd20; B = 32'd5; ALUctl = 4'b0110;
        #10;
        $display("Subtracao: A=%d, B=%d, ALUout=%d, Zero=%b", A, B, ALUout, Zero);

        //SUBTRACAO com resultado zero
        A = 32'd10; B = 32'd10; ALUctl = 4'b0110;
        #10;
        $display("Flag zero na subtracao : A=%d, B=%d, ALUout=%d, Zero=%b", A, B, ALUout, Zero);

        //MENOR QUE
        A = 32'd5; B = 32'd10; ALUctl = 4'b0111;
        #10;
        $display("MENOR QUE: A=%d, B=%d, ALUout=%d, Zero=%b", A, B, ALUout, Zero);
        
        //NOR
        A = 32'hAAAA5555; B = 32'h5555AAAA; ALUctl = 4'b1100;
        #10;
        $display("NOR: A=%h, B=%h, ALUout=%h, Zero=%b", A, B, ALUout, Zero);
        
        //NOR com resultado zero
        A = 32'hFFFFFFFF; B = 32'h00000000; ALUctl = 4'b1100;
        #10;
        $display("Flag zero no NOR: A=%h, B=%h, ALUout=%h, Zero=%b", A, B, ALUout, Zero);

        $finish;
    end
endmodule