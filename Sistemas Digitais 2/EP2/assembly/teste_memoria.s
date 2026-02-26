# teste_memoria.s
# Programa de diagnóstico focado em Load e Store - Versão Final
.section .text
.global _start

_start:
  # a1 é o registrador do "bitmap de falhas". 0 = sucesso.
  addi a1, zero, 0
  # t5 contém a máscara de bit para o teste atual. Começa em 1.
  addi t5, zero, 1 

# --- TESTE 1: Store Word (SW) e Load Word (LW) ---
  lui  t0, 0xDEADB
  addi t0, t0, -273      # CORRIGIDO: t0 = 0xDEADB000 - 273 = 0xDEADBEEF
  sw   t0, 0(zero)
  lw   t1, 0(zero)
  bne  t0, t1, fail_test_1
pass_test_1:
  slli t5, t5, 1

# --- TESTE 2: Store Byte (SB) e Load Byte (LB - com sinal) ---
  lui  t0, 0x11223
  addi t0, t0, 836       # t0 = 0x11223344
  sw   t0, 4(zero)
  addi t1, zero, -10
  sb   t1, 5(zero)
  lw   t2, 4(zero)
  lui  t3, 0x11F63
  addi t3, t3, 836       # Valor esperado: 0x11F63344
  bne  t2, t3, fail_test_2
  lb   t4, 5(zero)
  addi t3, zero, -10
  bne  t4, t3, fail_test_2
pass_test_2:
  slli t5, t5, 1

# --- TESTE 3: Store Half (SH) e Load Half (LH - com sinal) ---
  lui  t0, 0x11223
  addi t0, t0, 836       # t0 = 0x11223344
  sw   t0, 8(zero)
  addi t1, zero, -100
  sh   t1, 10(zero)
  lw   t2, 8(zero)
  lui  t3, 0x1122F
  addi t3, t3, -100      # CORRIGIDO: Valor esperado: 0x1122FF9C
  bne  t2, t3, fail_test_3
  lh   t4, 10(zero)
  addi t3, zero, -100
  bne  t4, t3, fail_test_3
pass_test_3:
  slli t5, t5, 1

# --- TESTE 4: Load Byte Unsigned (LBU) ---
  addi t0, zero, -1
  sb   t0, 15(zero)
  lbu  t1, 15(zero)
  addi t3, zero, 255
  bne  t1, t3, fail_test_4
pass_test_4:
  slli t5, t5, 1

# --- TESTE 5: Load Half Unsigned (LHU) ---
  addi t0, zero, -1
  sh   t0, 16(zero)
  lhu  t1, 16(zero)
  lui  t3, 0x10
  addi t3, t3, -1       # t3 = 0xFFFF (65535)
  bne  t1, t3, fail_test_5
pass_test_5:

# --- Fim dos Testes ---
  jal zero, all_tests_passed

# --- Rotinas de Falha (executam e continuam para o próximo teste) ---
fail_test_1: or a1, a1, t5; jal zero, pass_test_1;
fail_test_2: or a1, a1, t5; jal zero, pass_test_2;
fail_test_3: or a1, a1, t5; jal zero, pass_test_3;
fail_test_4: or a1, a1, t5; jal zero, pass_test_4;
fail_test_5: or a1, a1, t5; jal zero, pass_test_5;

all_tests_passed:
halt:
  jal zero, halt