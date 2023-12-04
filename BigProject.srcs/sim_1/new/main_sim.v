`timescale 1ns / 1ps

module main_sim();
reg clk = 0;
reg rst = 0;
reg b1=0,b2=0,b3=0;
reg res=0,mode=0;
wire [13:0] vga;
wire st;
main M(clk,rst,b1,b2,b3,res,mode,vga,st);

always #10 clk = ~clk;

initial begin
#100 rst = 1;
#100 b2=1;
#20 b2=0;
#10000 $finish;
end
endmodule
