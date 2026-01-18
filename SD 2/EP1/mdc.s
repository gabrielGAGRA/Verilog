# a = x10
# b = x11
addi x10, x0, 42       # exemplo: a = 42
addi x11, x0, 30       # exemplo: b = 30

mdc:
    beq  x10, x11, end     # se a for igual a b, achamos o mdc
    blt  x10, x11, troca   # se a for menor que b, troca a e b
    sub  x10, x10, x11     # se nao, eh maior, entao a = a - b
    jal  x0, mdc           
    
troca:
    sub  x11, x11, x10     # b = b - a
    jal  x0, mdc             

end:
