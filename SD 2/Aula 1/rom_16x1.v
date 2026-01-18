module rom_16x1 (
    input [3:0] address,  // 4-bit address input
    output data_out       // 1-bit ROM output
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