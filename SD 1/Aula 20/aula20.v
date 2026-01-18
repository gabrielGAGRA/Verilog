module a20moore (CLOCK,RESET,X,Z);
input CLOCK;
input RESET;
input X;
output reg Z;
reg [3:0] Sreg, Snext;
parameter [2:0] 
A = 3'b000,
B = 3'b001,
C = 3'b010,
D = 3'b011,
E = 3'b100,
F = 3'b101,
G = 3'b110,
H = 3'b111
;
// State memory with active-high synchronous reset
always @ (posedge CLOCK) begin // Create state memory
if (RESET==1) Sreg <= A;
else Sreg <= Snext;
$display("Sreg=%b", Sreg);
end
// Next state logic
always @ (X,Sreg) begin // Next state logic
case (Sreg)
A: if (X==0) Snext = B; else Snext = A;
B: if (X==0) Snext = B; else Snext = C;
C: if (X==0) Snext = B; else Snext = D;
D: if (X==0) Snext = E; else Snext = C;
E: if (X==0) Snext = B; else Snext = A;
default Snext = A;
endcase
end
// Output logic
always @ (Sreg) begin// Output logic
case (Sreg)
A: Z = 0;
B: Z = 0;
C: Z = 0;
D: Z = 0;
E: Z = 1;
F: Z = 0;
G: Z = 0;
H: Z = 0;
default Z = 0;
endcase
end
endmodule