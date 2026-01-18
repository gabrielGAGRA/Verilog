module rom_16x1 (
input [3:0] address, // 4-bit address input
output data_out // 1-bit ROM output
);
wire a3, a2, a1, a0;

assign a3 = address[3];
assign a2 = address[2];
assign a1 = address[1];
assign a0 = address[0];

wire addr_0, addr_1, addr_2, addr_3, addr_4, addr_5, addr_6, addr_7;
wire addr_8, addr_9, addr_10, addr_11, addr_12, addr_13, addr_14, addr_15;

assign addr_0 = ~a3 & ~a2 & ~a1 & ~a0;
assign addr_1 = ~a3 & ~a2 & ~a1 & a0;
assign addr_2 = ~a3 & ~a2 & a1 & ~a0;
assign addr_3 = ~a3 & ~a2 & a1 & a0;
assign addr_4 = ~a3 & a2 & ~a1 & ~a0;
assign addr_5 = ~a3 & a2 & ~a1 & a0;
assign addr_6 = ~a3 & a2 & a1 & ~a0;
assign addr_7 = ~a3 & a2 & a1 & a0;
assign addr_8 = a3 & ~a2 & ~a1 & ~a0;
assign addr_9 = a3 & ~a2 & ~a1 & a0;
assign addr_10 = a3 & ~a2 & a1 & ~a0;
assign addr_11 = a3 & ~a2 & a1 & a0;
assign addr_12 = a3 & a2 & ~a1 & ~a0;
assign addr_13 = a3 & a2 & ~a1 & a0;
assign addr_14 = a3 & a2 & a1 & ~a0;
assign addr_15 = a3 & a2 & a1 & a0;

assign data_out = addr_0 | addr_2 | addr_5 | addr_7 | addr_8 | addr_9 |
addr_10 | addr_13 | addr_14 | addr_15;
endmodule

19 março
Mateus Silva de Araujo
Mateus Silva de Araujo
14:49
module rom_16 (addr, CS, OE, out);
input [3:0] addr;
input CS, OE;
output reg [15:0] out;
reg [15:0] data[15:0];
initial
for (integer i = 0; i < 16; i++)
data[i] = ~i[15:0];
always @(addr, CS, OE)
if (OE == 1'b1 && CS == 1'b1)
out = data[addr];
else
out = 16'bz;
endmodule

module ram_4 (in, addr, RW, CS, OE, out);
input [15:0] in;
input [1:0] addr;
input RW, CS, OE;
output reg [15:0] out;
reg [15:0] data[3:0];
always @(addr, CS, OE, RW)
begin
if (RW == 1'b0 && OE == 1'b1 && CS == 1'b1)
out = data[addr];
else
out = 16'bz;
if (RW == 1'b1 && CS == 1'b1)
data[addr] = in;
end
endmodule

module ram_8 (in, addr, RW, CS, OE, out);
input [15:0] in;
input [2:0] addr;
input RW, CS, OE;
output reg [15:0] out;
wire [15:0] out1, out2;
wire CS1, CS2;
assign CS1 = CS & ~addr[2];
assign CS2 = CS & addr[2];

ram_4 ram1 (in, addr[1:0], RW, CS1, OE, out1);
ram_4 ram2 (in, addr[1:0], RW, CS2, OE, out2);

always @(*)
out = CS1 ? out1 : (CS2 ? out2 : 16'bz);
endmodule

module memchip_64 (in, addr, RW, out);
input [15:0] in;
input [5:0] addr;
input RW;
output reg [15:0] out;
wire [15:0] out_rom, out_ram1, out_ram2;
wire CS_rom, CS_ram1, CS_ram2;

assign CS_rom = (addr >= 6'h00 && addr <= 6'h0F);
assign CS_ram1 = (addr >= 6'h10 && addr <= 6'h17);
assign CS_ram2 = (addr >= 6'h28 && addr <= 6'h2F);

rom_16 rom (addr[3:0], CS_rom, ~RW, out_rom);
ram_8 ram1 (in, addr[2:0], RW, CS_ram1, ~RW, out_ram1);
ram_8 ram2 (in, addr[2:0], RW, CS_ram2, ~RW, out_ram2);

always @(*)
if (CS_rom)
out = out_rom;
else if (CS_ram1)
out = out_ram1;
else if (CS_ram2)
out = out_ram2;
else
out = 16'bz;
endmodule