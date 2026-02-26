module primo_tb;
    reg [3:0] N;
    wire F;

    primo uut (
        .N(N), 
        .F(F)
    );

    initial begin
        N = 4'b0000;
        #10;
        $display("N=%b, F=%b", N, F);

        N = 4'b0001;
        #10;
        $display("N=%b, F=%b", N, F);

        N = 4'b0010;
        #10;
        $display("N=%b, F=%b", N, F);

        N = 4'b0011;
        #10;
        $display("N=%b, F=%b", N, F);

        N = 4'b0100;
        #10;
        $display("N=%b, F=%b", N, F);

        N = 4'b1000;
        #10;
        $display("N=%b, F=%b", N, F);

        N = 4'b1111;
        #10;
        $display("N=%b, F=%b", N, F);

        $finish;
    end
endmodule