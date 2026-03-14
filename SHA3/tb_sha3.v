`timescale 1ns/1ns

module tb_sha3();

// ===============================================================
// 参数定义
// ===============================================================
parameter CLK_PERIOD = 10;  // 100MHz

// ===============================================================
// 测试信号
// ===============================================================
reg clk;
reg rst_n;
reg [2:0] mode;
reg in_valid;
reg in_isLast;
reg [7:0] in_byte;
wire in_ready;
reg [15:0] shake_req;
reg rd_word;
reg read_ready;
wire [63:0] out_data;
wire is_empty;
wire fifo_wr_ready;


//内部信号
wire       absorb_flag,squeeze_flag;
wire [4:0] state, next_state;
wire [4:0] round;  // 0-23
wire [15:0] bytes_out;  // 已输出字节数
wire [15:0] total_bytes;  // 总需要输出的字节数
wire [4:0]   round_words;
wire [4:0]   round_words_out;
wire         msg_done;

wire [63:0] state_reg [0:24];

wire [63:0] theta_reg [0:24];

wire  [63:0] theta_out [0:24];
wire  [63:0] rho_out [0:24];
wire  [63:0] pi_out [0:24];
wire  [63:0] chi_out [0:24];
wire  [63:0] iota_out [0:24];

wire [63:0] theta_in [0:24];

wire        pad_in_ready;
wire        pad_out_valid;
wire  [1599:0] pad_out_data_ext;
wire        pad_out_ready;

wire [63:0] fifo_din;
wire        fifo_wrreq;
wire        fifo_full;
wire        fifo_rdreq;




/***

// SHA3-224: 1152位
wire [1151:0] pad_out_224;
wire pad_valid_224;
wire pad_ready_224;
wire msg_done_224;

// SHA3-256: 1088位
wire [1087:0] pad_out_256;
wire pad_valid_256;
wire pad_ready_256;
wire msg_done_256;

// SHA3-384: 832位
wire [831:0] pad_out_384;
wire pad_valid_384;
wire pad_ready_384;
wire msg_done_384;

// SHA3-512: 576位
wire [575:0] pad_out_512;
wire pad_valid_512;
wire pad_ready_512;
wire msg_done_512;
***/
// SHAKE128: 1344位
wire [1343:0] pad_out_s128;
wire pad_valid_s128;
wire pad_ready_s128;
wire msg_done_s128;
/***
// SHAKE256: 1088位
wire [1087:0] pad_out_s256;
wire pad_valid_s256;
wire pad_ready_s256;
wire msg_done_s256;
***/
// ===============================================================
// 从DUT内部信号连接到测试平台信号
// ===============================================================

// 控制标志信号
assign absorb_flag     = dut.absorb_flag;
assign squeeze_flag    = dut.squeeze_flag;
assign msg_done        = dut.msg_done;

// 状态和计数器
assign state           = dut.state;
assign next_state      = dut.next_state;
assign round           = dut.round;
assign bytes_out       = dut.bytes_out;
assign total_bytes     = dut.total_bytes;
assign round_words     = dut.round_words;
assign round_words_out = dut.round_words_out;

// 状态寄存器数组
assign state_reg[0]  = dut.state_reg[0];
assign state_reg[1]  = dut.state_reg[1];
assign state_reg[2]  = dut.state_reg[2];
assign state_reg[3]  = dut.state_reg[3];
assign state_reg[4]  = dut.state_reg[4];
assign state_reg[5]  = dut.state_reg[5];
assign state_reg[6]  = dut.state_reg[6];
assign state_reg[7]  = dut.state_reg[7];
assign state_reg[8]  = dut.state_reg[8];
assign state_reg[9]  = dut.state_reg[9];
assign state_reg[10] = dut.state_reg[10];
assign state_reg[11] = dut.state_reg[11];
assign state_reg[12] = dut.state_reg[12];
assign state_reg[13] = dut.state_reg[13];
assign state_reg[14] = dut.state_reg[14];
assign state_reg[15] = dut.state_reg[15];
assign state_reg[16] = dut.state_reg[16];
assign state_reg[17] = dut.state_reg[17];
assign state_reg[18] = dut.state_reg[18];
assign state_reg[19] = dut.state_reg[19];
assign state_reg[20] = dut.state_reg[20];
assign state_reg[21] = dut.state_reg[21];
assign state_reg[22] = dut.state_reg[22];
assign state_reg[23] = dut.state_reg[23];
assign state_reg[24] = dut.state_reg[24];

// Theta寄存器数组
assign theta_reg[0]  = dut.theta_reg[0];
assign theta_reg[1]  = dut.theta_reg[1];
assign theta_reg[2]  = dut.theta_reg[2];
assign theta_reg[3]  = dut.theta_reg[3];
assign theta_reg[4]  = dut.theta_reg[4];
assign theta_reg[5]  = dut.theta_reg[5];
assign theta_reg[6]  = dut.theta_reg[6];
assign theta_reg[7]  = dut.theta_reg[7];
assign theta_reg[8]  = dut.theta_reg[8];
assign theta_reg[9]  = dut.theta_reg[9];
assign theta_reg[10] = dut.theta_reg[10];
assign theta_reg[11] = dut.theta_reg[11];
assign theta_reg[12] = dut.theta_reg[12];
assign theta_reg[13] = dut.theta_reg[13];
assign theta_reg[14] = dut.theta_reg[14];
assign theta_reg[15] = dut.theta_reg[15];
assign theta_reg[16] = dut.theta_reg[16];
assign theta_reg[17] = dut.theta_reg[17];
assign theta_reg[18] = dut.theta_reg[18];
assign theta_reg[19] = dut.theta_reg[19];
assign theta_reg[20] = dut.theta_reg[20];
assign theta_reg[21] = dut.theta_reg[21];
assign theta_reg[22] = dut.theta_reg[22];
assign theta_reg[23] = dut.theta_reg[23];
assign theta_reg[24] = dut.theta_reg[24];

// Theta输入数组
assign theta_in[0]  = dut.theta_in[0];
assign theta_in[1]  = dut.theta_in[1];
assign theta_in[2]  = dut.theta_in[2];
assign theta_in[3]  = dut.theta_in[3];
assign theta_in[4]  = dut.theta_in[4];
assign theta_in[5]  = dut.theta_in[5];
assign theta_in[6]  = dut.theta_in[6];
assign theta_in[7]  = dut.theta_in[7];
assign theta_in[8]  = dut.theta_in[8];
assign theta_in[9]  = dut.theta_in[9];
assign theta_in[10] = dut.theta_in[10];
assign theta_in[11] = dut.theta_in[11];
assign theta_in[12] = dut.theta_in[12];
assign theta_in[13] = dut.theta_in[13];
assign theta_in[14] = dut.theta_in[14];
assign theta_in[15] = dut.theta_in[15];
assign theta_in[16] = dut.theta_in[16];
assign theta_in[17] = dut.theta_in[17];
assign theta_in[18] = dut.theta_in[18];
assign theta_in[19] = dut.theta_in[19];
assign theta_in[20] = dut.theta_in[20];
assign theta_in[21] = dut.theta_in[21];
assign theta_in[22] = dut.theta_in[22];
assign theta_in[23] = dut.theta_in[23];
assign theta_in[24] = dut.theta_in[24];

// Theta输出
assign theta_out[0]  = dut.u_theta.out_data_0;
assign theta_out[1]  = dut.u_theta.out_data_1;
assign theta_out[2]  = dut.u_theta.out_data_2;
assign theta_out[3]  = dut.u_theta.out_data_3;
assign theta_out[4]  = dut.u_theta.out_data_4;
assign theta_out[5]  = dut.u_theta.out_data_5;
assign theta_out[6]  = dut.u_theta.out_data_6;
assign theta_out[7]  = dut.u_theta.out_data_7;
assign theta_out[8]  = dut.u_theta.out_data_8;
assign theta_out[9]  = dut.u_theta.out_data_9;
assign theta_out[10] = dut.u_theta.out_data_10;
assign theta_out[11] = dut.u_theta.out_data_11;
assign theta_out[12] = dut.u_theta.out_data_12;
assign theta_out[13] = dut.u_theta.out_data_13;
assign theta_out[14] = dut.u_theta.out_data_14;
assign theta_out[15] = dut.u_theta.out_data_15;
assign theta_out[16] = dut.u_theta.out_data_16;
assign theta_out[17] = dut.u_theta.out_data_17;
assign theta_out[18] = dut.u_theta.out_data_18;
assign theta_out[19] = dut.u_theta.out_data_19;
assign theta_out[20] = dut.u_theta.out_data_20;
assign theta_out[21] = dut.u_theta.out_data_21;
assign theta_out[22] = dut.u_theta.out_data_22;
assign theta_out[23] = dut.u_theta.out_data_23;
assign theta_out[24] = dut.u_theta.out_data_24;

// Rho输出
assign rho_out[0]  = dut.u_rho.out_data_0;
assign rho_out[1]  = dut.u_rho.out_data_1;
assign rho_out[2]  = dut.u_rho.out_data_2;
assign rho_out[3]  = dut.u_rho.out_data_3;
assign rho_out[4]  = dut.u_rho.out_data_4;
assign rho_out[5]  = dut.u_rho.out_data_5;
assign rho_out[6]  = dut.u_rho.out_data_6;
assign rho_out[7]  = dut.u_rho.out_data_7;
assign rho_out[8]  = dut.u_rho.out_data_8;
assign rho_out[9]  = dut.u_rho.out_data_9;
assign rho_out[10] = dut.u_rho.out_data_10;
assign rho_out[11] = dut.u_rho.out_data_11;
assign rho_out[12] = dut.u_rho.out_data_12;
assign rho_out[13] = dut.u_rho.out_data_13;
assign rho_out[14] = dut.u_rho.out_data_14;
assign rho_out[15] = dut.u_rho.out_data_15;
assign rho_out[16] = dut.u_rho.out_data_16;
assign rho_out[17] = dut.u_rho.out_data_17;
assign rho_out[18] = dut.u_rho.out_data_18;
assign rho_out[19] = dut.u_rho.out_data_19;
assign rho_out[20] = dut.u_rho.out_data_20;
assign rho_out[21] = dut.u_rho.out_data_21;
assign rho_out[22] = dut.u_rho.out_data_22;
assign rho_out[23] = dut.u_rho.out_data_23;
assign rho_out[24] = dut.u_rho.out_data_24;

// Pi输出
assign pi_out[0]  = dut.u_pi.out_data_0;
assign pi_out[1]  = dut.u_pi.out_data_1;
assign pi_out[2]  = dut.u_pi.out_data_2;
assign pi_out[3]  = dut.u_pi.out_data_3;
assign pi_out[4]  = dut.u_pi.out_data_4;
assign pi_out[5]  = dut.u_pi.out_data_5;
assign pi_out[6]  = dut.u_pi.out_data_6;
assign pi_out[7]  = dut.u_pi.out_data_7;
assign pi_out[8]  = dut.u_pi.out_data_8;
assign pi_out[9]  = dut.u_pi.out_data_9;
assign pi_out[10] = dut.u_pi.out_data_10;
assign pi_out[11] = dut.u_pi.out_data_11;
assign pi_out[12] = dut.u_pi.out_data_12;
assign pi_out[13] = dut.u_pi.out_data_13;
assign pi_out[14] = dut.u_pi.out_data_14;
assign pi_out[15] = dut.u_pi.out_data_15;
assign pi_out[16] = dut.u_pi.out_data_16;
assign pi_out[17] = dut.u_pi.out_data_17;
assign pi_out[18] = dut.u_pi.out_data_18;
assign pi_out[19] = dut.u_pi.out_data_19;
assign pi_out[20] = dut.u_pi.out_data_20;
assign pi_out[21] = dut.u_pi.out_data_21;
assign pi_out[22] = dut.u_pi.out_data_22;
assign pi_out[23] = dut.u_pi.out_data_23;
assign pi_out[24] = dut.u_pi.out_data_24;

// Chi输出
assign chi_out[0]  = dut.u_chi.out0;
assign chi_out[1]  = dut.u_chi.out1;
assign chi_out[2]  = dut.u_chi.out2;
assign chi_out[3]  = dut.u_chi.out3;
assign chi_out[4]  = dut.u_chi.out4;
assign chi_out[5]  = dut.u_chi.out5;
assign chi_out[6]  = dut.u_chi.out6;
assign chi_out[7]  = dut.u_chi.out7;
assign chi_out[8]  = dut.u_chi.out8;
assign chi_out[9]  = dut.u_chi.out9;
assign chi_out[10] = dut.u_chi.out10;
assign chi_out[11] = dut.u_chi.out11;
assign chi_out[12] = dut.u_chi.out12;
assign chi_out[13] = dut.u_chi.out13;
assign chi_out[14] = dut.u_chi.out14;
assign chi_out[15] = dut.u_chi.out15;
assign chi_out[16] = dut.u_chi.out16;
assign chi_out[17] = dut.u_chi.out17;
assign chi_out[18] = dut.u_chi.out18;
assign chi_out[19] = dut.u_chi.out19;
assign chi_out[20] = dut.u_chi.out20;
assign chi_out[21] = dut.u_chi.out21;
assign chi_out[22] = dut.u_chi.out22;
assign chi_out[23] = dut.u_chi.out23;
assign chi_out[24] = dut.u_chi.out24;


assign iota_out[0] = dut.u_iota.out_data_0;
assign iota_out[1] = dut.iota_out[1];
assign iota_out[2] = dut.iota_out[2];
assign iota_out[3] = dut.iota_out[3];
assign iota_out[4] = dut.iota_out[4];
assign iota_out[5] = dut.iota_out[5];
assign iota_out[6] = dut.iota_out[6];
assign iota_out[7] = dut.iota_out[7];
assign iota_out[8] = dut.iota_out[8];
assign iota_out[9] = dut.iota_out[9];
assign iota_out[10] = dut.iota_out[10];
assign iota_out[11] = dut.iota_out[11];
assign iota_out[12] = dut.iota_out[12];
assign iota_out[13] = dut.iota_out[13];
assign iota_out[14] = dut.iota_out[14];
assign iota_out[15] = dut.iota_out[15];
assign iota_out[16] = dut.iota_out[16];
assign iota_out[17] = dut.iota_out[17];
assign iota_out[18] = dut.iota_out[18];
assign iota_out[19] = dut.iota_out[19];
assign iota_out[20] = dut.iota_out[20];
assign iota_out[21] = dut.iota_out[21];
assign iota_out[22] = dut.iota_out[22];
assign iota_out[23] = dut.iota_out[23];
assign iota_out[24] = dut.iota_out[24];

// Padding接口信号
assign pad_in_ready     = dut.pad_in_ready;
assign pad_out_valid    = dut.pad_out_valid;
assign pad_out_data_ext = dut.pad_out_data_ext;
assign pad_out_ready    = dut.pad_out_ready;

// FIFO信号
assign fifo_din   = dut.fifo_din;
assign fifo_wrreq = dut.fifo_wrreq;
assign fifo_full  = dut.fifo_full;
assign fifo_rdreq = dut.fifo_rdreq;

// 各模式padding模块的msg_done信号
//assign msg_done_224 = dut.u_pad_224.msg_done;
//assign msg_done_256 = dut.u_pad_256.msg_done;
//assign msg_done_384 = dut.u_pad_384.msg_done;
//assign msg_done_512 = dut.u_pad_512.msg_done;
assign msg_done_s128 = dut.u_pad_s128.msg_done;
//assign msg_done_s256 = dut.u_pad_s256.msg_done;
//
//// 各模式padding模块的输出有效信号
//assign pad_valid_224 = dut.u_pad_224.out_valid;
//assign pad_valid_256 = dut.u_pad_256.out_valid;
//assign pad_valid_384 = dut.u_pad_384.out_valid;
//assign pad_valid_512 = dut.u_pad_512.out_valid;
assign pad_valid_s128 = dut.u_pad_s128.out_valid;
//assign pad_valid_s256 = dut.u_pad_s256.out_valid;
//
//// 各模式padding模块的就绪信号
//assign pad_ready_224 = dut.u_pad_224.in_ready;
//assign pad_ready_256 = dut.u_pad_256.in_ready;
//assign pad_ready_384 = dut.u_pad_384.in_ready;
//assign pad_ready_512 = dut.u_pad_512.in_ready;
assign pad_ready_s128 = dut.u_pad_s128.in_ready;
//assign pad_ready_s256 = dut.u_pad_s256.in_ready;
//
//// 各模式padding模块的输出数据
//assign pad_out_224 = dut.u_pad_224.out;
//assign pad_out_256 = dut.u_pad_256.out;
//assign pad_out_384 = dut.u_pad_384.out;
//assign pad_out_512 = dut.u_pad_512.out;
assign pad_out_s128 = dut.u_pad_s128.out;
//assign pad_out_s256 = dut.u_pad_s256.out;

// 测试数据
reg [7:0] test_message [0:2];  // "abc"
integer i;
reg [63:0] read_data [0:3];    // 存储读取的4个字

// ===============================================================
// 时钟生成
// ===============================================================
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// ===============================================================
// DUT实例化
// ===============================================================
sha3 dut (
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .in_valid(in_valid),
    .in_isLast(in_isLast),
    .in_byte(in_byte),
    .in_ready(in_ready),
    .shake_req(shake_req),
    .rd_word(rd_word),
    .read_ready(read_ready),
    .out_data(out_data),
    .is_empty(is_empty),
    .fifo_wr_ready(fifo_wr_ready)
);
initial begin
    // 变量声明必须在initial块的最开始
    
    
    // 初始化
    rst_n = 0;
    in_byte = 8'h00;
    in_valid = 0;
    in_isLast = 0;
    mode = 3'd4;
    shake_req = 16'd72;
    
    // 复位
    #(CLK_PERIOD*2);
    rst_n = 1;
    #(CLK_PERIOD*2);
    
    // 发送1600bit数据 (200字节，模式为11000101重复)
    @(posedge clk);
    #1;
    
    for (i = 0; i < 200; i = i + 1) begin
        if(!in_isLast)
            in_valid=0;
        wait(in_ready);
        in_byte = 8'b11000101;  // 0xC5
        in_valid = 1;
        if (i == 199) begin
            in_isLast = 1;  // 最后一个字节设置in_isLast
        end else begin
            in_isLast = 0;
        end
        @(posedge clk);
        #1;
    end
    
    // 结束输入
    in_valid = 0;
    in_isLast = 0;
    
    // 等待msg_done，表示输入处理完成
    wait(msg_done);
    #(CLK_PERIOD*10);
    
    $finish;
end

endmodule