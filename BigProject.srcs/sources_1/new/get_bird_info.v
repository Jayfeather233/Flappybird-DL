`timescale 1ns / 1ps

module get_bird_info(
    input clk,
    input [10:0] x2,
    input [10:0] y2,
    input [9:0] birdpos_x,
    input [9:0] birdpos_y,
    output [15:0] color,
    output [1:0] isbird
);
wire [11:0] x;
wire [11:0] y;
assign x = {1'b0, x2};
assign y = {1'b0, y2};

wire [11:0] readpos;

assign isbird[1] = (x >= birdpos_x && x < birdpos_x + 10'd60 &&
                    y >= birdpos_y && y < birdpos_y + 10'd50) ? 1'b1 : 1'b0;
assign isbird[0] = (x >= birdpos_x + 5 && x < birdpos_x + 10'd55 &&
                    y >= birdpos_y + 5 && y < birdpos_y + 10'd45) ? 1'b1 : 1'b0;

assign readpos = (y2 - birdpos_y) * 6'd60 + (x2 - birdpos_x);


BIRD_IMG BIRDIMG(.addra(readpos),.clka(clk),.douta(color));

endmodule
