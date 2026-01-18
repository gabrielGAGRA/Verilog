`timescale 1ns/1ps

module juiz_tb;

    // Parâmetros de simulação
    localparam CLK_PERIOD       = 10;
    localparam INSTRUCTIONS     = 1024;
    localparam DATAWORDS        = 1024;
    localparam HALT_CYCLES_THR  = 10;
    localparam TIMEOUT_CYCLES   = 500;

    // Sinais de controle
    reg clk;
    reg rst;

    // Sinais da interface do processador
    reg  [31:0] IM_data_from_mem;
    reg  [31:0] DM_data_from_mem;
    wire [$clog2(INSTRUCTIONS*4)-1:0] IM_address_to_mem;
    wire [$clog2(DATAWORDS*4)-1:0]  DM_address_to_mem;
    wire [31:0] DM_data_to_mem;
    wire        DM_write_enable_to_mem;

    // Sinais de depuração requeridos pelo enunciado
    wire [31:0] pc;
    wire [31:0] pc_in;
    wire [31:0] ALUout;
    wire [31:0] rfi_wd;
    wire [4:0]  rfi_rd;

    // Instanciação do Processador (Device Under Test)
    // Assumindo que o seu módulo de topo está em "poliriscv_sc32.v"
    poliriscv_sc32 #(
        .instructions(INSTRUCTIONS),
        .datawords(DATAWORDS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .IM_data(IM_data_from_mem),
        .DM_data_i(DM_data_from_mem),
        .IM_address(IM_address_to_mem),
        .DM_address(DM_address_to_mem),
        .DM_data_o(DM_data_to_mem),
        .DM_write_enable(DM_write_enable_to_mem),
        .pc(pc),
        .pc_in(pc_in),
        .ALUout(ALUout),
        .rfi_wd(rfi_wd),
        .rfi_rd(rfi_rd)
    );

    // Memória de Instruções
    reg [31:0] instruction_memory [0:INSTRUCTIONS-1];
    initial begin
        $readmemh("program.mem", instruction_memory);
    end
    always @(*) begin
        // A memória é acessada por palavra, mas o endereço vem em bytes (PC >> 2)
        IM_data_from_mem = instruction_memory[IM_address_to_mem >> 2];
    end

    // Memória de Dados
    reg [31:0] data_memory [0:DATAWORDS-1];
    integer i;
    initial begin
        // Inicializa a memória de dados com zeros
        for (i = 0; i < DATAWORDS; i = i + 1) begin
            data_memory[i] = 32'h00000000;
        end
    end
    always @(*) begin
        DM_data_from_mem = data_memory[DM_address_to_mem >> 2];
    end
    always @(posedge clk) begin
        if (DM_write_enable_to_mem) begin
            data_memory[DM_address_to_mem >> 2] <= DM_data_to_mem;
            $display("Ciclo %0t: [MEM WRITE] Endereço: 0x%h, Dado: 0x%h", $time, DM_address_to_mem, DM_data_to_mem);
        end
    end

    // Geração de Clock
    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Lógica de simulação e verificação de término
    reg [31:0] prev_pc;
    integer stable_pc_counter;

    initial begin
        // Inicia com reset
        rst = 1'b1;
        stable_pc_counter = 0;
        prev_pc = 32'hFFFFFFFF;
        #(2 * CLK_PERIOD);
        rst = 1'b0;
        $display("Ciclo %0t: Reset liberado. Iniciando execução.", $time);
        
        // Timeout
        #(TIMEOUT_CYCLES * CLK_PERIOD);
        $display("-----------------------------------------------");
        $display("FALHA: Simulação atingiu o TIMEOUT de %0d ciclos.", TIMEOUT_CYCLES);
        $display("Verifique se o programa entrou em um loop inesperado.");
        $display("Último PC: 0x%h", pc);
        $display("-----------------------------------------------");
        $finish;
    end

    always @(posedge clk) begin
        if (!rst) begin
            $display("Ciclo %0t: PC=0x%h, Inst=0x%h, rfi_rd=%d, rfi_wd=0x%h, ALUout=0x%h",
                $time, pc, IM_data_from_mem, rfi_rd, rfi_wd, ALUout);

            // Verifica se o PC está estável
            if (pc == prev_pc) begin
                stable_pc_counter = stable_pc_counter + 1;
            end else begin
                stable_pc_counter = 0;
            end
            
            prev_pc <= pc;

            if (stable_pc_counter >= HALT_CYCLES_THR) begin
                $display("------------------------------------------------------------");
                $display("SUCESSO: O PC permaneceu estável em 0x%h por %0d ciclos.", pc, HALT_CYCLES_THR);
                $display("Simulação encerrada com êxito.");
                $display("Valor final em a0 (x10): %d (0x%h)", dut.dut_datapath.reg_file_unit.registers[10], dut.dut_datapath.reg_file_unit.registers[10]);
                $display("Valor final em mem[0]: 0x%h", data_memory[0]);
                $display("------------------------------------------------------------");
                $finish;
            end
        end
    end

endmodule