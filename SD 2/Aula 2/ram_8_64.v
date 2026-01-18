module rom_16 (addr, CS, OE, out);
  input [3:0] addr;
  input CS, OE;
  output reg [15:0] out;
  reg [15:0] data [15:0];

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
  reg [15:0] data [3:0];

  always @(addr, CS, OE, RW) begin
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
  
  wire [15:0] out_low, out_high;
  wire cs_low, cs_high;
  
  assign cs_low = CS && !addr[2];
  assign cs_high = CS && addr[2];

  ram_4 ram_low(
    .in(in),
    .addr(addr[1:0]),
    .RW(RW),
    .CS(cs_low),
    .OE(OE),
    .out(out_low)
  );

  ram_4 ram_high(
    .in(in),
    .addr(addr[1:0]),
    .RW(RW),
    .CS(cs_high),
    .OE(OE),
    .out(out_high)
  );
  
  always @(addr, CS, OE, out_low, out_high) begin
    if (CS && OE)
      out = addr[2] ? out_high : out_low;
    else
      out = 16'bz;
  end
endmodule

module memchip_64(in, addr, RW, out);
  input [15:0] in;
  input [5:0] addr;
  input RW;
  output reg [15:0] out;
  
  wire [15:0] out_rom, out_ram_low, out_ram_high;
  wire cs_rom, cs_ram_low, cs_ram_high;
  wire internal_OE;
  
  assign internal_OE = 1'b1;
  
  assign cs_rom = (addr[5:4] == 2'b00);
  
  assign cs_ram_low = (addr[5:3] == 3'b010);
  
  assign cs_ram_high = (addr[5:3] == 3'b100);
  
  rom_16 rom(
    .addr(addr[3:0]), 
    .CS(cs_rom),       
    .OE(internal_OE),          
    .out(out_rom)      
  );
  
  ram_8 ram_low(
    .in(in),             
    .addr(addr[2:0]),    
    .RW(RW),
    .CS(cs_ram_low),     
    .OE(internal_OE),
    .out(out_ram_low)
  );
  
  ram_8 ram_high(
    .in(in),             
    .addr(addr[2:0]),    
    .RW(RW),
    .CS(cs_ram_high),  
    .OE(internal_OE),
    .out(out_ram_high)
  );
  
  always @(addr, out_rom, out_ram_low, out_ram_high) begin
    case(addr[5:3])
      3'b000, 3'b001: out = out_rom;    
      3'b010: out = out_ram_low;          
      3'b100: out = out_ram_high;         
      default: out = 16'bz;              
    endcase
  end
endmodule