module test;
reg a = 0, b = 1;
initial begin y = a & b;
endmodule
module xand3(a, b, c, y);
input a, b, c;
output y;
wire t;
xand2 xand0(a, b, t);
xand2 xand1(t, c, y);
endmodule