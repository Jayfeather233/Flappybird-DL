`timescale 1ns / 1ps

module segment(input clk, input [15:0] number, output reg [7:0] ST, output reg [15:0] NUM);
parameter _0 = 8'h3f;
parameter _1 = 8'h06;
parameter _2 = 8'h5b;
parameter _3 = 8'h4f;
parameter _4 = 8'h66;
parameter _5 = 8'h6d;
parameter _6 = 8'h7d;
parameter _7 = 8'h07;
parameter _8 = 8'h7f;
parameter _9 = 8'h6f;
parameter _E = 8'h79;//Error

reg [17:0] cnt = 0;

always @(posedge clk) cnt = cnt + 1;

always @* begin
    if(cnt[17]==1) begin
        ST = 8'b00101000;
        case(number[15:12])
            4'h0: NUM[15:8] <= _0;
            4'h1: NUM[15:8] <= _1;
            4'h2: NUM[15:8] <= _2;
            4'h3: NUM[15:8] <= _3;
            4'h4: NUM[15:8] <= _4;
            4'h5: NUM[15:8] <= _5;
            4'h6: NUM[15:8] <= _6;
            4'h7: NUM[15:8] <= _7;
            4'h8: NUM[15:8] <= _8;
            4'h9: NUM[15:8] <= _9;
            default: NUM[15:8] <= _E;
        endcase
        case(number[7:4])
            4'h0: NUM[7:0] <= _0;
            4'h1: NUM[7:0] <= _1;
            4'h2: NUM[7:0] <= _2;
            4'h3: NUM[7:0] <= _3;
            4'h4: NUM[7:0] <= _4;
            4'h5: NUM[7:0] <= _5;
            4'h6: NUM[7:0] <= _6;
            4'h7: NUM[7:0] <= _7;
            4'h8: NUM[7:0] <= _8;
            4'h9: NUM[7:0] <= _9;
            default: NUM[7:0] <= _E;
        endcase
    end else begin
        ST = 8'b00010100;
        case(number[11:8])
            4'h0: NUM[15:8] <= _0;
            4'h1: NUM[15:8] <= _1;
            4'h2: NUM[15:8] <= _2;
            4'h3: NUM[15:8] <= _3;
            4'h4: NUM[15:8] <= _4;
            4'h5: NUM[15:8] <= _5;
            4'h6: NUM[15:8] <= _6;
            4'h7: NUM[15:8] <= _7;
            4'h8: NUM[15:8] <= _8;
            4'h9: NUM[15:8] <= _9;
            default: NUM[15:8] <= _E;
        endcase
        case(number[3:0])
            4'h0: NUM[7:0] <= _0;
            4'h1: NUM[7:0] <= _1;
            4'h2: NUM[7:0] <= _2;
            4'h3: NUM[7:0] <= _3;
            4'h4: NUM[7:0] <= _4;
            4'h5: NUM[7:0] <= _5;
            4'h6: NUM[7:0] <= _6;
            4'h7: NUM[7:0] <= _7;
            4'h8: NUM[7:0] <= _8;
            4'h9: NUM[7:0] <= _9;
            default: NUM[7:0] <= _E;
        endcase
    end
end


endmodule
