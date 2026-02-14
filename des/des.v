module des(
    input   wire    [63:0]  key_message,
    input   wire            clk,
    input   wire            rst_n,
    input   wire            sel,//0 输入key，1输入message
    output  wire    [63:0]  enc,
    output  wire             enc_ready  ,
    output wire            parity_check_error
);


wire    [63:0]enc_pre_ivip;//未使用ip逆置换
wire    [63:0]   ip_out;
wire    [47:0]  subkey1,subkey2,subkey3,subkey4,subkey5,subkey6,subkey7,subkey8,subkey9,subkey10,subkey11,subkey12,subkey13,subkey14,subkey15,subkey16;  

wire    [31:0]  L1,R1,L2,R2,L3,R3,L4,R4,L5,R5,L6,R6,L7,R7,L8,R8,L9,R9,L10,R10,L11,R11,L12,R12,L13,R13,L14,R14,L15,R15,L16,R16;
wire    [31:0]  out_L,out_R;
assign  L1=ip_out[63:32];
assign  R1=ip_out[31:0];
assign  enc_pre_ivip={out_R,out_L};
assign  Sub_key1=subkey16;
reg key_en;
reg     [63:0]  message;
reg     [63:0]  key;
wire    [63:0]  message_wire;
wire    [63:0]  key_wire;
wire            key_en_wire;
assign message_wire=message;
assign key_wire=key;
assign  key_en_wire=key_en;
always @(posedge  clk or negedge rst_n)begin
    if(!rst_n)begin
        message<=0;
        key<=0;
        key_en<=0;
    end
    else if(sel==0)begin
        message<=message;
        key<=key_message;
        key_en<=1'd1;
    end
    else if(sel==1'd1)begin
        message<=key_message;
        key<=key;
        key_en<=key_en;
    end
    else begin
        message<=message;
        key<=key;
        key_en<=key_en;
    end
end
 ip ip_inst
(
    .din(message_wire),
    .ip_out(ip_out)
);



des_keyExtension    key_extension(
    .clk(clk),            // 系统时钟
    .rst_n(rst_n),          // 低电平复位
    .key_in(key_wire),         // 64位原始密钥（含8位奇偶校验位）
    .key_en(key_en_wire),         // 密钥扩展使能
    .key_ready(enc_ready),
    .parity_check_error(parity_check_error),
    .subkey1_o (subkey1),
    .subkey2_o (subkey2),
    .subkey3_o (subkey3),
    .subkey4_o (subkey4),
    .subkey5_o (subkey5),
    .subkey6_o (subkey6),
    .subkey7_o (subkey7),
    .subkey8_o (subkey8),
    .subkey9_o (subkey9),
    .subkey10_o(subkey10),
    .subkey11_o(subkey11),
    .subkey12_o(subkey12),
    .subkey13_o(subkey13),
    .subkey14_o(subkey14),
    .subkey15_o(subkey15),
    .subkey16_o(subkey16)
);
des_round_function f1
(
    .INR(R1),   // 输入32位右半部分
    .K_sub(subkey1), // 输入48位子密钥
    .INL(L1),   // 输入32位左半部分
    .OUTL(L2),  // 输出32位左半部分
    .OUTP(R2)   // 输出32位右半部分（轮函数输出）
);
des_round_function f2
(
    .INR(R2),   // 输入32位右半部分
    .K_sub(subkey2), // 输入48位子密钥
    .INL(L2),   // 输入32位左半部分
    .OUTL(L3),  // 输出32位左半部分
    .OUTP(R3)   // 输出32位右半部分（轮函数输出）
);
des_round_function f3
(
    .INR(R3),   // 输入32位右半部分
    .K_sub(subkey3), // 输入48位子密钥
    .INL(L3),   // 输入32位左半部分
    .OUTL(L4),  // 输出32位左半部分
    .OUTP(R4)   // 输出32位右半部分（轮函数输出）
);
des_round_function f4
(
    .INR(R4),   // 输入32位右半部分
    .K_sub(subkey4), // 输入48位子密钥
    .INL(L4),   // 输入32位左半部分
    .OUTL(L5),  // 输出32位左半部分
    .OUTP(R5)   // 输出32位右半部分（轮函数输出）
);
des_round_function f5
(
    .INR(R5),   // 输入32位右半部分
    .K_sub(subkey5), // 输入48位子密钥
    .INL(L5),   // 输入32位左半部分
    .OUTL(L6),  // 输出32位左半部分
    .OUTP(R6)   // 输出32位右半部分（轮函数输出）
);
des_round_function f6
(
    .INR(R6),   // 输入32位右半部分
    .K_sub(subkey6), // 输入48位子密钥
    .INL(L6),   // 输入32位左半部分
    .OUTL(L7),  // 输出32位左半部分
    .OUTP(R7)   // 输出32位右半部分（轮函数输出）
);
des_round_function f7
(
    .INR(R7),   // 输入32位右半部分
    .K_sub(subkey7), // 输入48位子密钥
    .INL(L7),   // 输入32位左半部分
    .OUTL(L8),  // 输出32位左半部分
    .OUTP(R8)   // 输出32位右半部分（轮函数输出）
);
des_round_function f8
(
    .INR(R8),   // 输入32位右半部分
    .K_sub(subkey8), // 输入48位子密钥
    .INL(L8),   // 输入32位左半部分
    .OUTL(L9),  // 输出32位左半部分
    .OUTP(R9)   // 输出32位右半部分（轮函数输出）
);
des_round_function f9
(
    .INR(R9),   // 输入32位右半部分
    .K_sub(subkey9), // 输入48位子密钥
    .INL(L9),   // 输入32位左半部分
    .OUTL(L10),  // 输出32位左半部分
    .OUTP(R10)   // 输出32位右半部分（轮函数输出）
);
des_round_function f10
(
    .INR(R10),   // 输入32位右半部分
    .K_sub(subkey10), // 输入48位子密钥
    .INL(L10),   // 输入32位左半部分
    .OUTL(L11),  // 输出32位左半部分
    .OUTP(R11)   // 输出32位右半部分（轮函数输出）
);
des_round_function f11
(
    .INR(R11),   // 输入32位右半部分
    .K_sub(subkey11), // 输入48位子密钥
    .INL(L11),   // 输入32位左半部分
    .OUTL(L12),  // 输出32位左半部分
    .OUTP(R12)   // 输出32位右半部分（轮函数输出）
);
des_round_function f12
(
    .INR(R12),   // 输入32位右半部分
    .K_sub(subkey12), // 输入48位子密钥
    .INL(L12),   // 输入32位左半部分
    .OUTL(L13),  // 输出32位左半部分
    .OUTP(R13)   // 输出32位右半部分（轮函数输出）
);
des_round_function f13
(
    .INR(R13),   // 输入32位右半部分
    .K_sub(subkey13), // 输入48位子密钥
    .INL(L13),   // 输入32位左半部分
    .OUTL(L14),  // 输出32位左半部分
    .OUTP(R14)   // 输出32位右半部分（轮函数输出）
);
des_round_function f14
(
    .INR(R14),   // 输入32位右半部分
    .K_sub(subkey14), // 输入48位子密钥
    .INL(L14),   // 输入32位左半部分
    .OUTL(L15),  // 输出32位左半部分
    .OUTP(R15)   // 输出32位右半部分（轮函数输出）
);
des_round_function f15
(
    .INR(R15),   // 输入32位右半部分
    .K_sub(subkey15), // 输入48位子密钥
    .INL(L15),   // 输入32位左半部分
    .OUTL(L16),  // 输出32位左半部分
    .OUTP(R16)   // 输出32位右半部分（轮函数输出）
);
des_round_function f16
(
    .INR(R16),   // 输入32位右半部分
    .K_sub(subkey16), // 输入48位子密钥
    .INL(L16),   // 输入32位左半部分
    .OUTL(out_L),  // 输出32位左半部分
    .OUTP(out_R)   // 输出32位右半部分（轮函数输出）
);
ivip ivip_inst
(
    .din(enc_pre_ivip),   // 输入64位数据
    .ivip_out(enc)// 逆初始置换输出
);
endmodule
