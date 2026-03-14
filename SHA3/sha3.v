module sha3
(
    // 时钟和复位
    input clk,
    input rst_n,
    
    // 模式选择
    input [2:0] mode,  // 000:SHA3-224, 001:SHA3-256, 010:SHA3-384, 011:SHA3-512, 
                        // 100:SHAKE128, 101:SHAKE256
    
    // 数据输入接口
    input in_valid,
    input in_isLast,
    input [7:0] in_byte,  // 字节输入
    output in_ready,
    
    // SHAKE模式输出请求
    input [15:0] shake_req,             // 请求输出字节长度
    //请求输出信号（连接fifo的rd信号）
    input        rd_word,
    //外部读出全部输出
    input       read_ready,
    // 输出接口
    output [63:0] out_data,
    output is_empty,
    output reg fifo_wr_ready
);

// ===============================================================
// 参数定义
// ===============================================================
localparam IDLE        = 5'd0;
localparam ABSORB      = 5'd1;//等待pad模块输出&&xor
localparam THETA       = 5'd2;
localparam IOTA        = 5'd3;
localparam ROUND_      = 5'd4;
localparam SQUEEZE     = 5'd5;
localparam DONE        = 5'd6;



// FIFO深度
localparam FIFO_DEPTH = 8;  

// 各模式的输出长度(字)
localparam [3:0] WORDS_224 = 4'd4;  // 224/64 = 4
localparam [3:0] WORDS_256 = 4'd4;  // 256/64 = 4
localparam [3:0] WORDS_384 = 4'd6;  // 384/64 = 6
localparam [3:0] WORDS_512 = 4'd8;  // 512/64 = 8

// ===============================================================
// 内部信号
// ===============================================================
integer j;
reg       absorb_flag,squeeze_flag;
reg [4:0] state, next_state;
reg [4:0] round;  // 0-23
reg [15:0] bytes_out;  // 已输出字节数
reg [15:0] total_bytes;  // 总需要输出的字节数
reg [4:0]   round_words;
reg [4:0]   round_words_out;
wire        msg_done;
reg flag;

// 状态寄存器 (25个64位字)
reg [63:0] state_reg [0:24];

// Theta输出寄存器
reg [63:0] theta_reg [0:24];

// 组合逻辑连线
wire [63:0] theta_out [0:24];
wire [63:0] rho_out [0:24];
wire [63:0] pi_out [0:24];
wire [63:0] chi_out [0:24];
wire [63:0] iota_out [0:24];

reg [63:0] theta_in [0:24];

// Padding模块接口
wire       pad_in_ready;
wire       pad_out_valid;
wire [1599:0] pad_out_data_ext;
reg        pad_out_ready;
// 内部FIFO信号
reg [63:0] fifo_din;
reg        fifo_wrreq;
wire       fifo_full;
reg        fifo_rdreq;




// ===============================================================
// Padding模块输出信号
// ===============================================================

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

// SHAKE128: 1344位
wire [1343:0] pad_out_s128;
wire pad_valid_s128;
wire pad_ready_s128;
wire msg_done_s128;

// SHAKE256: 1088位
wire [1087:0] pad_out_s256;
wire pad_valid_s256;
wire pad_ready_s256;
wire msg_done_s256;

// ===============================================================
// Padding模块实例化
// ===============================================================

padding_sha3_224 u_pad_224 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid && mode == 3'd0),
    .is_last(in_isLast),
    .in_byte(in_byte),
    .in_ready(pad_ready_224),
    .out_valid(pad_valid_224),
    .out(pad_out_224),
    .out_ready(pad_out_ready),
    .msg_done(msg_done_224)
);





