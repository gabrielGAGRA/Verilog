module codprisimples_tb;
    reg [3:0]i;
    reg en;
    wire [1:0]y;

    codprisimples dut(i, en, y);
 
    initial begin
        $monitor("I = %b, en = %x, Y = %x", i,en,y);
        #1 i=4'b0000;en=1'b1; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0001;en=1'b1; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0010;en=1'b1; #1 if (y!=2'b01) begin $display("Erro!"); $finish; end;
        #1 i=4'b0011;en=1'b1; #1 if (y!=2'b01) begin $display("Erro!"); $finish; end;
        #1 i=4'b0100;en=1'b1; #1 if (y!=2'b10) begin $display("Erro!"); $finish; end;
        #1 i=4'b0101;en=1'b1; #1 if (y!=2'b10) begin $display("Erro!"); $finish; end;
        #1 i=4'b0110;en=1'b1; #1 if (y!=2'b10) begin $display("Erro!"); $finish; end;
        #1 i=4'b0111;en=1'b1; #1 if (y!=2'b10) begin $display("Erro!"); $finish; end;
        #1 i=4'b1000;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;
        #1 i=4'b1001;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;
        #1 i=4'b1010;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;
        #1 i=4'b1111;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;
        #1 i=4'b1101;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;
        #1 i=4'b1110;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;
        #1 i=4'b1111;en=1'b1; #1 if (y!=2'b11) begin $display("Erro!"); $finish; end;

        #1 i=4'b0000;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0001;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0010;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0011;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0100;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0101;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0110;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b0111;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1000;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1001;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1010;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1111;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1101;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1110;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        #1 i=4'b1111;en=1'b0; #1 if (y!=2'b00) begin $display("Erro!"); $finish; end;
        $finish;
    end
endmodule
