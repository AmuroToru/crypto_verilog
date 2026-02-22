module AES128(
    input   wire            clk         ,  // 时钟
    input   wire            rst_n       ,  // 复位，低有效
    input   wire            en          ,  // 使能信号，开始加密
    input   wire            key_mode    ,  // 输入模式：1=输入密钥，0=输入明文
    input   wire    [7:0]   data_in     ,  // 8位数据输入
    output  wire    [127:0] data_out    ,  // 128位密文输出
    output  wire            ready       ,  // 加密完成标志
    output  wire            busy           // 忙碌标志
);

// ============================================================
// 参数定义
// ============================================================
localparam  IDLE        = 3'd0,
            LOAD_KEY    = 3'd1,
            LOAD_TEXT   = 3'd2,
            KEY_EXPAND  = 3'd3,
            ENCRYPT     = 3'd4,
            WAIT_ROUNDS = 3'd5,
            DONE        = 3'd6;

// ============================================================
// 内部信号定义
// ============================================================
reg  [2:0]   state, next_state;
reg  [4:0]   byte_cnt;           // 字节计数器，0-15
reg  [127:0] key_reg;             // 密钥寄存器
reg  [127:0] text_reg;            // 明文寄存器
reg  [127:0] text_out;            // 密文输出寄存器
reg          key_expand_done;     // 密钥扩展完成标志
reg  [5:0]   round_cnt;           // 轮计数器 (0-39)
reg          encrypt_start;       // 加密启动信号

// 密钥扩展相关信号 
wire [127:0] key_wire0;
wire [127:0] key_wire1;
wire [127:0] key_wire2;
wire [127:0] key_wire3;
wire [127:0] key_wire4;
wire [127:0] key_wire5;
wire [127:0] key_wire6;
wire [127:0] key_wire7;
wire [127:0] key_wire8;
wire [127:0] key_wire9;
wire [127:0] key_wire10;
wire         key_expand_ready;

// 加密轮次中间结果 
wire [127:0] round_data_out1;
wire [127:0] round_data_out2;
wire [127:0] round_data_out3;
wire [127:0] round_data_out4;
wire [127:0] round_data_out5;
wire [127:0] round_data_out6;
wire [127:0] round_data_out7;
wire [127:0] round_data_out8;
wire [127:0] round_data_out9;
wire [127:0] round10_data_out;

// 各轮完成信号
wire         round_ready1;
wire         round_ready2;
wire         round_ready3;
wire         round_ready4;
wire         round_ready5;
wire         round_ready6;
wire         round_ready7;
wire         round_ready8;
wire         round_ready9;
wire         round10_ready;

// 各轮输入数据寄存器
reg  [127:0] round_data_in1;
reg  [127:0] round_data_in2;
reg  [127:0] round_data_in3;
reg  [127:0] round_data_in4;
reg  [127:0] round_data_in5;
reg  [127:0] round_data_in6;
reg  [127:0] round_data_in7;
reg  [127:0] round_data_in8;
reg  [127:0] round_data_in9;
reg  [127:0] round_data_in10;

// ============================================================
// 状态机：状态转移
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

