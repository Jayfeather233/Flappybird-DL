`timescale 1ns / 1ps

module rand(input clk, output [10:0] opt);
reg [24:0] state = 25'd19260817;
always @(posedge clk) begin
    state = state * 1000003;
    state = state + 99907;
end
assign opt = state[10:0];
endmodule
