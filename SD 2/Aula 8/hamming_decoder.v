module hamming_dec (
    input [7:1] du,
    output [7:1] dc,
    output NOERROR
);

    wire syn0, syn1, syn2;
    
    wire [2:0] syndrome;

    wire [7:1] error_vec;

    assign syn0 = du[7] ^ du[5] ^ du[3] ^ du[1];
    assign syn1 = du[7] ^ du[6] ^ du[3] ^ du[2];
    assign syn2 = du[7] ^ du[6] ^ du[5] ^ du[4];
    
    assign syndrome = {syn2, syn1, syn0};

    assign error_vec[1] = (syndrome == 3'b001);
    assign error_vec[2] = (syndrome == 3'b010);
    assign error_vec[3] = (syndrome == 3'b011);
    assign error_vec[4] = (syndrome == 3'b100);
    assign error_vec[5] = (syndrome == 3'b101);
    assign error_vec[6] = (syndrome == 3'b110);
    assign error_vec[7] = (syndrome == 3'b111);

    assign dc = du ^ error_vec;

    assign NOERROR = (syndrome == 3'b000);

endmodule