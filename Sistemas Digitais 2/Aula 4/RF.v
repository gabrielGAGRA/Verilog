// Gabriel Agra de Castro Motta
// 15452743
// Mateus  Silva de Araujo
// 15497076

module registerfile
  #(parameter W = 32)
(
  input  wire [4:0] Read1, Read2, WriteReg,
  input  wire [W-1:0] WriteData,
  input  wire RegWrite,
  input  wire clk,
  output wire [W-1:0] Data1, Data2
);

  // 32 registradores
  reg [W-1:0] registers [31:0];

  // Rzero, se read1 ou read2 forem 0, a saida correspondente data1 ou data2 sera 0
  assign Data1 = (Read1 == 0) ? {W{1'b0}} : registers[Read1];
  assign Data2 = (Read2 == 0) ? {W{1'b0}} : registers[Read2];

  // escreve sincrona
  always @(posedge clk) begin
    if (RegWrite && WriteReg != 5'd0) begin
      registers[WriteReg] <= WriteData;
    end
  end
endmodule