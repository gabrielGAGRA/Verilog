module primo (N, F ) ;
input [ 15 : 0 ] N;
output reg F ;

always @(*) begin
    
    if (N == 2 | N == 3)  F = 1;

    else begin 
        if ((N-1) % 6 == 0 | (N+1) % 6 == 0)
            F = 1;
        else begin
            F = 0;
        end
    end
end


endmodule