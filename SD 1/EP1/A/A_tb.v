module tb_ep01A;
    reg a, b, c;
    wire f;

    ep01A uut (
        .a(a),
        .b(b),
        .c(c),
        .f(f)
    );

    initial begin
        $monitor("a = %b, b = %b, c = %b, f = %b", a, b, c, f);

        a = 0; b = 0; c = 0; #10;
        a = 0; b = 0; c = 1; #10;
        a = 0; b = 1; c = 0; #10;
        a = 0; b = 1; c = 1; #10;
        a = 1; b = 0; c = 0; #10;
        a = 1; b = 0; c = 1; #10;
        a = 1; b = 1; c = 0; #10;
        a = 1; b = 1; c = 1; #10;

        $finish;
    end
endmodule