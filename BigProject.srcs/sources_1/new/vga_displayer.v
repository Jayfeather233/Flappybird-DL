`timescale 1ns / 1ps

//13 12 11 ~ 1 0
//3 2 1 0red ~ hs vs

module vga_displayer #(
parameter C_H_SYNC_PULSE    =11'd96,
parameter C_H_BACK_PORCH    =11'd48,
parameter C_H_ACTIVE_TIME   =11'd640,
parameter C_H_FRONT_PORCH   =11'd16,
parameter C_H_LINE_PERIOD   =11'd800,

parameter C_V_SYNC_PULSE    =11'd2,
parameter C_V_BACK_PORCH    =11'd33,
parameter C_V_ACTIVE_TIME   =11'd480,
parameter C_V_FRONT_PORCH   =11'd10,
parameter C_V_FRAME_PERIOD  =11'd525)
(   input vga_clk, input rst,
    output active,
    output [10:0] x,
    output [10:0] y,
    output [1:0] sync);

reg [10:0] hc = 0;
always @(posedge vga_clk) begin
    if(~rst) hc <= 0;
    else if (hc == C_H_LINE_PERIOD - 1) hc <= 0;
    else hc <= hc + 1;
end

reg [10:0] vc = 0;
always @(posedge vga_clk) begin
    if(~rst) vc <= 0;
    else if (vc == C_V_FRAME_PERIOD - 1) vc <= 0;
    else if (hc == C_H_LINE_PERIOD - 1) vc <= vc + 1;
    else vc <= vc;
end


assign x = hc - C_H_SYNC_PULSE - C_H_BACK_PORCH;
assign y = vc - C_V_SYNC_PULSE - C_V_BACK_PORCH;

assign sync[1] = hc >= C_H_SYNC_PULSE;
assign sync[0] = vc >= C_V_SYNC_PULSE;
assign active  =    (C_H_SYNC_PULSE + C_H_BACK_PORCH <= hc &&
                hc < C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME &&
                     C_V_SYNC_PULSE + C_V_BACK_PORCH <= vc &&
                vc < C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME) ? 1 : 0;

endmodule
