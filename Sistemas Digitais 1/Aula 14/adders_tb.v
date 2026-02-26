`timescale 1ns/1ps
// Testbench para os somadores (meio e completo)
// 1. Entenda o circuito gerado (no arquivo adders.v fornecido)
// 2. Execute este TB com:
//    iverilog -o adders_tb.o adders.v adders_tb.v
//    vvp adders_tb.o
// 3. Abra o arquivo gerado adders_tb.vcd com o GTKWave.
// 4. Estude atentamente a forma de onda. Observe o que acontece entre dois casos de teste e discuta com seu grupo.

module adders_tb;

    reg a,b,ci;
    wire ha_s, ha_co, fa_s, fa_co;

    ha dut_ha(a,b,ha_s,ha_co);
    fa dut_fa(a,b,ci,fa_s,fa_co);

    initial begin
        $dumpfile ("adders_tb.vcd");
        $dumpvars(0, adders_tb);   

        #20 a=1'b0; b=1'b0; ci=1'b0; 
        #20 a=1'b0; b=1'b0; ci=1'b1; 
        #20 a=1'b0; b=1'b1; ci=1'b0; 
        #20 a=1'b0; b=1'b1; ci=1'b1; 
        #20 a=1'b1; b=1'b0; ci=1'b0; 
        #20 a=1'b1; b=1'b0; ci=1'b1; 
        #20 a=1'b1; b=1'b1; ci=1'b0; 
        #20 a=1'b1; b=1'b1; ci=1'b1; 
        #20;
        $finish;
    end
    
endmodule