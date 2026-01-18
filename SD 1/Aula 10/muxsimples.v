module tb_muxsimples;
    reg a, b, s;
    wire y;

    muxsimples uut (
        .a(a),
        .b(b),
        .s(s),
        .y(y)
    );

    initial begin
        a = 0; b = 0; s = 0;
        #10;

        a = 0; b = 0; s = 1;
        #10;
        a = 0; b = 1; s = 0;
        #10;
        a = 0; b = 1; s = 1;
        #10;
        a = 1; b = 0; s = 0;
        #10;
        a = 1; b = 0; s = 1;
        #10;
        a = 1; b = 1; s = 0;
        #10;
        a = 1; b = 1; s = 1;
        #10;

        $finish;
    end

    initial begin
        $monitor("Time = %0d: a = %b, b = %b, s = %b, y = %b", $time, a, b, s, y);
    end
endmodule