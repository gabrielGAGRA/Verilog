# Calcula o 12º número de Fibonacci. Resultado esperado em a0 = 89.
main:
  addi a0, zero, 12       # n = 12 (parâmetro de entrada)
  beq  a0, zero, end_zero  # Caso especial: se n=0, resultado é 0
  
  addi t0, zero, 0        # a = 0
  addi t1, zero, 1        # b = 1
  addi t2, zero, 2        # i = 2 (contador do loop)

loop:
  bge t2, a0, end         # if (i >= n), fim do loop
  add t3, t0, t1          # temp = a + b
  addi t0, t1, 0          # a = b
  addi t1, t3, 0          # b = temp
  addi t2, t2, 1          # i = i + 1
  jal zero, loop          # Volta para o início do loop

end_zero:
  addi a0, zero, 0        # Resultado para n=0 é 0
  jal zero, halt          # Pula para o halt

end:
  addi a0, t1, 0          # Move o resultado final (em t1) para a0
  
halt:
  jal zero, halt          # halt: PC fica estável aqui