module ROM_4x1 (
    input wire [1:0] addr,
    output wire D
);
    
    reg [3:0] memory;
    
    initial begin
        memory[0] = 0;
        memory[1] = 1;
        memory[2] = 0;
        memory[3] = 1;
    end
    
    assign D = memory[addr];
    
endmodule
