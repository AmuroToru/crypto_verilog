`timescale 1ns/1ns

module tb_multi_without_add_function();

// 参数定义
parameter MPWID = 256;
parameter CLK_PERIOD = 20;
localparam cnt_width   =$clog2(MPWID);

// 信号定义
reg                     clk;
reg                     rst_n;
reg                     start;
reg     [MPWID-1:0]     in_a;
reg     [MPWID-1:0]     in_b;
wire    [MPWID*2-1:0]   mul;
wire                    ready;


wire     [1:0]           state,next_state;
wire     [MPWID*2-1:0]  res;//保存最终结果
wire                     c,add_en;//进位寄存器
wire                     ready_reg;    
wire     [cnt_width-1:0]   cnt;//计数器，计算位移次数
wire     [MPWID-1:0]     mul_a;
wire     [MPWID:0]       add_res_reg;
wire                     cnt_mul;//cnt=0,加法，cnt=1，右移
wire                    sub,add_ready;
wire    [MPWID:0]       add_res;

assign  state=u.state;
assign  next_state=u.next_state;
assign  c=u.c;
assign  add_en=u.add_en;
assign  ready_reg=u.ready_reg;
assign  cnt=u.cnt;
assign  mul_a=u.mul_a;
assign  add_res_reg=u.add_res_reg;
assign  cnt_mul=u.cnt_mul;
assign  sub=u.sub;
assign  add_ready=u.add_ready;
assign  add_res=u.add_res;
assign  res=u.res;

// 实例化被测试模块
multi_without_add_function #(
    .MPWID      (MPWID)
) u (
    .clk        (clk),
    .rst_n      (rst_n),
    .start      (start),
    .in_a       (in_a),
    .in_b       (in_b),
    .mul        (mul),
    .ready      (ready)
);

// 时钟生成
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end


// 初始化
initial begin
    // 初始值设置
    rst_n = 1'b0;           
    start = 1'b0;

    
    // 等待20ns后释放复位
    #20;
    rst_n = 1'b1; 
    start=1'b1;    
    
    in_a=256'h0123456701234567012345670123456701234567012345670123456701234567;
    in_b=256'h89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef;

    #1000;
    // 结束仿真
    #320;
    $finish;
end

endmodule