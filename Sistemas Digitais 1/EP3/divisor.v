module bcd_adder_1digit (
    input [3:0] a, // Adendo A de 1 dígito BCD
    input [3:0] b, // Adendo B de 1 dígito BCD
    input cin, // Carry-in BCD
    output [3:0] sum, // Soma de 1 dígito BCD
    output cout // Carry-out BCD
);

    wire [4:0] soma_inicial;
    wire [3:0] soma_corrigida;
    wire carry_out;

    assign soma_inicial = a + b + cin;

    assign soma_corrigida = (soma_inicial > 9) ? (soma_inicial + 6) : soma_inicial;
    assign carry_out = (soma_inicial > 9) ? 1 : 0;

    assign sum = soma_corrigida[3:0];
    assign cout = carry_out;

endmodule

module bcd_adder_4digits (
    input [15:0] a, // Adendo A de 4 dígitos BCD
    input [15:0] b, // Adendo B de 4 dígitos BCD
    input cin, // Carry-in BCD
    output [15:0] sum, // Soma de 4 dígitos BCD
    output cout // Carry-out BCD
);

    wire [3:0] digito_soma [3:0];
    wire digito_cout [3:0];
    wire [15:0] soma_corrigida;

    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin : BCD_ADDERS
            if (i == 0) begin
                bcd_adder_1digit adder (
                    .a(a[3:0]),
                    .b(b[3:0]),
                    .cin(cin),
                    .sum(soma_corrigida[3:0]),
                    .cout(digito_cout[0])
                );
            end else begin
                bcd_adder_1digit adder (
                    .a(a[i*4 +: 4]),
                    .b(b[i*4 +: 4]),
                    .cin(digito_cout[i-1]),
                    .sum(soma_corrigida[i*4 +: 4]),
                    .cout(digito_cout[i])
                );
            end
        end
    endgenerate

    assign sum = soma_corrigida;
    assign cout = digito_cout[3];

endmodule

module bcd_subtractor_1digit (
    input [3:0] a, // Minuend A de 1 dígito BCD
    input [3:0] b, // Subtraendo B de 1 dígito BCD
    input bin, // Borrow-in
    output [3:0] diff, // Diferença de 1 dígito BCD
    output bout // Borrow-out
);

    wire [4:0] raw_diff;
    wire [3:0] corrected_diff;
    wire borrow_out;

    assign raw_diff = {1'b0, a} - {1'b0, b} - bin;

    assign corrected_diff = (raw_diff[4] == 1) ? (raw_diff + 10) : raw_diff[3:0];
    assign borrow_out = (raw_diff[4] == 1) ? 1 : 0;

    assign diff = corrected_diff;
    assign bout = borrow_out;

endmodule

module bcd_subtractor_4digits (
    input [15:0] a, // Minuend A de 4-digitos BCD
    input [15:0] b, // Subtraendo B de 4-digitos BCD
    input bin, // Borrow-in
    output [15:0] diff, // Diferenca de 4-digit0s BCD
    output bout // Borrow-out
);
    wire [3:0] digit_diff [3:0];
    wire digit_bout [3:0];
    wire [15:0] corrected_diff;

    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin : BCD_SUBTRACTORS
            if (i == 0) begin
                bcd_subtractor_1digit subtractor (
                    .a(a[3:0]),
                    .b(b[3:0]),
                    .bin(bin),
                    .diff(corrected_diff[3:0]),
                    .bout(digit_bout[0])
                );
            end else begin
                bcd_subtractor_1digit subtractor (
                    .a(a[i*4 +: 4]),
                    .b(b[i*4 +: 4]),
                    .bin(digit_bout[i-1]),
                    .diff(corrected_diff[i*4 +: 4]),
                    .bout(digit_bout[i])
                );
            end
        end
    endgenerate

    assign diff = corrected_diff;
    assign bout = digit_bout[3];

endmodule

module bcd_comparator_4digits (
    input [15:0] a, // A: número BCD de 4 dígitos
    input [15:0] b, // B: número BCD de 4 dígitos
    output a_ge_b   // Saída: se A >= B então 1, senão 0
);

    wire [3:0] a3 = a[15:12];
    wire [3:0] a2 = a[11:8];
    wire [3:0] a1 = a[7:4];
    wire [3:0] a0 = a[3:0];

    wire [3:0] b3 = b[15:12];
    wire [3:0] b2 = b[11:8];
    wire [3:0] b1 = b[7:4];
    wire [3:0] b0 = b[3:0];

    assign a_ge_b = (a3 > b3) ? 1'b1 :
                    (a3 < b3) ? 1'b0 :
                    (a2 > b2) ? 1'b1 :
                    (a2 < b2) ? 1'b0 :
                    (a1 > b1) ? 1'b1 :
                    (a1 < b1) ? 1'b0 :
                    (a0 >= b0) ? 1'b1 : 1'b0;

