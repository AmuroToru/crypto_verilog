module ip
(
    input  wire [63:0] din,   // 输入64位数据
    output wire [63:0] ip_out// 初始置换输出
);

// ---------------- 初始置换 IP ----------------
/*
assign ip_out = {
    din[57], din[49], din[41], din[33], din[25], din[17], din[9],  din[1],
    din[59], din[51], din[43], din[35], din[27], din[19], din[11], din[3],
    din[61], din[53], din[45], din[37], din[29], din[21], din[13], din[5],
    din[63], din[55], din[47], din[39], din[31], din[23], din[15], din[7],
    din[56], din[48], din[40], din[32], din[24], din[16], din[8],  din[0],
    din[58], din[50], din[42], din[34], din[26], din[18], din[10], din[2],
    din[60], din[52], din[44], din[36], din[28], din[20], din[12], din[4],
    din[62], din[54], din[46], din[38], din[30], din[22], din[14], din[6]
};
*/
assign ip_out = {
    din[6],  din[14], din[22], din[30], din[38], din[46], din[54], din[62],
    din[4],  din[12], din[20], din[28], din[36], din[44], din[52], din[60],
    din[2],  din[10], din[18], din[26], din[34], din[42], din[50], din[58],
    din[0],  din[8],  din[16], din[24], din[32], din[40], din[48], din[56],
    din[7],  din[15], din[23], din[31], din[39], din[47], din[55], din[63],
    din[5],  din[13], din[21], din[29], din[37], din[45], din[53], din[61],
    din[3],  din[11], din[19], din[27], din[35], din[43], din[51], din[59],
    din[1],  din[9],  din[17], din[25], din[33], din[41], din[49], din[57]
};

endmodule