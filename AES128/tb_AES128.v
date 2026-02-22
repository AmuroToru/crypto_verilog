`timescale 1ns/1ns  // 时间尺度设置

module tb_AES128();

// 信号定义
reg             clk         ;
reg             rst_n       ;
reg             en          ;
reg             key_mode    ;
reg     [7:0]   data_in     ;
wire    [127:0] data_out    ;
wire            ready       ;
wire            busy        ;





// 时钟生成：周期20ns (50MHz)
always #10 clk = ~clk;

// 实例化被测试模块
AES128 aes_inst(
    .clk       (clk     ) ,  // 时钟
    .rst_n     (rst_n   ) ,  // 复位，低有效
    .en        (en      ) ,  // 使能信号，开始加密
    .key_mode  (key_mode) ,  // 输入模式：1=输入密钥，0=输入明文
    .data_in   (data_in ) ,  // 8位数据输入
    .data_out  (data_out) ,  // 128位密文输出
    .ready     (ready   ) ,  // 加密完成标志
    .busy      (busy    )    // 忙碌标志
);

// 初始化
initial begin
    // 初始值设置
    clk = 1'b1;
    rst_n = 1'b0;           
    en = 1'b0;
    key_mode = 1'b1;
    data_in = 8'd0;
    
    // 等待20ns后释放复位
    #20;
    rst_n = 1'b1; 
    en=1'b1;    
    
    // 加载密钥（假设是128位密钥，需要16个时钟周期）
    #20;
    key_mode = 1'b1;  // 密钥加载模式
    //密钥: 2b7e151628aed2a6abf7158809cf4f3c
    // 每个时钟周期输入一个字节]
    #20
    data_in = 8'h2b; #20;
    data_in = 8'h7e; #20;
    data_in = 8'h15; #20;
    data_in = 8'h16; #20;
    data_in = 8'h28; #20;
    data_in = 8'hae; #20;
    data_in = 8'hd2; #20;
    data_in = 8'ha6; #20;
    data_in = 8'hab; #20;
    data_in = 8'hf7; #20;
    data_in = 8'h15; #20;
    data_in = 8'h88; #20;
    data_in = 8'h09; #20;
    data_in = 8'hcf; #20;
    data_in = 8'h4f; #20;
    data_in = 8'h3c; #20;
    
    // 切换到明文加载模式
    key_mode = 1'b0;
    //明文: 6bc1bee22e409f96e93d7e117393172a
    // 输入128位明文 
    data_in = 8'h6b; #20;
    data_in = 8'hc1; #20;
    data_in = 8'hbe; #20;
    data_in = 8'he2; #20;
    data_in = 8'h2e; #20;
    data_in = 8'h40; #20;
    data_in = 8'h9f; #20;
    data_in = 8'h96; #20;
    data_in = 8'he9; #20;
    data_in = 8'h3d; #20;
    data_in = 8'h7e; #20;
    data_in = 8'h11; #20;
    data_in = 8'h73; #20;
    data_in = 8'h93; #20;
    data_in = 8'h17; #20;
    data_in = 8'h2a; #20;
    

    
    // 等待加密完成
    #1000;  // 等待足够时间
    
    $display("加密完成！");
    $display("密钥扩展结果：");
    
    // 结束仿真
    #320;
    $finish;
end

// 监控信号变化
always @(posedge clk) begin
    if (ready) begin
        $display("加密结果输出：%h", data_out);
    end
end


endmodule