padding_sha3_256 u_pad_256 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid && mode == 3'd1),
    .is_last(in_isLast),
    .in_byte(in_byte),
    .in_ready(pad_ready_256),
    .out_valid(pad_valid_256),
    .out(pad_out_256),
    .out_ready(pad_out_ready),
    .msg_done(msg_done_256)
);
padding_sha3_384 u_pad_384(
    .clk(clk),
    .rst_n(rst_n),
    .in_byte(in_byte),
    .in_valid(in_valid && mode == 3'd2),
    .is_last(in_isLast),
    .in_ready(pad_ready_384),

    .out_valid(pad_valid_384),
    .out(pad_out_384),
    .out_ready(pad_out_ready),
    .msg_done(msg_done_384)
);


padding_sha3_512 u_pad_512 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid && mode == 3'd3),
    .is_last(in_isLast),
    .in_byte(in_byte),
    .in_ready(pad_ready_512),
    .out_valid(pad_valid_512),
    .out(pad_out_512),
    .out_ready(pad_out_ready),
    .msg_done(msg_done_512)
);

padding_shake128 u_pad_s128 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid && mode == 3'd4),
    .is_last(in_isLast),
    .in_byte(in_byte),
    .in_ready(pad_ready_s128),
    .out_valid(pad_valid_s128),
    .out(pad_out_s128),
    .out_ready(pad_out_ready),
    .msg_done(msg_done_s128)
);

padding_shake256 u_pad_s256 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid && mode == 3'd5),
    .is_last(in_isLast),
    .in_byte(in_byte),
    .in_ready(pad_ready_s256),
    .out_valid(pad_valid_s256),
    .out(pad_out_s256),
    .out_ready(pad_out_ready),
    .msg_done(msg_done_s256)
);

// ===============================================================
// Padding输出选择 - 扩展到1600位
// ===============================================================
assign pad_out_data_ext = (mode == 3'd0) ? {pad_out_224,{448{1'b0}}} :
                          (mode == 3'd1) ? { pad_out_256,{512{1'b0}}} :
                          (mode == 3'd2) ? {pad_out_384,{768{1'b0}}} :
                          (mode == 3'd3) ? { pad_out_512,{1024{1'b0}}} :
                          (mode == 3'd4) ? { pad_out_s128,{256{1'b0}}} :
                          (mode == 3'd5) ? {pad_out_s256,{512{1'b0}}} :
                          1600'h0;

