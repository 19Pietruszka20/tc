
module test ;
reg x = 0;
reg y = 0;
reg [3:0] t = ’b1000 ;
wire z;
integer i;

my_and my_and1 (x, y, z);

initial begin
for (i = 0; i < 4; i = i + 1) begin
{ x, y } <= i;
#1;
$display ( " % h \ t ␣ % h \ t ␣ % h \ t " , x, y, z);
end
end

endmodule
