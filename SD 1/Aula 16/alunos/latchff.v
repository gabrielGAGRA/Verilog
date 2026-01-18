module d_lt_gates(q, d, en);
    output q;
    input  d, en;

    wire qt, qnt;
    
    assign qt  = !( qnt || ( (!d) && en ));
    assign qnt = !( qt  || ( ( d) && en ));
    assign q = qt;

endmodule

module d_lt_always(q, d, en);
    output reg q;
    input  d, en;

    always @(en, d) begin
        if (~en) q <= d;
    end
endmodule

module d_ff (q, d, clk);
    input  d, clk;
    output reg q;
    output qn;

    always @(posedge clk) begin
        q <= d;
    end
    assign qn = ~q;

endmodule

module d_ff_rp (q, d, clk, rst, prs);
    input  d, clk, rst, prs;
    output reg q;
    output qn;

    always @(posedge clk, posedge rst, posedge prs) begin
        if (rst)
            q <= 1'b0;
        else if (prs)
            q <= 1'b1;
        else
            q <= d;
    end
    assign qn = ~q;

endmodule

module jk_ff (q, j, k, clk);
    input  j, k, clk;
    output reg q;
    output qn;

    always @(posedge clk) begin
        if (j && k)
            q <= ~q;
        else if (j)
            q <= 1'b1;
        else if (k)
            q <= 1'b0;
    end
    assign qn = ~q;

endmodule

module t_ff (q, t, clk, rst, prs);
    input  t, clk, rst, prs;
    output reg q;
    output qn;

    always @(posedge clk, posedge rst, posedge prs) begin
        if (rst)
            q <= 1'b0;
        else if (prs)
            q <= 1'b1;
        else if (t)
            q <= ~q;
    end
    assign qn = ~q;

endmodule

`timescale 1ns/1ps
module d_ff_temp (q, qn, d, clk);
    input  d, clk;
    output q, qn;

    wire dts;
    reg dth;
    assign #2 dts = d;
    always @(posedge clk) begin        
        if (dts != d) begin
            dth <= dts;
        end else begin
            #4 dth <= d;
        end                
    end

    assign #10 q = (dth && d);
    assign #2 qn = ~q;
endmodule