endmodule

module bcd_divider_df (
    input [15:0] dividend, // Dividend
    input [15:0] divisor, // Divisor
    input muxr, // Mux select signal for dividend
    input muxq, // Mux select signal for quotient
    input clk, // Clock signal
    input rst, // Reset signal
    input loadq, // Load signal for quotient
    input loadr, // Load signal for remainder
    output [15:0] quotient, // Quotient
    output [15:0] remainder, // Remainder
    output rged // GE signal
);
    wire [15:0] soma;
    wire [15:0] subtracao;
    reg [15:0] resto_reg;
    reg [15:0] quociente_reg;
    reg [15:0] dividendo_reg;
    reg [15:0] divisor_reg;

    bcd_subtractor_4digits subtractor (
        .a(resto_reg),
        .b(divisor_reg),
        .bin(1'b0),
        .diff(subtracao),
        .bout()
    );

    bcd_adder_4digits adder (
        .a(quociente_reg),
        .b(16'h0001),
        .cin(1'b0),
        .sum(soma),
        .cout()
    );

    bcd_comparator_4digits comparator (
        .a(resto_reg),
        .b(divisor_reg),
        .a_ge_b(rged)
    );

    assign quotient  = quociente_reg;
    assign remainder = resto_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dividendo_reg <= 16'd0;
            divisor_reg  <= 16'd0;
        end else begin
            if (loadr && ~muxr) begin
                dividendo_reg <= dividend;
                divisor_reg  <= divisor;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            resto_reg <= 16'd0;
        end else begin
            if (loadr) begin
                if (muxr) begin
                    resto_reg <= subtracao;
                end else begin
                    resto_reg <= dividendo_reg;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            quociente_reg <= 16'd0;
        end else begin
            if (loadq) begin
                if (muxq) begin
                    quociente_reg <= soma;
                end
            end
        end
    end

endmodule

module bcd_divider_control (
    input start, // Start signal
    input rged, // GE signal
    input clk, // Clock signal
    input rst, // Reset signal
    output reg muxr, // Mux select signal for dividend
    output reg muxq, // Mux select signal for quotient
    output reg loadq, // Load signal for quotient
    output reg loadr, // Load signal for remainder
    output reg end_division // Finish signal
);

    reg [2:0] state;

    parameter IDLE      = 3'd0;
    parameter LOAD_DIVISOR  = 3'd1;
    parameter LOAD_REM  = 3'd2;
    parameter WAIT      = 3'd3;
    parameter CHECK     = 3'd4;
    parameter SUBTRAIR  = 3'd5;
    parameter INCREMENTAR = 3'd6;
    parameter FIM       = 3'd7;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            muxr <= 0;
            muxq <= 0;
            loadq <= 0;
            loadr <= 0;
            end_division <= 0;
        end else begin
            loadr <= 0;
            loadq <= 0;
            muxr <= 0;
            muxq <= 0;
            end_division <= 0;

            case (state)
                IDLE: begin
                    if (start) begin
                        state <= LOAD_DIVISOR;
                        loadr <= 1;
                    end
                end
                LOAD_DIVISOR: begin
                    state <= LOAD_REM;
                end
                LOAD_REM: begin
                    loadr <= 1;
                    state <= WAIT;
                end
                WAIT: begin
                    state <= CHECK;
                end
                CHECK: begin
                    if (rged) begin
                        state <= SUBTRAIR;
                    end else begin
                        state <= FIM;
                    end
                end
                SUBTRAIR: begin
                    muxr <= 1;
                    loadr <= 1;
                    state <= INCREMENTAR;
                end
                INCREMENTAR: begin
                    muxq <= 1;
                    loadq <= 1;
                    state <= WAIT;
                end
                FIM: begin
                    end_division <= 1;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

module bcd_divider (
    input clk, // Clock signal
    input rst, // Reset signal
    input start, // Start signal
    input [15:0] dividend, // Dividend
    input [15:0] divisor, // Divisor
    output [15:0] quotient, // Quotient
    output [15:0] remainder, // Remainder
    output end_division // Finish signal
);

    wire muxr;
    wire muxq;
    wire loadq;
    wire loadr;
    wire rged;

    bcd_divider_df df (
        .dividend(dividend),
        .divisor(divisor),
        .muxr(muxr),
        .muxq(muxq),
        .clk(clk),
        .rst(rst),
        .loadq(loadq),
        .loadr(loadr),
        .quotient(quotient),
        .remainder(remainder),
        .rged(rged)
    );

    bcd_divider_control uc (
        .start(start),
        .rged(rged),
        .clk(clk),
        .rst(rst),
        .muxr(muxr),
        .muxq(muxq),
        .loadq(loadq),
        .loadr(loadr),
        .end_division(end_division)
    );

endmodule