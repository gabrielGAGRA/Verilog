module mux2to1_tb;

    reg a;
    reg b;
    reg sel;
    wire y;

    mux2to1 uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        // Test case 1: sel=0, a=0, b=0
        a = 0; b = 0; sel = 0;
        #10;
        $display("sel=%b, a=%b, b=%b, y=%b", sel, a, b, y);

        // Test case 2: sel=0, a=1, b=0
        a = 1; b = 0; sel = 0;
        #10;
        $display("sel=%b, a=%b, b=%b, y=%b", sel, a, b, y);

        // Test case 3: sel=1, a=0, b=1
        a = 0; b = 1; sel = 1;
        #10;
        $display("sel=%b, a=%b, b=%b, y=%b", sel, a, b, y);

        // Test case 4: sel=1, a=1, b=1
        a = 1; b = 1; sel = 1;
        #10;
        $display("sel=%b, a=%b, b=%b, y=%b", sel, a, b, y);

        $finish;
    end
endmodule
