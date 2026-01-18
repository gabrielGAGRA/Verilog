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

module fpa(
    input [1:0] ram_addr,  
    output [31:0] ram_out,
    output reg done
);
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk; 

    reg [2:0] rom_addr;
    reg [1:0] addr_counter;
    reg rom_OE;
    reg ram_RW;
    reg ram_OE;
    reg adder_en;
    reg [31:0] operand_1;
    reg [31:0] operand_2;
    wire [31:0] rom_out;
    wire [31:0] adder_sum;
    wire [1:0] ram_addr_mux;
    assign ram_addr_mux = (ram_RW ? addr_counter : ram_addr);

    rom_8 rom_inst (
        .addr(rom_addr),
        .OE(rom_OE),
        .out(rom_out)
    );

    ram_4 ram_inst (
        .in(adder_sum),
        .addr(ram_addr_mux),
        .RW(ram_RW),
        .OE(ram_OE),
        .out(ram_out)
    );

    adder fp_adder (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .clk(clk),
        .en(adder_en),
        .sum(adder_sum)
    );

    reg [3:0] state;
    parameter IDLE             = 4'd0,
              READ_OP1_START   = 4'd1,
              READ_OP1_WAIT    = 4'd2,
              READ_OP2_START   = 4'd3,
              READ_OP2_WAIT    = 4'd4,
              COMPUTE_START    = 4'd5,
              COMPUTE_WAIT     = 4'd6,
              WRITE_RAM        = 4'd7,
              DONE_STATE       = 4'd8;

    initial begin
        state <= IDLE;
        rom_addr <= 3'd0;
        addr_counter <= 2'd0;
        rom_OE <= 1'b0;
        ram_RW <= 1'b0;
        ram_OE <= 1'b0;
        adder_en <= 1'b0;
        done <= 1'b0;
        operand_1 <= 32'd0;
        operand_2 <= 32'd0;
    end

    always @(posedge clk) begin
        case(state)
            IDLE: begin
                rom_addr <= 3'd0;
                addr_counter <= 2'd0;
                rom_OE <= 1'b1; 
                ram_RW <= 1'b0; 
                ram_OE <= 1'b0;
                adder_en <= 1'b0;
                done <= 1'b0;
                state <= READ_OP1_START;
            end

            READ_OP1_START: begin
                rom_addr <= {addr_counter, 1'b0};
                state <= READ_OP1_WAIT;
            end

            READ_OP1_WAIT: begin
                operand_1 <= rom_out;
                state <= READ_OP2_START;
            end

            READ_OP2_START: begin
                rom_addr <= {addr_counter, 1'b0} + 3'b001;
                state <= READ_OP2_WAIT;
            end

            READ_OP2_WAIT: begin
                operand_2 <= rom_out;
                state <= COMPUTE_START;
            end

            COMPUTE_START: begin
                adder_en <= 1'b1;
                state <= COMPUTE_WAIT;
            end

            COMPUTE_WAIT: begin
                adder_en <= 1'b0;
                state <= WRITE_RAM;
            end

            WRITE_RAM: begin
                ram_RW <= 1'b1; 
                ram_OE <= 1'b0; 
                if (addr_counter == 2'd3) begin
                    state <= DONE_STATE;
                end else begin
                    addr_counter <= addr_counter + 1;
                    state <= READ_OP1_START;
                end
            end

            DONE_STATE: begin
                ram_RW <= 1'b0;
                ram_OE <= 1'b1;
                done <= 1'b1;
                state <= DONE_STATE;
            end

            default: state <= IDLE;
        endcase
    end
endmodule
