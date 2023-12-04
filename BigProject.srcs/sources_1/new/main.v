`timescale 1ns / 1ps

module main(
input clk, input rst,
input uppersw, input midsw, input downsw,
input dis_res, input dis_mode,
input [2:0] diff_sw,
output [13:0] vga,
output [1:0] opt_state,
output [2:0] leds,
output [7:0] cho,
output [15:0] seg_num);

wire [1:0]vga_clk;
clk_wiz_0 CLK(.reset(~rst),.clk_in1(clk),.clk_out1(vga_clk[0]),.clk_out2(vga_clk[1]));

wire act1,act2;
wire [10:0] x1;
wire [10:0] y1;
wire [10:0] x2;
wire [10:0] y2;
wire [1:0] vgasync1;
wire [1:0] vgasync2;
vga_displayer #(
.C_H_SYNC_PULSE    (11'd96),
.C_H_BACK_PORCH    (11'd48),
.C_H_ACTIVE_TIME   (11'd640),
.C_H_FRONT_PORCH   (11'd16),
.C_H_LINE_PERIOD   (11'd800),

.C_V_SYNC_PULSE    (11'd2),
.C_V_BACK_PORCH    (11'd33),
.C_V_ACTIVE_TIME   (11'd480),
.C_V_FRONT_PORCH   (11'd10),
.C_V_FRAME_PERIOD  (11'd525))
VD1(vga_clk[0],rst,act1,x1,y1,vgasync1);

vga_displayer #(
.C_H_SYNC_PULSE    (11'd128),
.C_H_BACK_PORCH    (11'd88),
.C_H_ACTIVE_TIME   (11'd800),
.C_H_FRONT_PORCH   (11'd40),
.C_H_LINE_PERIOD   (11'd1056),

.C_V_SYNC_PULSE    (11'd4),
.C_V_BACK_PORCH    (11'd23),
.C_V_ACTIVE_TIME   (11'd600),
.C_V_FRONT_PORCH   (11'd1),
.C_V_FRAME_PERIOD  (11'd623))
VD2(vga_clk[1],rst,act2,x2,y2,vgasync2);

wire [10:0] x;
wire [10:0] y;
wire act,v_clk;
assign v_clk = dis_res ? vga_clk[1] : vga_clk[0];
assign x = dis_res ? x2 : x1;
assign y = dis_res ? y2 : y1;
assign act = dis_res ? act2 : act1;
assign vga[1:0] = dis_res ? vgasync2 : vgasync1;

reg [15:0] score = 0;
segment SG(clk,score,cho,seg_num);
reg [19:0] birdpos;
reg [2:0] tube_num;
assign leds = tube_num;
reg [59:0] tubepos;

wire [15:0] bird_color;
wire [1:0] is_bird;
get_bird_info GBI(v_clk,x,y,birdpos[19:10],birdpos[9:0],bird_color,is_bird);

wire [15:0] num_color;
wire is_num;
get_score_info GSI(v_clk,dis_res,x,y,score,is_num,num_color);

wire [15:0] bg_color;
reg [15:0] bg_delta;
get_background_info GBGI(v_clk,dis_res,x,y,bg_delta[15:6],bg_color);

wire [15:0] tube_color [4:0];
wire is_tube [4:0];

parameter width_of_inteval = 11'd260;
get_tube_info GTI0(v_clk,x,y,tubepos[9:0]                            ,tubepos[19:10],tube_color[0],is_tube[0]);
get_tube_info GTI1(v_clk,x,y,tubepos[9:0] + width_of_inteval         ,tubepos[29:20],tube_color[1],is_tube[1]);
get_tube_info GTI2(v_clk,x,y,tubepos[9:0] + width_of_inteval * 3'b010,tubepos[39:30],tube_color[2],is_tube[2]);
get_tube_info GTI3(v_clk,x,y,tubepos[9:0] + width_of_inteval * 3'b011,tubepos[49:40],tube_color[3],is_tube[3]);
//get_tube_info GTI4(clk,x,y,tubepos[9:0] + width_of_inteval * 3'b100,tubepos[59:50],tube_color[4],is_tube[4]);

reg [11:0] color;
assign vga[13:2] = color;
reg is_end=0;
always @(negedge v_clk) begin //Color blending
    if(~rst || downsw) is_end <= 0;
    else
    if(~act) color <= 12'h000;
    else begin
        if(is_num && num_color[15:12] > 4'd8) color <= num_color[11:0];
        else
        if(is_bird[1]&& bird_color[15:12]>4'd8) color <= bird_color[11:0];
        else
        if(tube_num >= 3'b000 && is_tube[0]&&tube_color[0][15:12]>4'd8) color <= tube_color[0][11:0];
        else
        if(tube_num >= 3'b001 && is_tube[1]&&tube_color[1][15:12]>4'd8) color <= tube_color[1][11:0];
        else
        if(tube_num >= 3'b010 && is_tube[2]&&tube_color[2][15:12]>4'd8) color <= tube_color[2][11:0];
        else
        if(tube_num >= 3'b011 && is_tube[3]&&tube_color[3][15:12]>4'd8) color <= tube_color[3][11:0];
        else color <= bg_color[11:0];
        
        if(is_bird[0] && ((tube_num >= 3'b000&&is_tube[0])||
                       (tube_num >= 3'b001&&is_tube[1])||
                       (tube_num >= 3'b010&&is_tube[2])||
                       (tube_num >= 3'b011&&is_tube[3]))) is_end <= 1;
    end
end

reg rand_clk = 0;
wire [10:0] rand_val;
rand R(rand_clk,rand_val);

reg [10:0] velocity_x;
reg [15:0] fake_tube_pos;
reg [15:0] fake_bird_pos; //fake_y
reg [10:0] velocity_y;
reg [10:0] gravity_y;
reg [10:0] tmpval;
wire g_clk;
game_clk GC(clk,g_clk);
always @(posedge clk) begin
    case (diff_sw[1:0])
        2'b00: velocity_x = 10'd0;
        2'b01: velocity_x = 10'd16;
        2'b10: velocity_x = 10'd20;
        2'b11: velocity_x = 10'd24;
    endcase
end

parameter width_of_tube = 10'd55;
parameter height_of_inteval = 10'd160;
parameter gravity = 10'd1;

reg [1:0] state;
assign opt_state = state;
parameter _init = 2'b00;
parameter _play = 2'b01;
parameter _end  = 2'b10;
reg flg;
always @(posedge g_clk) begin // bird moving
    if(~rst || downsw) begin
        fake_bird_pos = dis_res ? (10'd284<<3'b110) : (10'd224<<3'b110);
        birdpos = dis_res ? {10'd150, 10'd284} : {10'd100, 10'd224};
        flg=0;
        velocity_y = 10'd90;
        gravity_y = 0;
    end else
    if(state == _play) begin
        if( fake_bird_pos + gravity_y < velocity_y ) fake_bird_pos = 0;
        else fake_bird_pos = fake_bird_pos + gravity_y - velocity_y;
        gravity_y = gravity_y + gravity;
    end else
    if(state == _end) begin
        if(fake_bird_pos[15:6] < (dis_res ? 10'd600 : 10'd480)) fake_bird_pos = fake_bird_pos + 10'd40;
    end
    if(midsw && (~flg)) begin
        flg = 1;
        gravity_y = 0;
    end else
    if(~midsw) flg = 0;
    birdpos[9:0] = fake_bird_pos[15:6];
end

always @(posedge g_clk) begin // state fsm
    if(~rst || downsw) state <= _init;
    else if(birdpos[9:0] > (dis_res ? 10'd600 : 10'd480)) state <= _end;
    else if(is_end) state <= _end;
    else if(state == _init && midsw) state <= _play;
end

always @(posedge g_clk) begin // tube & bg moving
    if(~rst || downsw) begin
        bg_delta = 0;
        tube_num = 3'b000;
        score[7:0] = 0;
        fake_tube_pos = 0;
        tubepos = 0;
        fake_tube_pos[15:6] = (dis_res ? 10'd800 : 10'd640) + width_of_tube - 1;
        tubepos[9:0]=fake_tube_pos[15:6];
        tubepos[19:10] = dis_res ? (rand_val % (10'd600 - height_of_inteval)) : (rand_val % (10'd480 - height_of_inteval));
    end
    else begin
        if(tube_num <= 3'b011 && width_of_inteval * tube_num < (dis_res ? 12'd800 : 12'd640) + width_of_tube - tubepos[9:0]) begin
            tube_num = tube_num + 1;
            tmpval = dis_res ? (rand_val % (10'd600 - height_of_inteval)) : (rand_val % (10'd480 - height_of_inteval));
            case(tube_num)
                3'b001: tubepos[29:20] = tmpval;
                3'b010: tubepos[39:30] = tmpval;
                3'b011: tubepos[49:40] = tmpval;
                3'b100: tubepos[59:50] = tmpval;
                default:tubepos[59:50] = 0;
            endcase
        end
        bg_delta = (bg_delta + velocity_x / 2) % (8'd230<<6);
        if(state == _play) begin
            if(tubepos[9:0] == 8'd100) begin
                if(diff_sw[2:2]) begin
                    tmpval = tmpval%160;
                    if(tubepos[29:20] < tmpval)
                        tubepos[29:20] = tubepos[29:20] + tmpval;
                    else
                    if((dis_res ? 10'd800 : 10'd640) < tubepos[29:20] + tmpval + height_of_inteval)
                        tubepos[29:20] = tubepos[29:20] - tmpval;
                    else tubepos[29:20] = tubepos[29:20] + 80 - tmpval;
                end
            end
            if(fake_tube_pos[15:0] > velocity_x)
                fake_tube_pos[15:0] = fake_tube_pos[15:0] - velocity_x;
            else begin
                fake_tube_pos[15:0] = fake_tube_pos[15:0] + (width_of_inteval<<6) - velocity_x;
                if(tube_num == 3'b000) begin
                    tubepos[19:10] = tmpval;
                end else begin
                    tube_num = tube_num - 1;
                    tubepos[19:10] = tubepos[29:20];
                    tubepos[29:20] = tubepos[39:30];
                    tubepos[39:30] = tubepos[49:40];
                    tubepos[49:40] = tubepos[59:50];
                end
                score[3:0] = score[3:0] + 1;
                if(score[3:0] >= 4'b1010) begin
                    score[3:0] = 0;
                    score[7:4] = score[7:4] + 1;
                    if(score[7:4] >= 4'b1010) begin
                        score[7:4] = 0;
                    end
                end
                score[15:8] = (score[15:8] > score[7:0]) ? score[15:8] : score[7:0];
            end
            tubepos[9:0]=fake_tube_pos[15:6];
        end
    end
end

always @(posedge clk) begin
    rand_clk = ~rand_clk;
end

endmodule
