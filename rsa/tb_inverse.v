`timescale 1ns/1ns

module tb_inverse();

// 参数定义
parameter width = 33;
parameter CLK_PERIOD = 20;

reg                   clk;
reg                   rst_n;
reg                   en;
reg     [width-1:0]   a;
reg     [width-1:0]   n;
wire                  ready;
wire    [width-1:0]   a_inv;

wire     [width-1:0]     a_reg;
wire     [width-1:0]     n_reg;
wire     [width-1:0]     a_new;
wire     [width-1:0]     n_new;
wire     [width:0]       A;
wire     [width:0]       C;
wire     [2:0]           state,next_state;

assign a_reg=u.a_reg;
assign n_reg=u.n_reg;
assign a_new=u.a_new;
assign n_new=u.n_new;
assign A=u.A;
assign C=u.C;
assign state=u.state;
assign next_state=next_state;

// 实例化被测试模块
inverse
#(
    .width(width)
)
u
(   
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .a(a),
    .n(n),
    .ready(ready),
    .a_inv(a_inv)
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
    en    = 1'b0;

    
    // 等待20ns后释放复位
    #20;
    rst_n = 1'b1; 
    en    =1'b1;    
    
    n = 33'h1_0000_0000;
    a=32'hFFFFFFFB;
    #1000;

    
    // 结束仿真
    #320;
    $finish;
end

endmodule