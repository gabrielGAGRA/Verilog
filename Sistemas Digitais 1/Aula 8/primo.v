module primo (N, F );
input [ 3 : 0 ] N;
output F;
assign a = N[2];
assign b = N[3];
assign c = N[0];
assign d = N[1];
assign F = (a & !d & c) | (d & c & (!b | !a)) | (!a & !b & d);
endmodule