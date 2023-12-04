`timescale 1ns / 1ps

module get_background_info(
    input clk,
    input dis_res,
    input [10:0] x2,
    input [10:0] y,
    input [9:0] delta,
    output [15:0] color
);

reg [15:0] readpos;
wire [11:0] x;
assign x = (x2 + delta) % 10'd230;
always @(posedge clk) begin
    if(dis_res) begin
        if(y<10'd327) readpos <= x;
        else if (y>10'd510) readpos <= 16'd42320 + x;
        else readpos <= (y - 10'd327) * 10'd230 + x;
    end else begin
        if(y < 10'd297) readpos <= x;
        else readpos <= (y - 10'd297) * 10'd230 + x;
    end
end

BG_IMG BGIMG(.addra(readpos),.clka(clk),.douta(color));

endmodule
