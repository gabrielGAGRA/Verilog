# Calcula o MDC(54, 24). Resultado esperado em a0 = 6
main:
  addi a0, zero, 54   # a0 = 54
  addi a1, zero, 24   # a1 = 24

loop:
  beq a0, a1, end     # se a == b, fim (pula para o halt)
  blt a0, a1, a1_maior # se a < b, pula para o trecho de b = b - a
  
  # a0 > a1
  sub a0, a0, a1      # a = a - b
  jal zero, loop      # volta ao início do loop

a1_maior:
  sub a1, a1, a0      # b = b - a
  jal zero, loop      # volta ao início do loop

end:
  jal zero, end       # halt: PC fica estável aqui