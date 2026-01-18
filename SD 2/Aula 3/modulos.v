module rom_8 (
    input [2:0] addr , 
    input OE, 
    output reg [31:0] out 
); 
    reg [31:0] data [7:0]; 
    initial begin 
        data [0] = 32'h0986ab68; 
        data [1] = 32'h10385ba9; 
        data [2] = 32'h3F800000; 
        data [3] = 32'h3C449BA6; 
        data [4] = 32'h40400000;
        data [5] = 32'h41200000; 
        data [6] = 32'h3EA00000;
        data [7] = 32'h3F600000; 
    end 
    always @(addr, OE) 
        if (OE == 1'b1) 
            out = data[addr]; 
        else 
            out = 32'bz;
endmodule


module ram_4 (
    input [31:0] in,
    input [1:0] addr,
    input RW, OE,
    output reg [31:0] out
);
    reg [31:0] data [3:0];
    always @(in, addr, RW, OE) begin
        if (RW == 1'b0 & OE == 1'b1)
            out = data[addr];
        else
            out = 32'bz;
        if (RW == 1'b1)
            data[addr] = in;
    end
endmodule

module adder(
input [31:0] operand_1, operand_2,
input clk, en,
output reg [31:0] sum = 32'bz
);
endmodule