module codprisimples (i, en, y);
    input  [3:0]i;
    input en;
    output [1:0] y;
    
    assign y[0] = (i[3] | (!i[2] & i[1])) & en;
    assign y[1] = (i[3] | i[2]) & en;

endmodule