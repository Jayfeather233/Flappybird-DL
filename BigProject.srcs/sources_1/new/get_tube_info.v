`timescale 1ns / 1ps

module get_tube_info(
    input clk,
    input [11:0] x,
    input [11:0] y,
    input [10:0] tubepos_x,
    input [10:0] tubepos_y,
    output reg [15:0] color,
    output istube
);

parameter width_of_tube = 10'd55;
parameter height_of_inteval = 10'd160;
parameter width_of_inteval = 10'd260;

wire [9:0] cct;
wire [5:0] readpos;
wire [15:0] color1;
wire [15:0] color2;

assign istube = (x + width_of_tube >= tubepos_x && x < tubepos_x &&
                 (y <= tubepos_y || y > tubepos_y + height_of_inteval)) ? 1'b1 : 1'b0;

assign cct = tubepos_x - x - 1;
assign readpos = cct[5:0];

always @(posedge clk) begin
    if((tubepos_y < y + 2'b10 && y <= tubepos_y) ||
       (tubepos_y + height_of_inteval <= y && y < tubepos_y + height_of_inteval + 2'b10)) begin
        color <= 16'hf545; //outline1
    end else
    if((tubepos_y < y + 5'd27 && y + 5'd25 <= tubepos_y) ||
       (tubepos_y + height_of_inteval + 5'd27 <= y && y < tubepos_y + height_of_inteval + 5'd29)) begin
        color <= 16'hf545; //outlin2
    end else
    if(y + 5'd27 <= tubepos_y || tubepos_y + height_of_inteval + 5'd29 <= y) begin
        color <= color2;
    end else color <= color1;
end    


TUBE_TOP TUBEIMG_TOP(.addra(readpos),.clka(clk),.douta(color1));
TUBE_BODY TUBEIMG_BODY(.addra(readpos),.clka(clk),.douta(color2));

endmodule
