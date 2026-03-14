module Rho
(
    // input
    in_data_0,
    in_data_1,
    in_data_2,
    in_data_3,
    in_data_4,
    in_data_5,
    in_data_6,
    in_data_7,
    in_data_8,
    in_data_9,
    in_data_10,
    in_data_11,
    in_data_12,
    in_data_13,
    in_data_14,
    in_data_15,
    in_data_16,
    in_data_17,
    in_data_18,
    in_data_19,
    in_data_20,
    in_data_21,
    in_data_22,
    in_data_23,
    in_data_24,
    //output
    out_data_0,
    out_data_1,
    out_data_2,
    out_data_3,
    out_data_4,
    out_data_5,
    out_data_6,
    out_data_7,
    out_data_8,
    out_data_9,
    out_data_10,
    out_data_11,
    out_data_12,
    out_data_13,
    out_data_14,
    out_data_15,
    out_data_16,
    out_data_17,
    out_data_18,
    out_data_19,
    out_data_20,
    out_data_21,
    out_data_22,
    out_data_23,
    out_data_24
);


input [63:0] in_data_0;
input [63:0] in_data_1;
input [63:0] in_data_2;
input [63:0] in_data_3;
input [63:0] in_data_4;
input [63:0] in_data_5;
input [63:0] in_data_6;
input [63:0] in_data_7;
input [63:0] in_data_8;
input [63:0] in_data_9;
input [63:0] in_data_10;
input [63:0] in_data_11;
input [63:0] in_data_12;
input [63:0] in_data_13;
input [63:0] in_data_14;
input [63:0] in_data_15;
input [63:0] in_data_16;
input [63:0] in_data_17;
input [63:0] in_data_18;
input [63:0] in_data_19;
input [63:0] in_data_20;
input [63:0] in_data_21;
input [63:0] in_data_22;
input [63:0] in_data_23;
input [63:0] in_data_24;

output [63:0] out_data_0;
output [63:0] out_data_1;
output [63:0] out_data_2;
output [63:0] out_data_3;
output [63:0] out_data_4;
output [63:0] out_data_5;
output [63:0] out_data_6;
output [63:0] out_data_7;
output [63:0] out_data_8;
output [63:0] out_data_9;
output [63:0] out_data_10;
output [63:0] out_data_11;
output [63:0] out_data_12;
output [63:0] out_data_13;
output [63:0] out_data_14;
output [63:0] out_data_15;
output [63:0] out_data_16;
output [63:0] out_data_17;
output [63:0] out_data_18;
output [63:0] out_data_19;
output [63:0] out_data_20;
output [63:0] out_data_21;
output [63:0] out_data_22;
output [63:0] out_data_23;
output [63:0] out_data_24;


// 旋转常量表 (来自Keccak规范)
// r[0][0]=0,   r[1][0]=1,   r[2][0]=62,  r[3][0]=28,  r[4][0]=27
// r[0][1]=36,  r[1][1]=44,  r[2][1]=6,   r[3][1]=55,  r[4][1]=20
// r[0][2]=3,   r[1][2]=10,  r[2][2]=43,  r[3][2]=25,  r[4][2]=39
// r[0][3]=41,  r[1][3]=45,  r[2][3]=15,  r[3][3]=21,  r[4][3]=8
// r[0][4]=18,  r[1][4]=2,   r[2][4]=61,  r[3][4]=56,  r[4][4]=14

// 第0行 (y=0) - 输出位置不变，只做循环移位
// 第0行 (y=0)
assign out_data_0  = in_data_0;                                   // (0,0) 旋转0
assign out_data_1  = {in_data_1[0], in_data_1[63:1]};            // (1,0) 循环右移1
assign out_data_2  = {in_data_2[61:0], in_data_2[63:62]};        // (2,0) 循环右移62
assign out_data_3  = {in_data_3[27:0], in_data_3[63:28]};        // (3,0) 循环右移28
assign out_data_4  = {in_data_4[26:0], in_data_4[63:27]};        // (4,0) 循环右移27

// 第1行 (y=1)
assign out_data_5  = {in_data_5[35:0], in_data_5[63:36]};        // (0,1) 循环右移36
assign out_data_6  = {in_data_6[43:0], in_data_6[63:44]};        // (1,1) 循环右移44
assign out_data_7  = {in_data_7[5:0], in_data_7[63:6]};          // (2,1) 循环右移6
assign out_data_8  = {in_data_8[54:0], in_data_8[63:55]};        // (3,1) 循环右移55
assign out_data_9  = {in_data_9[19:0], in_data_9[63:20]};        // (4,1) 循环右移20

// 第2行 (y=2)
assign out_data_10 = {in_data_10[2:0], in_data_10[63:3]};        // (0,2) 循环右移3
assign out_data_11 = {in_data_11[9:0], in_data_11[63:10]};       // (1,2) 循环右移10
assign out_data_12 = {in_data_12[42:0], in_data_12[63:43]};      // (2,2) 循环右移43
assign out_data_13 = {in_data_13[24:0], in_data_13[63:25]};      // (3,2) 循环右移25
assign out_data_14 = {in_data_14[38:0], in_data_14[63:39]};      // (4,2) 循环右移39

// 第3行 (y=3)
assign out_data_15 = {in_data_15[40:0], in_data_15[63:41]};      // (0,3) 循环右移41
assign out_data_16 = {in_data_16[44:0], in_data_16[63:45]};      // (1,3) 循环右移45
assign out_data_17 = {in_data_17[14:0], in_data_17[63:15]};      // (2,3) 循环右移15
assign out_data_18 = {in_data_18[20:0], in_data_18[63:21]};      // (3,3) 循环右移21
assign out_data_19 = {in_data_19[7:0], in_data_19[63:8]};        // (4,3) 循环右移8

// 第4行 (y=4)
assign out_data_20 = {in_data_20[17:0], in_data_20[63:18]};      // (0,4) 循环右移18
assign out_data_21 = {in_data_21[1:0], in_data_21[63:2]};        // (1,4) 循环右移2
assign out_data_22 = {in_data_22[60:0], in_data_22[63:61]};      // (2,4) 循环右移61
assign out_data_23 = {in_data_23[55:0], in_data_23[63:56]};      // (3,4) 循环右移56
assign out_data_24 = {in_data_24[13:0], in_data_24[63:14]};      // (4,4) 循环右移14

endmodule