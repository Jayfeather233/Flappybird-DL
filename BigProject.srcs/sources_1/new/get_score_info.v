`timescale 1ns / 1ps

module get_score_info(
    input clk,
    input dis_res,
    input [10:0] x2,
    input [10:0] y2,
    input [15:0] score,
    output is_num,
    output [15:0] color
);
wire [10:0] x;
wire [10:0] y;
assign x = x2 / 5;
assign y = y2 / 5;

wire [10:0] st;
wire [10:0] num_pos;
assign st = x - ((dis_res ? 10'd80 : 10'd62) - 10'd14);

assign is_num = ((x + 10'd14 >= (dis_res ? 10'd80 : 10'd62)) && (x < (dis_res ? 10'd80 : 10'd62) + 10'd14) &&
                 (y < 5'd9));

wire [3:0] sc [3:0];
assign sc[0] = score [15:12];
assign sc[1] = score [11:8];
assign sc[2] = score [7:4];
assign sc[3] = score [3:0];


assign num_pos = is_num ? ((y * 7'd70) + sc[st / 7] * 7'd7 + st % 7) : 0;

blk_mem_gen_0 NUMIMG(.addra(num_pos),.clka(clk),.douta(color));

endmodule
