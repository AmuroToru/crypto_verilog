`timescale 1ns/1ns
module tb_RSA();

parameter   width   =   256;
parameter CLK_PERIOD = 20;
localparam      in_round    =        $clog2(width/8+1);

// ===== 输入输出信号 =====
reg                 clk;
reg                 rst_n;
reg                 en;
reg     [7:0]       in_N;
reg     [7:0]       in_key;
reg     [7:0]       in_data;
wire    [7:0]       out_data;
wire                ready;
wire                out_start;

// ===== RSA 模块内部信号观察 =====
wire    [width-1:0]         mod_n, data, key, mide_value, R2modN, mod_a, mod_b;
wire    [2:0]               state, next_state;
wire    [in_round:0]        round;
wire                         mod_start, divid_en, c;
wire                         mod_ready, divid_ready;
wire    [width-1:0]         R2modN_wire, mod_res;
wire    [width:0]           R;

// ===== 实例化 RSA 模块 =====
RSA #(.width(width)) u (
    .clk(clk), .rst_n(rst_n), .en(en),
    .in_N(in_N), .in_key(in_key), .in_data(in_data),
    .out_data(out_data), .ready(ready), .out_start(out_start)
);

// ===== 观察内部信号 =====
assign mod_n      = u.mod_n;
assign data       = u.data;
assign key        = u.key;
assign mide_value = u.mide_value;
assign R2modN     = u.R2modN;
assign mod_a      = u.mod_a;
assign mod_b      = u.mod_b;
assign state      = u.state;
assign next_state = u.next_state;
assign round      = u.round;
assign mod_start  = u.mod_start;
assign divid_en   = u.divid_en;
assign c          = u.c;
assign mod_ready  = u.mod_ready;
assign divid_ready= u.divid_ready;
assign R2modN_wire= u.R2modN_wire;
assign mod_res    = u.mod_res;
assign R          = u.R;

// ===== 时钟生成 =====
initial clk = 0;
always #(CLK_PERIOD/2) clk = ~clk;

// ===== 测试数据 =====
localparam N_VAL = 256'd51338974303929906378440101756985967100188452902583494209170611372982847998869;
localparam E_VAL = 256'd11179136139274132867;
localparam D_VAL = 256'd13882150891795195893273302265575302512495011909925093555329962074180241855347;
localparam M_VAL = 256'd171164890437666540476925010131443090833;
localparam ENC_VAL = 256'd45047290231758182114479141222664811456078789365407245513250457988444904265545;

integer i;
reg [width-1:0] encrypted_data, decrypted_data;

// ===== 测试主程序 =====
initial begin
    // 初始化
    rst_n = 0; en = 0;
    in_N = 0; in_key = 0; in_data = 0;
    
    #20 rst_n = 1;

    
    // ===== 加密 =====
    // en 只在第一个字节输入时拉高
    en = 1;
    #20
    // 输入 N、key、data 同时并行输入，每个时钟周期三个信号同时赋值
    for(i=width/8-1; i>=0; i=i-1) begin
        in_N   = N_VAL[i*8 +: 8];
        in_key = E_VAL[i*8 +: 8];    // 加密用 e
        in_data = M_VAL[i*8 +: 8];
        @(posedge clk);
        if(i == 0) en = 0;  // 第一个字节后拉低 en
    end
    
    // 等待加密完成
    wait(ready);
    wait(out_start);
    

      
    #200 $finish;
end

endmodule