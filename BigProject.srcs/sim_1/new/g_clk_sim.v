`timescale 1ns / 1ps
module g_clk_sim();
reg clk = 0;
wire ans;
game_clk GC(clk,ans);

always #10 clk = ~clk;

initial begin
#10000 $finish;
end
endmodule
