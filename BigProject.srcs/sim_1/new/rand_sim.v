`timescale 1ns / 1ps


module rand_sim();

reg clk = 0;
wire [10:0] ans;
rand R(clk,ans);

always #10 clk = ~clk;

initial begin
#10000 $finish;
end

endmodule
