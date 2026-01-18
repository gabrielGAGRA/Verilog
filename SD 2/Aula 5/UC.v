module alu
#(parameter W = 64)
(
    input  [3:0]   ALUctl,
    input  [W-1:0] A, B,
    output [W-1:0] ALUout,
    output Zero
);
    assign ALUout = (ALUctl == 4'b0000) ? (A & B) : //AND
                    (ALUctl == 4'b0001) ? (A | B) : //OR
                    (ALUctl == 4'b0010) ? (A + B) : //ADD
                    (ALUctl == 4'b0110) ? (A - B) : //SUB
                    (ALUctl == 4'b0111) ? (($signed(A) < $signed(B)) ? {{W-1{1'b0}}, 1'b1} : {W{1'b0}}) : //BLT
                    (ALUctl == 4'b1100) ? (~(A | B)) : //NOR
                    {W{1'bx}}; 

    assign Zero = (ALUout == {W{1'b0}});
endmodule

module DataMemory (
    input wire [5:0] address,
    input wire [63:0] WriteData,
    input wire MemWrite,
    input wire MemRead,
    output reg [63:0] RegData,
    input wire clk,
    input wire rst
);
    reg [63:0] registers [63:0];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1)
                registers[i] <= 64'b0;
        end
        else if (MemWrite)
            registers[address] <= WriteData;
    end

    always @(*) begin
        if (MemRead)
            RegData = registers[address];
        else
            RegData = 64'hXXXXXXXXXXXXXXXX;
    end
endmodule

module registerfile
  #(parameter W = 64)
(
  input  wire [4:0] Read1, Read2, WriteReg,
  input  wire [W-1:0] WriteData,
  input  wire RegWrite,
  input  wire clk,
  input  wire rst,
  output wire [W-1:0] Data1, Data2
);
  reg [W-1:0] registers [31:0];
  integer i;

  assign Data1 = (Read1 == 5'b0) ? {W{1'b0}} : registers[Read1];
  assign Data2 = (Read2 == 5'b0) ? {W{1'b0}} : registers[Read2];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= {W{1'b0}};
        end
    end else begin
        if (RegWrite && WriteReg != 5'd0) begin
          registers[WriteReg] <= WriteData;
        end
    end
  end
endmodule

module InstructionMemory #(
    parameter IFILE       = "rom_hex.mem",
    parameter ADDR_WIDTH  = 6
)(
    input  wire [ADDR_WIDTH-1:0] ReadAddress,
    output reg  [31:0]           Instruction,
    input  wire                  clk,
    input  wire                  rst
);
    localparam DEPTH = (1 << ADDR_WIDTH);
    reg [31:0] memory [0:DEPTH-1];

    initial begin
        $readmemh(IFILE, memory);
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            Instruction <= 32'b0;
        else
            Instruction <= memory[ReadAddress];
    end
endmodule

module ProgramCounter (
    input wire clk,
    input wire rst,
    input wire [5:0] nextPC,
    output reg [5:0] PC
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 6'b0;
        else
            PC <= nextPC;
    end
endmodule

module ImmGen (
    input wire [31:0] inst,
    output reg [63:0] imm
);
    always @(*) begin
        case(inst[6:0])
            7'b0000011: imm = {{52{inst[31]}}, inst[31:20]};
            7'b0010011: imm = {{52{inst[31]}}, inst[31:20]};
            7'b1100111: imm = {{52{inst[31]}}, inst[31:20]};
            7'b0100011: imm = {{52{inst[31]}}, inst[31:25], inst[11:7]};
            7'b1100011: imm = {{51{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            7'b0110111: imm = {{32{inst[31]}}, inst[31:12], 12'b0};
            7'b0010111: imm = {{32{inst[31]}}, inst[31:12], 12'b0};
            7'b1101111: imm = {{43{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            default: imm = 64'b0;
        endcase
    end
endmodule

module datapath #(
    parameter IFILE_DATAPATH = "rom_hex.mem"
)(
    input wire clk,
    input wire rst,

    input wire i_RegWrite,
    input wire i_ALUSrc,
    input wire i_MemtoReg,
    input wire i_MemRead,
    input wire i_MemWrite,
    input wire i_Branch,
    input wire i_BranchOnNotZero,
    input wire [3:0] i_ALUControl,

    output wire [63:0] o_ALUResult,
    output wire o_zero,
    output wire [6:0] o_opcode,
    output wire [2:0] o_funct3,
    output wire o_funct7_bit30,
    output wire [5:0] o_PC_current
);

    wire [5:0] PC_current_val, PC_next;
    wire [31:0] instruction_word;
    wire [63:0] rf_ReadData1, rf_ReadData2;
    wire [63:0] immediate_extended;
    wire [63:0] alu_operand2;
    wire [63:0] alu_result_internal;
    wire [63:0] data_memory_read_data;
    wire [63:0] data_to_write_to_reg;
    wire alu_zero_flag_internal;

    ProgramCounter pc_unit (
        .clk(clk), .rst(rst), .nextPC(PC_next), .PC(PC_current_val)
    );
    assign o_PC_current = PC_current_val;

    InstructionMemory #(.IFILE(IFILE_DATAPATH)) imem_unit (
        .ReadAddress(PC_current_val), .Instruction(instruction_word), .clk(clk), .rst(rst)
    );

    registerfile #(.W(64)) reg_file_unit (
        .Read1(instruction_word[19:15]), .Read2(instruction_word[24:20]),
        .WriteReg(instruction_word[11:7]), .WriteData(data_to_write_to_reg),
        .RegWrite(i_RegWrite), .clk(clk), .rst(rst),
        .Data1(rf_ReadData1), .Data2(rf_ReadData2)
    );

    ImmGen imm_gen_unit (
        .inst(instruction_word), .imm(immediate_extended)
    );

    assign alu_operand2 = i_ALUSrc ? immediate_extended : rf_ReadData2;

    alu #(.W(64)) alu_unit (
        .ALUctl(i_ALUControl), .A(rf_ReadData1), .B(alu_operand2),
        .ALUout(alu_result_internal), .Zero(alu_zero_flag_internal)
    );

    DataMemory dmem_unit (
        .address(alu_result_internal[5:0]), .WriteData(rf_ReadData2),
        .MemWrite(i_MemWrite), .MemRead(i_MemRead),
        .RegData(data_memory_read_data), .clk(clk), .rst(rst)
    );

    assign data_to_write_to_reg = i_MemtoReg ? data_memory_read_data : alu_result_internal;

    wire signed [63:0] signed_imm_byte_offset_for_branch = $signed(immediate_extended);
    wire signed [63:0] signed_imm_word_offset_for_branch = signed_imm_byte_offset_for_branch >>> 2;
    wire [5:0] branch_target_pc_word = PC_current_val + signed_imm_word_offset_for_branch[5:0];

    wire condition_active = (i_BranchOnNotZero) ? !alu_zero_flag_internal : alu_zero_flag_internal;
    assign PC_next = (i_Branch && condition_active) ? branch_target_pc_word : (PC_current_val + 6'd1);

    assign o_ALUResult = alu_result_internal;
    assign o_zero = alu_zero_flag_internal;
    assign o_opcode = instruction_word[6:0];
    assign o_funct3 = instruction_word[14:12];
    assign o_funct7_bit30 = instruction_word[30];
endmodule

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire        funct7_bit30,
    output wire        RegWrite,
    output wire        ALUSrc,
    output wire        MemtoReg,
    output wire        MemRead,
    output wire        MemWrite,
    output wire        Branch,
    output wire        BranchOnNotZero,
    output wire [3:0]  ALUControl
);
    assign RegWrite = (opcode==7'b0010011&&funct3==3'b000)||(opcode==7'b0110011&&funct3==3'b000&&funct7_bit30);
    assign ALUSrc = (opcode==7'b0010011&&funct3==3'b000);
    assign MemtoReg = 1'b0; 
    assign MemRead = 1'b0; 
    assign MemWrite = 1'b0; 
    assign Branch = (opcode==7'b1100011&&(funct3==3'b000||funct3==3'b100)); 
    assign BranchOnNotZero = (opcode==7'b1100011&&funct3==3'b100); 
    assign ALUControl = (opcode==7'b0010011&&funct3==3'b000) ? 4'b0010 : (opcode==7'b1100011&&funct3==3'b000) ? 4'b0110 : (opcode==7'b1100011&&funct3==3'b100) ? 4'b0111 : (opcode==7'b0110011&&funct3==3'b000&&funct7_bit30) ? 4'b0110 : 4'b0010;
endmodule

module poliriscv_sc #(
    parameter IFILE = "rom_hex.mem",
    parameter instructions = 256,
    parameter datawords = 1024
)(
    input wire clk,
    input wire rst,
    output wire [5:0] pc
);

    wire i_RegWrite;
    wire i_ALUSrc;
    wire i_MemtoReg;
    wire i_MemRead;
    wire i_MemWrite;
    wire i_Branch;
    wire i_BranchOnNotZero;
    wire [3:0] i_ALUControl;

    wire [63:0] o_ALUResult_from_dp;
    wire o_zero_from_dp;
    wire [6:0] o_opcode_from_dp;
    wire [2:0] o_funct3_from_dp;
    wire o_funct7_bit30_from_dp;

    datapath #(
        .IFILE_DATAPATH(IFILE)
    ) dut_datapath (
        .clk(clk), .rst(rst),
        .i_RegWrite(i_RegWrite), .i_ALUSrc(i_ALUSrc), .i_MemtoReg(i_MemtoReg),
        .i_MemRead(i_MemRead), .i_MemWrite(i_MemWrite), .i_Branch(i_Branch),
        .i_BranchOnNotZero(i_BranchOnNotZero), .i_ALUControl(i_ALUControl),
        .o_ALUResult(o_ALUResult_from_dp), .o_zero(o_zero_from_dp),
        .o_opcode(o_opcode_from_dp), .o_funct3(o_funct3_from_dp),
        .o_funct7_bit30(o_funct7_bit30_from_dp), .o_PC_current(pc)
    );

    control_unit dut_control_unit (
        .opcode(o_opcode_from_dp), .funct3(o_funct3_from_dp), .funct7_bit30(o_funct7_bit30_from_dp),
        .RegWrite(i_RegWrite), .ALUSrc(i_ALUSrc), .MemtoReg(i_MemtoReg),
        .MemRead(i_MemRead), .MemWrite(i_MemWrite), .Branch(i_Branch),
        .BranchOnNotZero(i_BranchOnNotZero), .ALUControl(i_ALUControl)
    );
endmodule
