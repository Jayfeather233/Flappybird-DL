`timescale 1ns / 1ps

module game_clk(input clk, output reg g_clk = 0);
reg [24:0] cnt = 0;
always @(posedge clk) begin
    if(cnt == 25'd120000) begin
    //if(cnt == 23'd2) begin
        cnt = 0;
        g_clk = ~g_clk;
    end else cnt = cnt + 1;
end
endmodule
