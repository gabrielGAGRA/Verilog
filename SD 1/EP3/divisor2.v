module bcd_adder_1digit (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
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
    input [15:0] a,
    input [15:0] b,
    input cin,
    output [15:0] sum,
    output cout
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
    input [3:0] a,
    input [3:0] b,
    input bin,
    output [3:0] diff,
    output bout
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
    input [15:0] a, 
    input [15:0] b, 
    input bin, 
    output [15:0] diff, 
    output bout 
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
    input [15:0] a, 
    input [15:0] b, 
    output a_ge_b   
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
    input [15:0] dividend,
    input [15:0] divisor,
    input muxr,
    input muxq,
    input clk,
    input rst,
    input loadq,
    input loadr,
    output [15:0] quotient,
    output [15:0] remainder,
    output rged
);

    wire [15:0] incrementa;
    wire [15:0] resto_incrementado;
    reg [15:0] remainder_register;
    reg [15:0] quotient_register;
    reg [15:0] dividend_register;
    reg [15:0] divisor_register;

    bcd_subtractor_4digits u_bcd_subtractor (
        .a(remainder_register),
        .b(divisor_register),
        .bin(1'b0),
        .diff(resto_incrementado),
        .bout()
    );

    bcd_adder_4digits u_bcd_adder (
        .a(quotient_register),
        .b(16'h0001),
        .cin(1'b0),
        .sum(incrementa),
        .cout()
    );

    bcd_comparator_4digits u_bcd_comparator (
        .a(remainder_register),
        .b(divisor_register),
        .a_ge_b(rged)
    );

    assign quotient  = quotient_register;
    assign remainder = remainder_register;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dividend_register <= 16'd0;
            divisor_register  <= 16'd0;
        end else if (loadr && ~muxr) begin
            dividend_register <= dividend;
            divisor_register  <= divisor;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            remainder_register <= 16'd0;
        end else if (loadr) begin
            if (muxr) begin
                remainder_register <= resto_incrementado;
            end else begin
                remainder_register <= dividend_register;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            quotient_register <= 16'd0;
        end else if (loadq) begin
            if (muxq) begin
                quotient_register <= incrementa;
            end else begin
                quotient_register <= quotient_register;
            end
        end
    end

endmodule
module bcd_divider_control (
    input start,
    input rged,
    input clk,
    input rst,
    output reg muxr,
    output reg muxq,
    output reg loadq,
    output reg loadr,
    output reg end_division
);

    reg [2:0] current_state;
    reg [2:0] next_state;

    localparam STATE_IDLE        = 3'd0;
    localparam STATE_INIT        = 3'd1;
    localparam STATE_LOAD        = 3'd2;
    localparam STATE_COMPARE     = 3'd3;
    localparam STATE_SUBTRACT    = 3'd4;
    localparam STATE_INCREMENT   = 3'd5;
    localparam STATE_COMPLETE    = 3'd6;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= STATE_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        muxr         = 1'b0;
        muxq         = 1'b0;
        loadq        = 1'b0;
        loadr        = 1'b0;
        end_division = 1'b0;
        next_state   = current_state;

        case (current_state)
            STATE_IDLE: begin
                if (start) begin
                    loadr      = 1'b1;
                    next_state = STATE_INIT;
                end
            end

            STATE_INIT: begin
                loadr      = 1'b1;
                next_state = STATE_LOAD;
            end

            STATE_LOAD: begin
                next_state = STATE_COMPARE;
            end

            STATE_COMPARE: begin
                if (rged) begin
                    next_state = STATE_SUBTRACT;
                end else begin
                    next_state = STATE_COMPLETE;
                end
            end

            STATE_SUBTRACT: begin
                muxr       = 1'b1;
                loadr      = 1'b1;
                next_state = STATE_INCREMENT;
            end

            STATE_INCREMENT: begin
                muxq       = 1'b1;
                loadq      = 1'b1;
                next_state = STATE_COMPARE;
            end

            STATE_COMPLETE: begin
                end_division = 1'b1;
                next_state   = STATE_IDLE;
            end

            default: begin
                next_state = STATE_IDLE;
            end
        endcase
    end

endmodule
module bcd_divider (
    input clk,
    input rst,
    input start,
    input [15:0] dividend,
    input [15:0] divisor,
    output [15:0] quotient,
    output [15:0] remainder,
    output end_division
);

    wire muxr_signal;
    wire muxq_signal;
    wire loadq_signal;
    wire loadr_signal;
    wire rged_signal;

    bcd_divider_df u_bcd_divider_df (
        .dividend(dividend),
        .divisor(divisor),
        .muxr(muxr_signal),
        .muxq(muxq_signal),
        .clk(clk),
        .rst(rst),
        .loadq(loadq_signal),
        .loadr(loadr_signal),
        .quotient(quotient),
        .remainder(remainder),
        .rged(rged_signal)
    );

    bcd_divider_control u_bcd_divider_control (
        .start(start),
        .rged(rged_signal),
        .clk(clk),
        .rst(rst),
        .muxr(muxr_signal),
        .muxq(muxq_signal),
        .loadq(loadq_signal),
        .loadr(loadr_signal),
        .end_division(end_division)
    );

endmodule