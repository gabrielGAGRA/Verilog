//Um registrador (Program Counter) que tem uma entrada e uma saída de 32 bits, sensível a borda de subida do clock e com reset.
module program_counter(
    input  [31:0] PC_input,   //endereço de input
    input         clk,        //sinal de clock
    input         reset,      //sinal de reset para zerar o PC
    output reg [31:0] PC_output //endereço de output para a instruction memory
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_output <= 32'd0;
        end else begin
            PC_output <= PC_input; 
        end
    end
endmodule

//Um módulo para somar 4 na saida do Program Counter e devolver o novo valor na entrada do PC.
module modulo_de_soma(
    input  [31:0] adder_input,   //input que recebe do PC
    output [31:0] adder_output   //output que retorna ao PC
);
    assign adder_output = adder_input + 32'd4;
endmodule

//Uma memória para as instruções (instruction memory) , 64 registradores de 32 bits concatenados, sensível a borda de subidad do clock e com reset.
module instruction_memory(
    input  [31:0] read_address,        // lê o endereço do PC
    input         clk,                 // sinal de clock 
    input         reset,               // sinal de reset para zerar as instruções
    output reg [31:0] instruction_out  // qual instrução sai para o resto do processador
);
    reg [31:0] instruction_list [63:0]; // vetor de registradores para guardar as instruções

    integer i; //isso aqui eh so pra resetar, nao tem como fazer while(1)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1) begin
                instruction_list[i] <= 32'd0;
            end
            instruction_out <= 32'd0;
        end else begin
            instruction_out <= instruction_list[read_address[31:2]];
        end
    end
endmodule

//nao sao 3 modulos, sao 4 ne? nao sei como fazer isso so com 3, tem que instanciar tudo depois ue
module instruction_fetch(
    input         clk,
    input         reset,
    output [31:0] current_instruction,
    output [31:0] current_pc
);
    wire [31:0] pc_next;
    wire [31:0] pc_out;
    wire [31:0] instr_out;

    program_counter u_pc(
        .PC_input(pc_next),
        .clk(clk),
        .reset(reset),
        .PC_output(pc_out)
    );

    pc_adder u_adder(
        .adder_input(pc_out),
        .adder_output(pc_next)
    );

    instruction_memory u_imem(
        .read_address(pc_out),
        .clk(clk),
        .reset(reset),
        .instruction_out(instr_out)
    );

    assign current_pc = pc_out;
    assign current_instruction = instr_out;

endmodule