module theta
(
    in_data_0, in_data_1, in_data_2, in_data_3, in_data_4,
    in_data_5, in_data_6, in_data_7, in_data_8, in_data_9,
    in_data_10, in_data_11, in_data_12, in_data_13, in_data_14,
    in_data_15, in_data_16, in_data_17, in_data_18, in_data_19,
    in_data_20, in_data_21, in_data_22, in_data_23, in_data_24,
    out_data_0, out_data_1, out_data_2, out_data_3, out_data_4,
    out_data_5, out_data_6, out_data_7, out_data_8, out_data_9,
    out_data_10, out_data_11, out_data_12, out_data_13, out_data_14,
    out_data_15, out_data_16, out_data_17, out_data_18, out_data_19,
    out_data_20, out_data_21, out_data_22, out_data_23, out_data_24
);

input [63:0] in_data_0, in_data_1, in_data_2, in_data_3, in_data_4,
             in_data_5, in_data_6, in_data_7, in_data_8, in_data_9,
             in_data_10, in_data_11, in_data_12, in_data_13, in_data_14,
             in_data_15, in_data_16, in_data_17, in_data_18, in_data_19,
             in_data_20, in_data_21, in_data_22, in_data_23, in_data_24;

output [63:0] out_data_0, out_data_1, out_data_2, out_data_3, out_data_4,
              out_data_5, out_data_6, out_data_7, out_data_8, out_data_9,
              out_data_10, out_data_11, out_data_12, out_data_13, out_data_14,
              out_data_15, out_data_16, out_data_17, out_data_18, out_data_19,
              out_data_20, out_data_21, out_data_22, out_data_23, out_data_24;

wire [63:0] C0, C1, C2, C3, C4;
wire [63:0] D0, D1, D2, D3, D4;

// Step 1: 计算列奇偶性
assign C0 = in_data_0 ^ in_data_5 ^ in_data_10 ^ in_data_15 ^ in_data_20;
assign C1 = in_data_1 ^ in_data_6 ^ in_data_11 ^ in_data_16 ^ in_data_21;
assign C2 = in_data_2 ^ in_data_7 ^ in_data_12 ^ in_data_17 ^ in_data_22;
assign C3 = in_data_3 ^ in_data_8 ^ in_data_13 ^ in_data_18 ^ in_data_23;
assign C4 = in_data_4 ^ in_data_9 ^ in_data_14 ^ in_data_19 ^ in_data_24;

// Step 2: 计算扩散值
assign D0 = C4 ^ {C1[0], C1[63:1]};
assign D1 = C0 ^ {C2[0], C2[63:1]};
assign D2 = C1 ^ {C3[0], C3[63:1]};
assign D3 = C2 ^ {C4[0], C4[63:1]};
assign D4 = C3 ^ {C0[0], C0[63:1]};

// Step 3: 应用扩散 - 列0
assign out_data_0  = in_data_0  ^ D0;
assign out_data_5  = in_data_5  ^ D0;
assign out_data_10 = in_data_10 ^ D0;
assign out_data_15 = in_data_15 ^ D0;
assign out_data_20 = in_data_20 ^ D0;

// 列1
assign out_data_1  = in_data_1  ^ D1;
assign out_data_6  = in_data_6  ^ D1;
assign out_data_11 = in_data_11 ^ D1;
assign out_data_16 = in_data_16 ^ D1;
assign out_data_21 = in_data_21 ^ D1;

// 列2
assign out_data_2  = in_data_2  ^ D2;
assign out_data_7  = in_data_7  ^ D2;
assign out_data_12 = in_data_12 ^ D2;
assign out_data_17 = in_data_17 ^ D2;
assign out_data_22 = in_data_22 ^ D2;

// 列3
assign out_data_3  = in_data_3  ^ D3;
assign out_data_8  = in_data_8  ^ D3;
assign out_data_13 = in_data_13 ^ D3;
assign out_data_18 = in_data_18 ^ D3;
assign out_data_23 = in_data_23 ^ D3;

// 列4
assign out_data_4  = in_data_4  ^ D4;
assign out_data_9  = in_data_9  ^ D4;
assign out_data_14 = in_data_14 ^ D4;
assign out_data_19 = in_data_19 ^ D4;
assign out_data_24 = in_data_24 ^ D4;

endmodule