module binary_shift_reg_Q #(parameter N = 4) (
    input CLK,
    input RESET,
    input G,
    input LOADB,
    input LOADQ,
    input [N-1:0] MULT_IN,
    output reg [2*N-1:0] MULT_OUT,
    output reg MULT_FINISH
);
    function integer log2;
        input integer value;
        integer i;
        begin
            log2 = 0;
            for (i = value; i > 0; i = i >> 1) begin
                log2 = log2 + 1;
            end
        end
    endfunction

    reg [N-1:0] shift_reg_Q;  
    reg [N-1:0] register_B; 
    reg [N:0] shift_reg_A; 
    reg [log2(N):0] counter; 
    reg [2:0] estado;

    localparam STATE_IDLE = 3'b000;
    localparam STATE_LOAD = 3'b001;
    localparam STATE_CALC = 3'b010;
    localparam STATE_WAIT = 3'b101;   
    localparam STATE_SHIFT = 3'b011;
    localparam STATE_DONE = 3'b100;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            shift_reg_Q <= 0;
            register_B <= 0;
            shift_reg_A <= 0;
            MULT_OUT <= 0;
            MULT_FINISH <= 0;
            counter <= 0;
            estado <= STATE_IDLE;
        end else begin
            case (estado)
                STATE_IDLE: begin
                    MULT_FINISH <= 0;
                    if (LOADB) begin
                        register_B <= MULT_IN;
                    end
                    if (LOADQ) begin
                        shift_reg_Q <= MULT_IN;
                    end
                    if (G) begin
                        shift_reg_A <= 0;
                        counter <= N;
                        estado <= STATE_CALC;
                    end
                end

                STATE_CALC: begin
                    if (counter > 0) begin
                        if (register_B[0] == 1'b1) begin
                            shift_reg_A <= shift_reg_A + {1'b0, shift_reg_Q};
                        end
                        estado <= STATE_WAIT; 
                    end else begin
                        MULT_OUT <= {shift_reg_A[N-1:0], register_B};
                        MULT_FINISH <= 1;
                        estado <= STATE_DONE;
                    end
                end

                STATE_WAIT: begin
                    estado <= STATE_SHIFT;
                end

                STATE_SHIFT: begin
                    {shift_reg_A, register_B} <= {shift_reg_A, register_B} >> 1;
                    counter <= counter - 1;
                    estado <= STATE_CALC;
                end

                STATE_DONE: begin
                    if (!G) begin
                        estado <= STATE_IDLE;
                    end
                end

                default: estado <= STATE_IDLE;
            endcase
        end
    end
endmodule