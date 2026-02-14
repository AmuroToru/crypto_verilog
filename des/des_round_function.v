module des_round_function
(
    input  wire [31:0] INR,   // 输入32位右半部分
    input  wire [47:0] K_sub, // 输入48位子密钥
    input  wire [31:0] INL,   // 输入32位左半部分
    output wire [31:0] OUTL,  // 输出32位左半部分
    output wire [31:0] OUTP  // 输出32位右半部分（轮函数输出）
);

// ---------------- E 扩展置换 ----------------

wire [47:0] E;

assign E = {

            INR[0],  INR[31], INR[30], INR[29], INR[28], INR[27],
            INR[28], INR[27], INR[26], INR[25], INR[24], INR[23],
            INR[24], INR[23], INR[22], INR[21], INR[20], INR[19],
            INR[20], INR[19], INR[18], INR[17], INR[16], INR[15],
            INR[16], INR[15], INR[14], INR[13], INR[12], INR[11],
            INR[12], INR[11], INR[10], INR[9],  INR[8],  INR[7],
            INR[8],  INR[7],  INR[6],  INR[5],  INR[4],  INR[3],
            INR[4],  INR[3],  INR[2],  INR[1],  INR[0],  INR[31]
};




// ---------------- 与子密钥异或 ----------------
wire [47:0] X;
assign X = E ^ K_sub;

// ---------------- 8个S盒替换 ----------------
wire [0:3] S0, S1, S2, S3, S4, S5, S6, S7;
wire [0:31] S;

sbox8 u8 (.address(X[05:00]),  .sout(S7));
sbox7 u7 (.address(X[11:06]),  .sout(S6));
sbox6 u6 (.address(X[17:12]),  .sout(S5));
sbox5 u5 (.address(X[23:18]),  .sout(S4));
sbox4 u4 (.address(X[29:24]),  .sout(S3));
sbox3 u3 (.address(X[35:30]),  .sout(S2));
sbox2 u2 (.address(X[41:36]),  .sout(S1));
sbox1 u1 (.address(X[47:42]),  .sout(S0));

//assign S = {S7[0],S7[1],S7[2],S7[3] ,S6[0],S6[1],S6[2],S6[3], S5[0], S5[1],S5[2],S5[3],S4[0],S4[1],S4[2],S4[3], S3[0],S3[1],S3[2],S3[3], S2[0],S2[1],S2[2],S2[3], S1[0],S1[1],S1[2],S1[3], S0[0],S0[1],S0[2],S0[3]};
assign  S={S0,S1,S2,S3,S4,S5,S6,S7};
// ---------------- P 盒置换 ----------------
wire [31:0] P;

assign P = {
    S[15], S[6],  S[19], S[20], S[28], S[11], S[27], S[16],
    S[0],  S[14], S[22], S[25], S[4],  S[17], S[30], S[9],
    S[1],  S[7],  S[23], S[13], S[31], S[26], S[2],  S[8],
    S[18], S[12], S[29], S[5],  S[21], S[10], S[3],  S[24]
};
/*
assign P = {
    S[24], S[3],  S[10], S[21], S[5],  S[29], S[12], S[18],
    S[8],  S[2],  S[26], S[31], S[13], S[23], S[7],  S[1],
    S[9],  S[30], S[17], S[4],  S[25], S[22], S[14], S[0],
    S[16], S[27], S[11], S[28], S[20], S[19], S[6],  S[15]
};
*/
// ---------------- 轮函数输出 ----------------
assign OUTP = P ^ INL;
//assign OUTP={P[31],P[30],P[29],P[28],P[27],P[26],P[25],P[24],P[23],P[22],P[21],P[20],P[19],P[18],P[17],P[16],P[15],P[14],P[13],P[12],P[11],P[10],P[9],P[8],P[7],P[6],P[5],P[4],P[3],P[2],P[1],P[0]};
assign OUTL = INR;

endmodule
