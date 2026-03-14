module chi
(
    input  [63:0] in0, in1, in2, in3, in4,
    input  [63:0] in5, in6, in7, in8, in9,
    input  [63:0] in10, in11, in12, in13, in14,
    input  [63:0] in15, in16, in17, in18, in19,
    input  [63:0] in20, in21, in22, in23, in24,
    
    output [63:0] out0, out1, out2, out3, out4,
    output [63:0] out5, out6, out7, out8, out9,
    output [63:0] out10, out11, out12, out13, out14,
    output [63:0] out15, out16, out17, out18, out19,
    output [63:0] out20, out21, out22, out23, out24
);

// Chi: out[x][y] = in[x][y] ^ ((~in[(x+1)%5][y]) & in[(x+2)%5][y])


// 第0行 (y=0)
assign out0 = in0 ^ ((~in1) & in2);
assign out1 = in1 ^ ((~in2) & in3);
assign out2 = in2 ^ ((~in3) & in4);
assign out3 = in3 ^ ((~in4) & in0);
assign out4 = in4 ^ ((~in0) & in1);

// 第1行 (y=1)
assign out5 = in5 ^ ((~in6) & in7);
assign out6 = in6 ^ ((~in7) & in8);
assign out7 = in7 ^ ((~in8) & in9);
assign out8 = in8 ^ ((~in9) & in5);
assign out9 = in9 ^ ((~in5) & in6);

// 第2行 (y=2)
assign out10 = in10 ^ ((~in11) & in12);
assign out11 = in11 ^ ((~in12) & in13);
assign out12 = in12 ^ ((~in13) & in14);
assign out13 = in13 ^ ((~in14) & in10);
assign out14 = in14 ^ ((~in10) & in11);

// 第3行 (y=3)
assign out15 = in15 ^ ((~in16) & in17);
assign out16 = in16 ^ ((~in17) & in18);
assign out17 = in17 ^ ((~in18) & in19);
assign out18 = in18 ^ ((~in19) & in15);
assign out19 = in19 ^ ((~in15) & in16);

// 第4行 (y=4)
assign out20 = in20 ^ ((~in21) & in22);
assign out21 = in21 ^ ((~in22) & in23);
assign out22 = in22 ^ ((~in23) & in24);
assign out23 = in23 ^ ((~in24) & in20);
assign out24 = in24 ^ ((~in20) & in21);

endmodule