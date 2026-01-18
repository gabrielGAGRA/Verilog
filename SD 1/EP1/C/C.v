module ep01C (a, b, c, d, f);
    input a, b, c, d;
    output f;

    // coloque aqui a descricao do circuito 
        wire [3:0] mux_inputs;
        wire [1:0] sel;
    
        assign mux_inputs[0] = b & d; // 00
        assign mux_inputs[1] = b | d; // 01
        assign mux_inputs[2] = b;     // 10
        assign mux_inputs[3] = 1'b1;  // 11
    
        assign sel = {a, c};
    
        assign f = mux_inputs[sel];
    
    endmodule