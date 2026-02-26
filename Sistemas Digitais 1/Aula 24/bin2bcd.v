module bin2bcd #(
parameter NUMBCDS = 4,
parameter NUMBIN =14) (
input [NUMBIN-1:0] bin,
output reg [NUMBCDS*4-1:0] bcd
);
reg [NUMBCDS*4-1:0] bc;
reg [NUMBIN-1:0] bn;
integer i,j;
always @(bin) begin
    bc=0;
    bn=bin;
    for (i = 0; i < NUMBIN; i = i + 1) begin
        for (j = 0; j < NUMBCDS;j=j+1 ) begin
            if (bc[4*j+:4] > 4) begin
                bc[4*j+:4]=bc[4*j+:4]+3;
            end
        end
        bc = bc <<1;
        bc[0] = bn[NUMBIN-1];
        bn = bn<<1;
        bcd = bc;
    end
end
endmodule