`timescale 1ns/1ns

module tb_divid();

// 参数定义
parameter width = 128;
parameter CLK_PERIOD = 20;
localparam  cnt_width   =$clog2(width);


// 信号定义

reg                     clk;
reg                     rst_n;
reg                        en;
reg     [width-1:0]     dividend;
reg     [width-1:0]     divisor;
wire    [width-1:0]     quotient;
wire    [width-1:0]     reminder;
wire                    ready;



wire    [width-1:0]         dividend_reg;
wire    [width-1:0]         divisor_reg;
wire    [2:0]               state,next_state;
wire    [cnt_width-1:0]     width_dividend,width_divisor;
wire                        shift_ready;
assign state=u.state;
assign dividend_reg=u.dividend_reg;
assign divisor_reg=u.divisor_reg;
assign width_dividend=u.width_dividend;
assign width_divisor=u.width_divisor;
assign shift_ready=u.shift_ready;
// 实例化被测试模块
divid
#(
    .width(width)
)
u
(   .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .reminder(reminder),
    .ready(ready)
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
    
    dividend=128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
    divisor=128'h01234567012345670123456701234567;
    #1000;

    
    // 结束仿真
    #320;
    $finish;
end

endmodule