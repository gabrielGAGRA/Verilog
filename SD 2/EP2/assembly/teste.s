# Programa de Diagnóstico para o PoliRV - Versão para Toolchain
.section .text
.global _start

_start:
  addi a1, zero, 0      # Inicia o código de erro como 0 (sucesso)

# --- TESTE 1: Instrução R-type (SUB) ---
  addi t0, zero, 15
  addi t1, zero, 8
  sub  t2, t0, t1
  addi t3, zero, 7
  bne  t2, t3, fail_test_1

# --- TESTE 2: Desvio Condicional (BGE) ---
  addi t0, zero, 10
  addi t1, zero, 5
  bge  t0, t1, test_2_passed
  jal  zero, fail_test_2
test_2_passed:

# --- TESTE 3: Desvio Condicional (BLTU) ---
  addi t0, zero, -1
  addi t1, zero, 1
  bltu t0, t1, fail_test_3
  
# --- TESTE 4: Store Byte (SB) e Load Byte (LB) ---
  lui  t0, 0x11223       # Carrega 0x11223000 em t0
  addi t0, t0, 0x344      # t0 = 0x11223344
  sw   t0, 0(zero)
  addi t1, zero, 0xAA
  sb   t1, 1(zero)
  lw   t2, 0(zero)
  lui  t3, 0x11AA3       # Valor esperado: 0x11AA3000
  addi t3, t3, 0x344      # Valor esperado: 0x11AA3344
  bne  t2, t3, fail_test_4

# --- TESTE 5: Store Half (SH) e Load Half (LH) ---
  lui  t0, 0x11223
  addi t0, t0, 0x344      # t0 = 0x11223344
  sw   t0, 4(zero)
  lui  t1, 1              # Load upper bits for 0x1000
  addi t1, t1, -1041      # t1 = 0x1000 - 1041 = 0xBEF
  sh   t1, 6(zero)
  lw   t2, 4(zero)
  lui  t3, 0x1122B        # Expected value upper: 0x1122B000
  addi t3, t3, -273       # t3 = 0x1122B000 - 273 = 0x1122BEEF
  bne  t2, t3, fail_test_5

# --- Fim dos Testes ---
  jal zero, all_tests_passed

# --- Rotinas de Falha ---
fail_test_1: addi a1, zero, 1; jal zero, halt;
fail_test_2: addi a1, zero, 2; jal zero, halt;
fail_test_3: addi a1, zero, 3; jal zero, halt;
fail_test_4: addi a1, zero, 4; jal zero, halt;
fail_test_5: addi a1, zero, 5; jal zero, halt;

all_tests_passed:
halt:
  jal zero, halt