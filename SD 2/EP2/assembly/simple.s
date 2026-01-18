main:
  beq x0, x0, exit      # Salto incondicional para a etiqueta 'exit'

# Esta instrução só executa se o BEQ falhar
fail:
  addi a0, zero, 999    # Carrega 999 em a0 para indicar falha

exit:
  addi a0, zero, 1      # Carrega 1 em a0 para indicar sucesso

halt:
  jal zero, halt        # Loop de halt para estabilizar o PC