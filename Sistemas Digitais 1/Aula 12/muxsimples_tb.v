module muxsimples_tb;
    reg a, b, s;
    wire y;

    muxsimples dut(a,b,s,y);
 
    initial begin
        $monitor("A = %x, B = %x, S = %x, X = %x", a,b,s,y);
        #1 a=1'b0;b=1'b0;s=1'b0;
        #1 a=1'b0;b=1'b0;s=1'b1;
        #1 a=1'b0;b=1'b1;s=1'b0;
        #1 a=1'b0;b=1'b1;s=1'b1;
        #1 a=1'b1;b=1'b0;s=1'b0;
        #1 a=1'b1;b=1'b0;s=1'b1;
        #1 a=1'b1;b=1'b1;s=1'b0;
        #1 a=1'b1;b=1'b1;s=1'b1;
        $finish;
    end
endmodule