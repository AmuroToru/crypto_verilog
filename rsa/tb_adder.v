`timescale 1ns/1ns
module tb_adder();

parameter   width   =   32;
parameter CLK_PERIOD = 20;
localparam  CNT_WIDTH   =   $clog2(width/16+1'd1);

reg                     clk     ;
reg                     rst_n   ;
reg                     en      ;
reg                     sub     ;
reg     [width-1:0]     in_a    ;
reg     [width-1:0]     in_b    ;
wire    [width:0]       res     ;
wire                    ready   ;

wire    [width-1:0]         a_reg, b_reg;
wire                        carry_in;
wire                        subtract_reg;
wire    [1:0]               state;
wire    [CNT_WIDTH-1:0]     block_cnt;
wire    [1:0]               block_sum;


assign  a_reg=u.a_reg;
assign  b_reg=u.b_reg;
assign  carry_in=u.carry_in;
assign  subtract_reg=u.subtract_reg;
assign  state=u.state;
assign  block_cnt=u.block_cnt;
assign  block_sum=u.block_sum;




adder
#(
    .width(width)
)
u
(
    .clk    (clk)  ,
    .rst_n  (rst_n)  ,
    .en     (en)  ,
    .sub    (sub)  ,
    .in_a   (in_a)  ,
    .in_b   (in_b)  ,
    .res    (res)  ,
    .ready  (ready)  
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
    sub =   1'b0;

    
    // 等待20ns后释放复位
    #20;
    rst_n = 1'b1; 
    en    =1'b1;    
    sub     =   1'b0;
    
    in_a=32'h01234567;
    in_b=32'h89abcdef;
    #20;
    in_a=32'h0;
    in_b=32'h0;
    en=0;
#1000
    $finish;
end
endmodule