assign pad_out_valid = (mode == 3'd0) ? pad_valid_224 :
                       (mode == 3'd1) ? pad_valid_256 :
                       (mode == 3'd2) ? pad_valid_384 :
                       (mode == 3'd3) ? pad_valid_512 :
                       (mode == 3'd4) ? pad_valid_s128 :
                       (mode == 3'd5) ? pad_valid_s256 : 1'b0;

assign pad_in_ready = (mode == 3'd0) ? pad_ready_224 :
                      (mode == 3'd1) ? pad_ready_256 :
                      (mode == 3'd2) ? pad_ready_384 :
                      (mode == 3'd3) ? pad_ready_512 :
                      (mode == 3'd4) ? pad_ready_s128 :
                      (mode == 3'd5) ? pad_ready_s256 : 1'b0;
                      
assign msg_done     = (mode == 3'd0) ? msg_done_224 :
                      (mode == 3'd1) ? msg_done_256 :
                      (mode == 3'd2) ? msg_done_384 :
                      (mode == 3'd3) ? msg_done_512 :
                      (mode == 3'd4) ? msg_done_s128 :
                      (mode == 3'd5) ? msg_done_s256 : 1'b0;
// ===============================================================
// 将1600位数据映射到25个64位字
// ===============================================================
wire [63:0] pad_words [0:24];
genvar p;
generate
    for (p = 0; p < 25; p = p + 1) begin : pad_word_mapping
        assign pad_words[p] = pad_out_data_ext[p*64 +: 64];
    end
endgenerate





theta u_theta (
    .in_data_0 (theta_in[0]),
    .in_data_1 (theta_in[1]),
    .in_data_2 (theta_in[2]),
    .in_data_3 (theta_in[3]),
    .in_data_4 (theta_in[4]),
    .in_data_5 (theta_in[5]),
    .in_data_6 (theta_in[6]),
    .in_data_7 (theta_in[7]),
    .in_data_8 (theta_in[8]),
    .in_data_9 (theta_in[9]),
    .in_data_10(theta_in[10]),
    .in_data_11(theta_in[11]),
    .in_data_12(theta_in[12]),
    .in_data_13(theta_in[13]),
    .in_data_14(theta_in[14]),
    .in_data_15(theta_in[15]),
    .in_data_16(theta_in[16]),
    .in_data_17(theta_in[17]),
    .in_data_18(theta_in[18]),
    .in_data_19(theta_in[19]),
    .in_data_20(theta_in[20]),
    .in_data_21(theta_in[21]),
    .in_data_22(theta_in[22]),
    .in_data_23(theta_in[23]),
    .in_data_24(theta_in[24]),
    
    .out_data_0(theta_out[0]),
    .out_data_1(theta_out[1]),
    .out_data_2(theta_out[2]),
    .out_data_3(theta_out[3]),
    .out_data_4(theta_out[4]),
    .out_data_5(theta_out[5]),
    .out_data_6(theta_out[6]),
    .out_data_7(theta_out[7]),
    .out_data_8(theta_out[8]),
    .out_data_9(theta_out[9]),
    .out_data_10(theta_out[10]),
    .out_data_11(theta_out[11]),
    .out_data_12(theta_out[12]),
    .out_data_13(theta_out[13]),
    .out_data_14(theta_out[14]),
    .out_data_15(theta_out[15]),
    .out_data_16(theta_out[16]),
    .out_data_17(theta_out[17]),
    .out_data_18(theta_out[18]),
    .out_data_19(theta_out[19]),
    .out_data_20(theta_out[20]),
    .out_data_21(theta_out[21]),
    .out_data_22(theta_out[22]),
    .out_data_23(theta_out[23]),
    .out_data_24(theta_out[24])
);


Rho u_rho (
    .in_data_0 (theta_reg[0]),
    .in_data_1 (theta_reg[1]),
    .in_data_2 (theta_reg[2]),
    .in_data_3 (theta_reg[3]),
    .in_data_4 (theta_reg[4]),
    .in_data_5 (theta_reg[5]),
    .in_data_6 (theta_reg[6]),
    .in_data_7 (theta_reg[7]),
    .in_data_8 (theta_reg[8]),
    .in_data_9 (theta_reg[9]),
    .in_data_10(theta_reg[10]),
    .in_data_11(theta_reg[11]),
    .in_data_12(theta_reg[12]),
    .in_data_13(theta_reg[13]),
    .in_data_14(theta_reg[14]),
    .in_data_15(theta_reg[15]),
    .in_data_16(theta_reg[16]),
    .in_data_17(theta_reg[17]),
    .in_data_18(theta_reg[18]),
    .in_data_19(theta_reg[19]),
    .in_data_20(theta_reg[20]),
    .in_data_21(theta_reg[21]),
    .in_data_22(theta_reg[22]),
    .in_data_23(theta_reg[23]),
    .in_data_24(theta_reg[24]),
    
    .out_data_0(rho_out[0]),
    .out_data_1(rho_out[1]),
    .out_data_2(rho_out[2]),
    .out_data_3(rho_out[3]),
    .out_data_4(rho_out[4]),
    .out_data_5(rho_out[5]),
    .out_data_6(rho_out[6]),
    .out_data_7(rho_out[7]),
    .out_data_8(rho_out[8]),
    .out_data_9(rho_out[9]),
    .out_data_10(rho_out[10]),
    .out_data_11(rho_out[11]),
    .out_data_12(rho_out[12]),
    .out_data_13(rho_out[13]),
    .out_data_14(rho_out[14]),
    .out_data_15(rho_out[15]),
    .out_data_16(rho_out[16]),
    .out_data_17(rho_out[17]),
    .out_data_18(rho_out[18]),
    .out_data_19(rho_out[19]),
    .out_data_20(rho_out[20]),
    .out_data_21(rho_out[21]),
    .out_data_22(rho_out[22]),
    .out_data_23(rho_out[23]),
    .out_data_24(rho_out[24])
);


pi u_pi (
    .in_data_0 (rho_out[0]),
    .in_data_1 (rho_out[1]),
    .in_data_2 (rho_out[2]),
    .in_data_3 (rho_out[3]),
    .in_data_4 (rho_out[4]),
    .in_data_5 (rho_out[5]),
    .in_data_6 (rho_out[6]),
    .in_data_7 (rho_out[7]),
    .in_data_8 (rho_out[8]),
    .in_data_9 (rho_out[9]),
    .in_data_10(rho_out[10]),
    .in_data_11(rho_out[11]),
    .in_data_12(rho_out[12]),
    .in_data_13(rho_out[13]),
    .in_data_14(rho_out[14]),
    .in_data_15(rho_out[15]),
    .in_data_16(rho_out[16]),
    .in_data_17(rho_out[17]),
    .in_data_18(rho_out[18]),
    .in_data_19(rho_out[19]),
    .in_data_20(rho_out[20]),
    .in_data_21(rho_out[21]),
    .in_data_22(rho_out[22]),
    .in_data_23(rho_out[23]),
    .in_data_24(rho_out[24]),
    
    .out_data_0(pi_out[0]),
    .out_data_1(pi_out[1]),
    .out_data_2(pi_out[2]),
    .out_data_3(pi_out[3]),
    .out_data_4(pi_out[4]),
    .out_data_5(pi_out[5]),
    .out_data_6(pi_out[6]),
    .out_data_7(pi_out[7]),
    .out_data_8(pi_out[8]),
    .out_data_9(pi_out[9]),
    .out_data_10(pi_out[10]),
    .out_data_11(pi_out[11]),
    .out_data_12(pi_out[12]),
    .out_data_13(pi_out[13]),
    .out_data_14(pi_out[14]),
    .out_data_15(pi_out[15]),
    .out_data_16(pi_out[16]),
    .out_data_17(pi_out[17]),
    .out_data_18(pi_out[18]),
    .out_data_19(pi_out[19]),
    .out_data_20(pi_out[20]),
    .out_data_21(pi_out[21]),
    .out_data_22(pi_out[22]),
    .out_data_23(pi_out[23]),
    .out_data_24(pi_out[24])
);


// ===============================================================
// Chi模块实例化 - 使用正确的端口名 (in0, in1, ... out0, out1, ...)
// ===============================================================
chi u_chi (
    .in0  (pi_out[0]),
    .in1  (pi_out[1]),
    .in2  (pi_out[2]),
    .in3  (pi_out[3]),
    .in4  (pi_out[4]),
    .in5  (pi_out[5]),
    .in6  (pi_out[6]),
    .in7  (pi_out[7]),
    .in8  (pi_out[8]),
    .in9  (pi_out[9]),
    .in10 (pi_out[10]),
    .in11 (pi_out[11]),
    .in12 (pi_out[12]),
    .in13 (pi_out[13]),
    .in14 (pi_out[14]),
    .in15 (pi_out[15]),
    .in16 (pi_out[16]),
    .in17 (pi_out[17]),
    .in18 (pi_out[18]),
    .in19 (pi_out[19]),
    .in20 (pi_out[20]),
    .in21 (pi_out[21]),
    .in22 (pi_out[22]),
    .in23 (pi_out[23]),
    .in24 (pi_out[24]),
    
    .out0  (chi_out[0]),
    .out1  (chi_out[1]),
    .out2  (chi_out[2]),
    .out3  (chi_out[3]),
    .out4  (chi_out[4]),
    .out5  (chi_out[5]),
    .out6  (chi_out[6]),
    .out7  (chi_out[7]),
    .out8  (chi_out[8]),
    .out9  (chi_out[9]),
    .out10 (chi_out[10]),
    .out11 (chi_out[11]),
    .out12 (chi_out[12]),
    .out13 (chi_out[13]),
    .out14 (chi_out[14]),
    .out15 (chi_out[15]),
    .out16 (chi_out[16]),
    .out17 (chi_out[17]),
    .out18 (chi_out[18]),
    .out19 (chi_out[19]),
    .out20 (chi_out[20]),
    .out21 (chi_out[21]),
    .out22 (chi_out[22]),
    .out23 (chi_out[23]),
    .out24 (chi_out[24])
);


Iota u_iota (
    .in_data_0(chi_out[0]),
    .out_data_0(iota_out[0]),
    .in_round(round)    
);



assign iota_out[1]  = chi_out[1];
assign iota_out[2]  = chi_out[2];
assign iota_out[3]  = chi_out[3];
assign iota_out[4]  = chi_out[4];
assign iota_out[5]  = chi_out[5];
assign iota_out[6]  = chi_out[6];
assign iota_out[7]  = chi_out[7];
assign iota_out[8]  = chi_out[8];
assign iota_out[9]  = chi_out[9];
assign iota_out[10] = chi_out[10];
assign iota_out[11] = chi_out[11];
assign iota_out[12] = chi_out[12];
assign iota_out[13] = chi_out[13];
assign iota_out[14] = chi_out[14];
assign iota_out[15] = chi_out[15];
assign iota_out[16] = chi_out[16];
assign iota_out[17] = chi_out[17];
assign iota_out[18] = chi_out[18];
assign iota_out[19] = chi_out[19];
assign iota_out[20] = chi_out[20];
assign iota_out[21] = chi_out[21];
assign iota_out[22] = chi_out[22];
assign iota_out[23] = chi_out[23];
assign iota_out[24] = chi_out[24];



fifo_64x512	u_fifo (
	.aclr (~rst_n ),
	.clock ( clk ),
	.data ( fifo_din ),
	.rdreq ( fifo_rdreq ),
	.wrreq ( fifo_wrreq ),
	.empty ( is_empty ),
	.full ( fifo_full ),
	.q ( out_data ),
	.usedw (  )
	);
//
assign in_ready=pad_in_ready&(state==ABSORB);

//状态机

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state<=IDLE;
    else
        state<=next_state;
end

always@(*)begin
    next_state=state;
    case(state)
        IDLE:
            next_state=ABSORB;
        ABSORB:begin
            if(pad_out_valid)
                next_state=THETA;
            else
                next_state=ABSORB;
        end
        THETA:next_state=IOTA;
        IOTA:next_state=ROUND_;
        ROUND_:begin
            if(round<24) next_state=THETA;
            else if(absorb_flag) next_state= ABSORB;
            else if(squeeze_flag) next_state=SQUEEZE;
        end
        SQUEEZE:begin
            if(total_bytes<=bytes_out)
                next_state<=DONE;
            else if(round_words_out==round_words)
                next_state<=THETA;
            else next_state<=SQUEEZE;
        end
        DONE:begin
            if(read_ready)next_state<=IDLE;
            else next_state<=DONE;
        end
        default:next_state=IDLE;
    endcase
end
//


always@(posedge clk or negedge rst_n)begin

    if(!rst_n)begin
        absorb_flag<=1'd1;
        squeeze_flag<=1'd0;
        round<=0; 
        total_bytes<=0; 
        pad_out_ready<=1'd0;
        round_words<=0;
        for (j = 0; j < 25; j = j + 1) begin
            state_reg[j] <= 64'h0;
            theta_reg[j] <= 64'h0;
            theta_in[j] <= 64'h0;
        end   
    end
    else case(state)
        IDLE:begin
            absorb_flag<=1'd1;
            squeeze_flag<=1'd0;
            round<=0;  
            total_bytes<=0;
            pad_out_ready<=0;
            round_words<=0;
            for (j = 0; j < 25; j = j + 1) begin
                state_reg[j] <= 64'h0;
                theta_reg[j] <= 64'h0;
                theta_in[j] <= 64'h0;
            end  
        end
        ABSORB:begin
            round<=0;
            case(mode)
                3'd0:begin
                    total_bytes<=15'd28;
                    round_words<=5'd5;
                end
                3'd1:begin
                    total_bytes<=15'd32;
                    round_words<=5'd5;
                end
                3'd2:begin
                    total_bytes<=15'd48;
                    round_words<=5'd6;
                end
                3'd3:begin
                    total_bytes<=15'd64;
                    round_words<=5'd8;
                end
                3'd4:begin
                    total_bytes<=shake_req;
                    round_words<=5'd21;
                end
                3'd5:begin
                    total_bytes<=shake_req;
                    round_words<=8'd17;
                end
                default begin
                    total_bytes<=0;
                    round_words<=0;
                end
            endcase
            if(pad_in_ready&in_valid) begin
                pad_out_ready<=1'd0;
            end
            else if(pad_out_valid)begin
                for (j = 0; j < 25; j = j + 1) begin
                    theta_in[24-j] <= pad_out_data_ext[j*64+:64]^state_reg[24-j];
                    
                end 
                pad_out_ready<=1'd1;
            end
            if(msg_done) begin
                absorb_flag<=1'd0;
                squeeze_flag<=1'd1;
            end
        end
        THETA:begin
            for (j = 0; j < 25; j = j + 1) begin
                theta_reg[j] <= theta_out[j];
            end 
        end
        IOTA:begin
            for (j = 0; j < 25; j = j + 1) begin
                state_reg[j] <= iota_out[j];
            end 
            round<=round+1'd1;
        end
        ROUND_:begin
            if(round<24)begin
                for (j = 0; j < 25; j = j + 1) begin
                    theta_in[j] <= state_reg[j];
                end 
            end
        end
        SQUEEZE:begin
            round<=0;
            for (j = 0; j < 25; j = j + 1) begin
                theta_in[j] <= state_reg[j];
            end 
        end
        default:begin
            absorb_flag<=absorb_flag;
            squeeze_flag<=squeeze_flag;
            round<=round; 
            total_bytes<=total_bytes;
            pad_out_ready<=pad_in_ready;
            for (j = 0; j < 25; j = j + 1) begin
                theta_in[j] <= theta_in[j];
                state_reg[j]<=state_reg[j];
                theta_reg[j]<=theta_reg[j];
            end  
            round_words<=round_words;
        end
    endcase
end

//fifo 输入
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        bytes_out<=0;
        round_words_out<=0;
        fifo_wrreq<=1'd0;
        fifo_din<=0;
        fifo_wr_ready<=0;
        flag<=0;
    end
    else case(state) 
        IDLE:begin
            flag<=0;
            bytes_out<=0;
            round_words_out<=0;
            fifo_wrreq<=1'd0;
            fifo_din<=0;
            fifo_wr_ready<=0;
        end
        SQUEEZE:begin
            if(flag==0)
                flag<=1'd1;
            if(bytes_out>=total_bytes)
                fifo_wr_ready<=1'd1;
            else 
                fifo_wr_ready<=1'd0;
            if((bytes_out<total_bytes)&(round_words_out<round_words))begin
                if(!fifo_full) begin
                    fifo_wrreq<=1'd1;
                    fifo_din<=state_reg[round_words_out];
                    bytes_out<=bytes_out+16'd8;
                    round_words_out<=round_words_out+1'd1;
                end
                else begin
                    fifo_wrreq<=1'd0;
                    fifo_din<=fifo_din;
                    bytes_out<=bytes_out;
                    round_words_out<=round_words_out;
                end
            
            end
            else begin
                fifo_wrreq<=1'd0;
                fifo_din<=fifo_din;
                bytes_out<=bytes_out;
                round_words_out<=round_words_out;
            end
        end
        default begin
            fifo_wrreq<=1'd0;
            fifo_din<=fifo_din;
            bytes_out<=bytes_out;
            if(!flag)
                round_words_out<=round_words;
            else
                round_words_out<=0;
            fifo_wr_ready<=fifo_wr_ready;
        end
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        fifo_rdreq<=1'd0;
    end
    else 
        fifo_rdreq<=rd_word;
end

endmodule