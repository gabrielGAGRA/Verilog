module tb_ripple_carry_adder;

    reg [3:0] a;
    reg [3:0] b;
    reg cin;
    wire [3:0] sum;
    wire cout;

    somador2b_rc uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    integer soma;
    initial begin
        for (integer i = 0; i <= 4'b1111; i = i +1) begin
            for (integer j = 0; j <= 4'b1111; j = j +1) begin
                a = i; b = j;
                soma = i+j;
                cin = 1'b0;
                #10 if ({cout,sum} == soma) begin
                    $display("Teste  OK: a=%b, b=%b, cin=%b, sum=%b, cout=%b", a, b, cin, sum, cout);    
                end else begin
                    $display("Teste NOK: a=%b, b=%b, cin=%b, sum=%b, cout=%b", a, b, cin, sum, cout);
                    $display("Esperado:                         sum=%b, cout=%b", soma[3:0],soma[4]);
                end
                cin = 1'b1;
                soma = soma +1;
                #10 if ({cout,sum} == soma) begin
                    $display("Teste  OK: a=%b, b=%b, cin=%b, sum=%b, cout=%b", a, b, cin, sum, cout);    
                end else begin
                    $display("Teste NOK: a=%b, b=%b, cin=%b, sum=%b, cout=%b", a, b, cin, sum, cout);
                    $display("Esperado:                         sum=%b, cout=%b", soma[3:0],soma[4]);
                end
            end
        end

        $finish;
    end
endmodule
