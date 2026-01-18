@block
def alu(reset, alu_decode, rda, rdx, result):

    @always_comb
    def operation():
        if reset.next == INACTIVE_HIGH:
            if alu_decode == AND:
                result.next = rda & rdx
            elif alu_decode == OR:
                result.next = rda | rdx
            elif alu_decode == ADD:
                result.next = rda + rdx
            elif alu_decode == SUB:
                result.next = rda - rdx
            elif alu_decode == XOR:
                result.next = rda ^ rdx
            elif alu_decode == SLL:
                result.next = rda << rdx
            elif alu_decode == SRL:
                result.next = rda.signed() >> rdx
            elif alu_decode == SLT:
                result.next = True if (rda.signed() < rdx.signed()) else False
            elif alu_decode == SLTU:
                result.next = True if (rda.unsigned() < rdx.unsigned()) else False
            elif alu_decode == SRA:
                if rda[31] == 0:
                    result.next = rda.signed() >> rdx
                elif rda[31] == 1:
                    temp = (2**rdx) - 1
                    pad = signal(intbv(temp)[rdx:])
                    result.next = rda.signed() >> rdx
                    result.next[32:(31 - rdx)] = pad

    return operation