// ============================================================
// 状态机：下一状态逻辑
// ============================================================
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (en)
                next_state <= LOAD_KEY;
        end
        
        LOAD_KEY: begin
            if (byte_cnt == 5'd15 && en)
                next_state <= LOAD_TEXT;
        end
        
        LOAD_TEXT: begin
            if (byte_cnt == 5'd15 && en)
                next_state <= KEY_EXPAND;
        end
        
        KEY_EXPAND: begin
            if (key_expand_done)
                next_state <= ENCRYPT;
        end
        
        ENCRYPT: begin
            next_state <= WAIT_ROUNDS;
        end
        
        WAIT_ROUNDS: begin
            // 9轮 × 4周期 + 最后一轮 × 3周期 = 39个周期
            if (round_cnt == 6'd39)
                next_state <= DONE;
        end
        
        DONE: begin
            if (!en)
                next_state = IDLE;
        end
        
        default: next_state = IDLE;
    endcase
end

// ============================================================
// 字节计数器
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        byte_cnt <= 5'd0;
    end
    else begin
        case (state)
            LOAD_KEY, LOAD_TEXT: begin
                if (en) begin
                    if (byte_cnt == 5'd15)
                        byte_cnt <= 5'd0;
                    else
                        byte_cnt <= byte_cnt + 5'd1;
                end
            end
            default: byte_cnt <= 5'd0;
        endcase
    end
end

// ============================================================
// 轮计数器
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        round_cnt <= 6'd0;
    end
    else if (state == ENCRYPT) begin
        round_cnt <= 6'd1;  // 从1开始计数
    end
    else if (state == WAIT_ROUNDS) begin
        if (round_cnt == 6'd39)
            round_cnt <= 6'd0;
        else
            round_cnt <= round_cnt + 6'd1;
    end
    else begin
        round_cnt <= 6'd0;
    end
end

// ============================================================
// 加密启动信号
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        encrypt_start <= 1'b0;
    else if (state == ENCRYPT)
        encrypt_start <= 1'b1;
    else
        encrypt_start <= encrypt_start;
end

// ============================================================
// 数据输入寄存器
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key_reg  <= 128'h0;
        text_reg <= 128'h0;
    end
    else begin
        case (state)
            LOAD_KEY: begin
                if (en) begin
                    key_reg <= {key_reg[119:0], data_in};
                end
            end
            
            LOAD_TEXT: begin
                if (en) begin
                    text_reg <= {text_reg[119:0], data_in};
                end
            end
            
            default: begin
                key_reg  <= key_reg;
                text_reg <= text_reg;
            end
        endcase
    end
end

// ============================================================
// 密钥扩展模块实例化
// ============================================================
key_extension key_expand_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .key_in     (key_reg),
    .key1       (key_wire1),
    .key2       (key_wire2),
    .key3       (key_wire3),
    .key4       (key_wire4),
    .key5       (key_wire5),
    .key6       (key_wire6),
    .key7       (key_wire7),
    .key8       (key_wire8),
    .key9       (key_wire9),
    .key10      (key_wire10),
    .key_ready  (key_expand_ready)
);

// 初始轮密钥
assign key_wire0 = key_reg;

// ============================================================
// 密钥扩展完成检测
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        key_expand_done <= 1'b0;
    else if (state == KEY_EXPAND && key_expand_ready)
        key_expand_done <= 1'b1;
    else if (state == DONE)
        key_expand_done <= 1'b0;
end

// ============================================================
// 第一轮：初始密钥加
// ============================================================
reg [127:0] round0_data;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round0_data <= 128'h0;
    else if (encrypt_start)
        round0_data <= text_reg ^ key_wire0;
end

// ============================================================
// 第1轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in1 <= 128'h0;
    else if (encrypt_start)
        round_data_in1 <= round0_data;
end

enc_round round1_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in1),
    .subkey         (key_wire1),
    .en             (encrypt_start),
    .message_out    (round_data_out1),
    .ready          (round_ready1)
);

// ============================================================
// 第2轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in2 <= 128'h0;
    else if (round_ready1)
        round_data_in2 <= round_data_out1;
end

enc_round round2_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in2),
    .subkey         (key_wire2),
    .en             (round_ready1),
    .message_out    (round_data_out2),
    .ready          (round_ready2)
);

// ============================================================
// 第3轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in3 <= 128'h0;
    else if (round_ready2)
        round_data_in3 <= round_data_out2;
end

enc_round round3_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in3),
    .subkey         (key_wire3),
    .en             (round_ready2),
    .message_out    (round_data_out3),
    .ready          (round_ready3)
);

// ============================================================
// 第4轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in4 <= 128'h0;
    else if (round_ready3)
        round_data_in4 <= round_data_out3;
end

enc_round round4_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in4),
    .subkey         (key_wire4),
    .en             (round_ready3),
    .message_out    (round_data_out4),
    .ready          (round_ready4)
);

// ============================================================
// 第5轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in5 <= 128'h0;
    else if (round_ready4)
        round_data_in5 <= round_data_out4;
end

enc_round round5_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in5),
    .subkey         (key_wire5),
    .en             (round_ready4),
    .message_out    (round_data_out5),
    .ready          (round_ready5)
);

// ============================================================
// 第6轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in6 <= 128'h0;
    else if (round_ready5)
        round_data_in6 <= round_data_out5;
end

enc_round round6_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in6),
    .subkey         (key_wire6),
    .en             (round_ready5),
    .message_out    (round_data_out6),
    .ready          (round_ready6)
);

// ============================================================
// 第7轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in7 <= 128'h0;
    else if (round_ready6)
        round_data_in7 <= round_data_out6;
end

enc_round round7_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in7),
    .subkey         (key_wire7),
    .en             (round_ready6),
    .message_out    (round_data_out7),
    .ready          (round_ready7)
);

// ============================================================
// 第8轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in8 <= 128'h0;
    else if (round_ready7)
        round_data_in8 <= round_data_out7;
end

enc_round round8_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in8),
    .subkey         (key_wire8),
    .en             (round_ready7),
    .message_out    (round_data_out8),
    .ready          (round_ready8)
);

// ============================================================
// 第9轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in9 <= 128'h0;
    else if (round_ready8)
        round_data_in9 <= round_data_out8;
end

enc_round round9_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in9),
    .subkey         (key_wire9),
    .en             (round_ready8),
    .message_out    (round_data_out9),
    .ready          (round_ready9)
);

// ============================================================
// 第10轮
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        round_data_in10 <= 128'h0;
    else if (round_ready9)
        round_data_in10 <= round_data_out9;
end

enc_round_10 round10_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .message_in     (round_data_in10),
    .subkey         (key_wire10),
    .en             (round_ready9),
    .message_out    (round10_data_out),
    .ready          (round10_ready)
);

// ============================================================
// 加密完成检测
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        text_out <= 128'h0;
    end
    else if (state == WAIT_ROUNDS && round_cnt == 6'd39) begin
        text_out <= round10_data_out;
    end
end

// ============================================================
// 输出赋值
// ============================================================
assign data_out = text_out;
assign ready    = (state == DONE);
assign busy     = (state != IDLE && state != DONE);

endmodule