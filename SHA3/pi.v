module pi
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

// output
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



// (0,0) -> (0,0) : out[0] <= in[0]
assign out_data_0  = in_data_0;

// (1,0) -> (0,2) : out[10] <= in[1]  (因为y'=2, x'=0 -> 5*2+0=10)
assign out_data_10 = in_data_1;

// (2,0) -> (0,4) : out[20] <= in[2]  (y'=4, x'=0 -> 5*4+0=20)
assign out_data_20 = in_data_2;

// (3,0) -> (0,1) : out[5] <= in[3]   (y'=1, x'=0 -> 5*1+0=5)
assign out_data_5  = in_data_3;

// (4,0) -> (0,3) : out[15] <= in[4]  (y'=3, x'=0 -> 5*3+0=15)
assign out_data_15 = in_data_4;

// (0,1) -> (1,3) : out[16] <= in[5]  (y'=3, x'=1 -> 5*3+1=16)
assign out_data_16 = in_data_5;

// (1,1) -> (1,0) : out[1] <= in[6]   (y'=0, x'=1 -> 5*0+1=1)
assign out_data_1  = in_data_6;

// (2,1) -> (1,2) : out[11] <= in[7]  (y'=2, x'=1 -> 5*2+1=11)
assign out_data_11 = in_data_7;

// (3,1) -> (1,4) : out[21] <= in[8]  (y'=4, x'=1 -> 5*4+1=21)
assign out_data_21 = in_data_8;

// (4,1) -> (1,1) : out[6] <= in[9]   (y'=1, x'=1 -> 5*1+1=6)
assign out_data_6  = in_data_9;

// (0,2) -> (2,1) : out[7] <= in[10]  (y'=1, x'=2 -> 5*1+2=7)
assign out_data_7  = in_data_10;

// (1,2) -> (2,3) : out[17] <= in[11] (y'=3, x'=2 -> 5*3+2=17)
assign out_data_17 = in_data_11;

// (2,2) -> (2,0) : out[2] <= in[12]  (y'=0, x'=2 -> 5*0+2=2)
assign out_data_2  = in_data_12;

// (3,2) -> (2,2) : out[12] <= in[13] (y'=2, x'=2 -> 5*2+2=12)
assign out_data_12 = in_data_13;

// (4,2) -> (2,4) : out[22] <= in[14] (y'=4, x'=2 -> 5*4+2=22)
assign out_data_22 = in_data_14;

// (0,3) -> (3,4) : out[23] <= in[15] (y'=4, x'=3 -> 5*4+3=23)
assign out_data_23 = in_data_15;

// (1,3) -> (3,1) : out[8] <= in[16]  (y'=1, x'=3 -> 5*1+3=8)
assign out_data_8  = in_data_16;

// (2,3) -> (3,3) : out[18] <= in[17] (y'=3, x'=3 -> 5*3+3=18)
assign out_data_18 = in_data_17;

// (3,3) -> (3,0) : out[3] <= in[18]  (y'=0, x'=3 -> 5*0+3=3)
assign out_data_3  = in_data_18;

// (4,3) -> (3,2) : out[13] <= in[19] (y'=2, x'=3 -> 5*2+3=13)
assign out_data_13 = in_data_19;

// (0,4) -> (4,2) : out[14] <= in[20] (y'=2, x'=4 -> 5*2+4=14)
assign out_data_14 = in_data_20;

// (1,4) -> (4,4) : out[24] <= in[21] (y'=4, x'=4 -> 5*4+4=24)
assign out_data_24 = in_data_21;

// (2,4) -> (4,1) : out[9] <= in[22]  (y'=1, x'=4 -> 5*1+4=9)
assign out_data_9  = in_data_22;

// (3,4) -> (4,3) : out[19] <= in[23] (y'=3, x'=4 -> 5*3+4=19)
assign out_data_19 = in_data_23;

// (4,4) -> (4,0) : out[4] <= in[24]  (y'=0, x'=4 -> 5*0+4=4)
assign out_data_4  = in_data_24;

endmodule