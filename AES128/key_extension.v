module key_extension(
    input   wire            clk,
    input   wire            rst_n,
    input   wire [127:0]    key_in,
    output  wire [127:0]    key1,
    output  wire [127:0]    key2,
    output  wire [127:0]    key3,
    output  wire [127:0]    key4,
    output  wire [127:0]    key5,
    output  wire [127:0]    key6,
    output  wire [127:0]    key7,
    output  wire [127:0]    key8,
    output  wire [127:0]    key9,
    output  wire [127:0]    key10,
    output  reg             key_ready
);

wire    key1_ready,key2_ready,key3_ready,key4_ready,key5_ready,key6_ready,key7_ready,key8_ready,key9_ready,key10_ready;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        key_ready<=0;
    else
        key_ready<=key1_ready && key2_ready && key3_ready && key4_ready && key5_ready && key6_ready && key7_ready && key8_ready && key9_ready && key10_ready;
end

key_round key_round1(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key_in),
    .round(4'd1),
    .key_out(key1),
    .key_ready(key1_ready)
);
key_round key_round2(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key1),
    .round(4'd2),
    .key_out(key2),
    .key_ready(key2_ready)
);
key_round key_round3(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key2),
    .round(4'd3),
    .key_out(key3),
    .key_ready(key3_ready)
);
key_round key_round4(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key3),
    .round(4'd4),
    .key_out(key4),
    .key_ready(key4_ready)
);
key_round key_round5(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key4),
    .round(4'd5),
    .key_out(key5),
    .key_ready(key5_ready)
);
key_round key_round6(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key5),
    .round(4'd6),
    .key_out(key6),
    .key_ready(key6_ready)
);
key_round key_round7(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key6),
    .round(4'd7),
    .key_out(key7),
    .key_ready(key7_ready)
);
key_round key_round8(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key7),
    .round(4'd8),
    .key_out(key8),
    .key_ready(key8_ready)
);
key_round key_round9(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key8),
    .round(4'd9),
    .key_out(key9),
    .key_ready(key9_ready)
);
key_round key_round10(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key9),
    .round(4'd10),
    .key_out(key10),
    .key_ready(key10_ready)
);
endmodule