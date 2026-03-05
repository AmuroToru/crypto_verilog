`timescale 1ns/1ns
module tb_radix2_montgomery_redc();

parameter   width   =  256;
parameter CLK_PERIOD = 20;

localparam cnt_width   = $clog2(width+1'd1);

reg                clk;
reg                rst_n;
reg                en;
reg    [width-1:0] in_a;
reg    [width-1:0] in_b;
reg    [width-1:0] in_n;
wire   [width-1:0] abRinv;
wire               ready;


            
wire    [2:0]               state, next_state;
wire                        add_en, sub;
wire    [width-1:0]         a, b, n, add2;
wire    [width+1:0]           T;
wire    [cnt_width-1:0]     cnt;  
wire    [width:0]           T_wire;
wire                        add_ready,cnt_shift,cnt_shift1;

assign state=u.state;
assign  next_state=u.next_state;
assign  add_en=u.add_en;
assign  sub=u.sub;
assign  a=u.a;
assign  b=u.b;
assign  add2=u.add2;
assign  T=u.T;
assign  cnt=u.cnt;
assign  T_wire=u.T_wire;
assign  add_ready=u.add_ready;
assign  n=u.n;
assign  cnt_shift=u.cnt_shift;
assign  cnt_shift1=u.cnt_shift1;

 radix2_montgomery_redc
#(
    .width(width)
)
u
(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .in_a(in_a),
    .in_b(in_b),
    .in_n(in_n),
    .abRinv(abRinv),
    .ready(ready)
);
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end


// 初始化
initial begin
    // 初始值设置
    rst_n = 1'b0;           
    en    = 1'b0;

    
    // 等待20ns后释放复位
    #20;
    rst_n = 1'b1; 
    en    =1'b1;    
    
    in_a=256'h89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef;
    in_b=256'd57448972955402726528454876578424267210853927114427293053654687936952302948223;
    in_n=256'd111079669216464751073942009743976564074175800489696573048427645366541613384429;
    #20
    en =1'b0;
    #1000;


    $finish;
end
endmodule