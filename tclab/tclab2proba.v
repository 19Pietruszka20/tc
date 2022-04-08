module tclab2proba();
reg [3:0] c = 0;
always @(*)
begin
c <= c + 1;
if (c == 1)
$display("foo");
end
endmodule