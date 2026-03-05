`timescale 1ns/1ns
module  tb_montgomery_mod_multi();

parameter       MPWID = 256;
parameter CLK_PERIOD = 20;

reg                clk;
reg                rst_n;
reg                start;
reg    [MPWID-1:0] in_a;
reg    [MPWID-1:0] in_b;
reg    [MPWID-1:0] in_n;
reg    [MPWID-1:0] R2modN;
wire    [MPWID-1:0] res ;
wire                ready;

wire    [MPWID:0]       R;
wire    [MPWID-1:0]     R2,a,b,n,Ma,Mb;
wire                    Men;
wire    [2:0]           state,next_state;
wire    [MPWID-1:0]     Minv;
wire                    Mready; 
assign           R2         =      u.R2         ;
assign           R          =      u.R          ;
assign           a          =      u.a          ;
assign           b          =      u.b          ;
assign           n          =      u.n          ;
assign           Ma         =      u.Ma         ;
assign           Mb         =      u.Mb         ;
assign           Men        =      u.Men        ;
assign           state      =      u.state      ;
assign           next_state =      u.next_state ;
assign           Minv       =      u.Minv       ;
assign           Mready     =      u.Mready     ;

montgomery_mod_multi
#(
    .MPWID(MPWID)
)
u
(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .in_a(in_a),
    .in_b(in_b),
    .in_n(in_n),
    .R2modN(R2modN),
    .res(res),
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
    start    = 1'b0;

    
    // 等待20ns后释放复位
    #20;
    rst_n = 1'b1; 
    start    =1'b1;    
    R2modN=256'd57448972955402726528454876578424267210853927114427293053654687936952302948223;
    in_a=256'h0123456701234567012345670123456701234567012345670123456701234567;
    in_b=256'h89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef;
    in_n=256'd111079669216464751073942009743976564074175800489696573048427645366541613384429;
    #1000;


    $finish;
end
endmodule