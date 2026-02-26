module RAM_16x1 (
input wire clk, // Clock
input wire we, // Sinal de escrita
input wire [3:0] addr, // Endereço
input wire din, // Dado de entrada
output wire dout // Dado de saída
);


reg mem [15:0];
always @(posedge clk) begin
if (we)
mem[addr] <= din;
end
assign dout = mem[addr];

endmodule