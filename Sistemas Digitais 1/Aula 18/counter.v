module t_ff (q, t, clk, rst, prs);
    input  t, clk, rst, prs;
    output reg q;

    always @(posedge clk or posedge rst or posedge prs) begin
        if (rst)
            q <= 1'b0;
        else if (prs)
            q <= 1'b1;
        else if (t)
            q <= ~q;
    end
endmodule

module counter (
    input clk,      // Clock input
    input reset,    // Asynchronous reset
    output [3:0] Q  // 4-bit output representing the count
);
    wire [3:0] q;
    wire [3:0] t;

    t_ff tff0 (.q(q[0]), .t(t[0]), .clk(clk), .rst(reset), .prs(1'b0));
    t_ff tff1 (.q(q[1]), .t(t[1]), .clk(clk), .rst(reset), .prs(1'b0));
    t_ff tff2 (.q(q[2]), .t(t[2]), .clk(clk), .rst(reset), .prs(1'b0));
    t_ff tff3 (.q(q[3]), .t(t[3]), .clk(clk), .rst(reset), .prs(1'b0));

    assign t[0] = 1'b1;
    assign t[1] = q[0];
    assign t[2] = q[0] & q[1];
    assign t[3] = q[0] & q[1] & q[2];

    reg [3:0] count;  
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0011; 
        else if (count == 4'b1101)
            count <= 4'b0011;
        else
            count <= count + 1;
    end

    assign Q = count; 
endmodule