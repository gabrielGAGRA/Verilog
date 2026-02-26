module latchff_tb;

    reg  d, j, k, en, clk, rst, prs;
    wire Dlatch1, Dlatch2, Dff1, Dff2, JKff, Tff;

    d_lt_gates  d_lt_1(Dlatch1, d, en);
    d_lt_always d_lt_2(Dlatch2, d, en);
    d_ff        d_ff_1(Dff1, d, clk);
    d_ff_rp     d_ff_2(Dff2, d, clk, rst, prs);
    jk_ff        jk_ff(JKff, j, k, clk);
    t_ff          t_ff(Tff, d, clk, rst, prs);
    d_ff_temp   d_ff_3(Dff3, , d, clk);

    initial begin
        $dumpfile ("latchff_tb.vcd");
        $dumpvars(0, latchff_tb);
        // Bloco de reset
        #2 rst = 1'b0; prs = 1'b0; 
        #2 rst = 1'b0; prs = 1'b1; 
        #2 rst = 1'b0; prs = 1'b0; 
        #2 rst = 1'b1; prs = 1'b0; 
        #2 rst = 1'b0; prs = 1'b0; 

        // Escreva seus testes a partir daqui        

        #200;

        $finish;
    end

    // Geração de clock contínuo
    initial begin
        clk = 1'b0;
	    forever #50 clk = ~clk;
    end
    
endmodule