module des_keyExtension(
    input   wire        clk,            // 系统时钟
    input   wire        rst_n,          // 低电平复位
    input   wire [63:0]  key_in,         // 64位原始密钥（含8位奇偶校验位）
    input   wire        key_en,         // 密钥扩展使能
    output  reg         key_ready,
    output wire     parity_check_error,
    output  wire    [47:0] subkey1_o ,
    output  wire    [47:0] subkey2_o ,
    output  wire    [47:0] subkey3_o ,
    output  wire    [47:0] subkey4_o ,
    output  wire    [47:0] subkey5_o ,
    output  wire    [47:0] subkey6_o ,
    output  wire    [47:0] subkey7_o ,
    output  wire    [47:0] subkey8_o ,
    output  wire    [47:0] subkey9_o ,
    output  wire    [47:0] subkey10_o,
    output  wire    [47:0] subkey11_o,
    output  wire    [47:0] subkey12_o,
    output  wire    [47:0] subkey13_o,
    output  wire    [47:0] subkey14_o,
    output  wire    [47:0] subkey15_o,
    output  wire    [47:0] subkey16_o
);
reg [63:0]  key64_buff;
 //56位key拆分成c和d两部分
wire [47:0] subkey_wire;
reg [4:0]   cnt;//计数器，记录轮次
reg         pc1_flag;
reg  [28:1] left_key,right_key;
wire [28:1] left_key_wire,right_key_wire;
wire  [28:1] key_c,key_d;
wire [28:1] left1, right1;
wire [28:1] left2, right2;
wire [28:1] left3, right3;
wire [28:1] left4, right4;
wire [28:1] left5, right5;
wire [28:1] left6, right6;
wire [28:1] left7, right7;
wire [28:1] left8, right8;
wire [28:1] left9, right9;
wire [28:1] left10, right10;
wire [28:1] left11, right11;
wire [28:1] left12, right12;
wire [28:1] left13, right13;
wire [28:1] left14, right14;
wire [28:1] left15, right15;
wire [28:1] left16, right16;

reg     [55:0] subkey1 ;
reg     [55:0] subkey2 ;
reg     [55:0] subkey3 ;
reg     [55:0] subkey4 ;
reg     [55:0] subkey5 ;
reg     [55:0] subkey6 ;
reg     [55:0] subkey7 ;
reg     [55:0] subkey8 ;
reg     [55:0] subkey9 ;
reg     [55:0] subkey10;
reg     [55:0] subkey11;
reg     [55:0] subkey12;
reg     [55:0] subkey13;
reg     [55:0] subkey14;
reg     [55:0] subkey15;
reg     [55:0] subkey16;

wire    [55:0] subkey1_wire ; 
wire    [55:0] subkey2_wire ; 
wire    [55:0] subkey3_wire ; 
wire    [55:0] subkey4_wire ; 
wire    [55:0] subkey5_wire ; 
wire    [55:0] subkey6_wire ; 
wire    [55:0] subkey7_wire ; 
wire    [55:0] subkey8_wire ; 
wire    [55:0] subkey9_wire ; 
wire    [55:0] subkey10_wire;
wire    [55:0] subkey11_wire;
wire    [55:0] subkey12_wire;
wire    [55:0] subkey13_wire;
wire    [55:0] subkey14_wire;
wire    [55:0] subkey15_wire;
wire    [55:0] subkey16_wire;




assign parity_check_error=~((^key64_buff[7:0])&(^key64_buff[15:8])&(^key64_buff[23:16])&(^key64_buff[31:24])&(^key64_buff[39:32])&(^key64_buff[47:40])&(^key64_buff[55:48])&(^key64_buff[63:56]));


        
assign  left1  = {key_c[27:1],key_c[28]};
assign  right1 = {key_d[27:1],key_d[28]};
        
        
assign  left2  = {left1[27:1],left1[28]}; 
assign  right2 = {right1[27:1],right1[28]};
        
assign  left3  = {left2[26:1],left2[28:27]}; 
assign  right3 = {right2[26:1],right2[28:27]};

assign  left4  = {left3[26:1],left3[28:27]}; 
assign  right4 = {right3[26:1],right3[28:27]};

assign  left5  = {left4[26:1],left4[28:27]}; 
assign  right5 = {right4[26:1],right4[28:27]};

assign  left6  = {left5[26:1],left5[28:27]}; 
assign  right6 = {right5[26:1],right5[28:27]};

assign  left7  = {left6[26:1],left6[28:27]}; 
assign  right7 = {right6[26:1],right6[28:27]};

       
assign  left8  = {left7[26:1],left7[28:27]}; 
assign  right8 = {right7[26:1],right7[28:27]};
        

assign  left9  = {left8[27:1],left8[28]}; 
assign  right9 = {right8[27:1],right8[28]};

assign  left10  ={left9[26:1],left9[28:27]}; 
assign  right10 ={right9[26:1],right9[28:27]};

assign  left11  ={left10[26:1],left10[28:27]}; 
assign  right11 ={right10[26:1],right10[28:27]};

assign  left12  ={left11[26:1],left11[28:27]}; 
assign  right12 ={right11[26:1],right11[28:27]};

assign  left13  ={left12[26:1],left12[28:27]}; 
assign  right13 ={right12[26:1],right12[28:27]};

assign  left14  ={left13[26:1],left13[28:27]}; 
assign  right14 ={right13[26:1],right13[28:27]};

        
assign  left15  ={left14[26:1],left14[28:27]}; 
assign  right15 ={right14[26:1],right14[28:27]};

assign  left16  ={left15[27:1],left15[28]}; 
assign  right16  ={right15[27:1],right15[28]};


assign subkey1_wire =subkey1 ;
assign subkey2_wire =subkey2 ;
assign subkey3_wire =subkey3 ;
assign subkey4_wire =subkey4 ;
assign subkey5_wire =subkey5 ;
assign subkey6_wire =subkey6 ;
assign subkey7_wire =subkey7 ;
assign subkey8_wire =subkey8 ;
assign subkey9_wire =subkey9 ;
assign subkey10_wire=subkey10;
assign subkey11_wire=subkey11;
assign subkey12_wire=subkey12;
assign subkey13_wire=subkey13;
assign subkey14_wire=subkey14;
assign subkey15_wire=subkey15;
assign subkey16_wire=subkey16;







//PC_1置换
des_pc1 pc1_inst
(
    .in_64(key64_buff),
    .key_c(key_c),
    .key_d(key_d)
);


always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        key64_buff<=64'd0;
        pc1_flag<=1'b0;
    end
    else if(key_en) begin
        pc1_flag<=1'b1;
        key64_buff<=key_in;
    end
    else begin
        pc1_flag<=pc1_flag;
        key64_buff<=key64_buff;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt<=5'd0;
        key_ready<=0;
        subkey1 <=0;
        subkey2 <=0;
        subkey3 <=0;
        subkey4 <=0;
        subkey5 <=0;
        subkey6 <=0;
        subkey7 <=0;
        subkey8 <=0;
        subkey9 <=0;
        subkey10<=0;
        subkey11<=0;
        subkey12<=0;
        subkey13<=0;
        subkey14<=0;
        subkey15<=0;
        subkey16<=0;
     
    end
    else if(pc1_flag)begin
        case(cnt)
            5'd0:begin
                cnt<=cnt+1;
            end
            5'd1,5'd2:begin
                cnt<=cnt+1;
                subkey1<={left1,right1};
                key_ready<=1'd0;
            end
            5'd3,5'd4:begin
                cnt<=cnt+1;
                subkey2<={left2,right2};
                key_ready<=1'd0;

            end
            5'd5,5'd6:begin
                cnt<=cnt+1;
                subkey3<={left3,right3};
                key_ready<=1'd0;
            end
            5'd7,5'd8:begin
                cnt<=cnt+1;
                subkey4<={left4,right4};
                key_ready<=1'd0;
            end
            5'd9,5'd10:begin
                cnt<=cnt+1;
                subkey5<={left5,right5};
                key_ready<=1'd0;
            end
            5'd11,5'd12:begin
                cnt<=cnt+1;
                subkey6<={left6,right6};
                key_ready<=1'd0;
            end
            5'd13,5'd14:begin
                cnt<=cnt+1;
                subkey7<={left7,right7};
                key_ready<=1'd0;
            end
            5'd15,5'd16:begin
                cnt<=cnt+1;
                subkey8<={left8,right8};
                key_ready<=1'd0;
            end
            5'd17,5'd18:begin
                cnt<=cnt+1;
                subkey9<={left9,right9};
                key_ready<=1'd0;
            end
            5'd19,5'd20:begin
                cnt<=cnt+1;
                subkey10<={left10,right10};
                key_ready<=1'd0;
            end
            5'd21,5'd22:begin
                cnt<=cnt+1;
                subkey11<={left11,right11};
                key_ready<=1'd0;
            end
            5'd23,5'd24:begin
                  cnt<=cnt+1;
                subkey12<={left12,right12};
                key_ready<=1'd0;
            end
            5'd25,5'd26:begin
                cnt<=cnt+1;
                subkey13<={left13,right13};
                key_ready<=1'd0;
            end
            5'd27,5'd28:begin
                cnt<=cnt+1;
                subkey14<={left14,right14};
                key_ready<=1'd0;
            end
            5'd29,5'd30:begin
                cnt<=cnt+1;
                subkey15<={left15,right15};
                key_ready<=1'd0;
            end
            5'd31:begin
                cnt<=cnt;
                subkey16<={left16,right16};
                key_ready<=1'd1;
            end
            default:begin
                cnt<=cnt;
                key_ready<=key_ready;
                subkey1 <=subkey1;
                subkey2 <=subkey2;
                subkey3 <=subkey3;
                subkey4 <=subkey4;
                subkey5 <=subkey5;
                subkey6 <=subkey6;
                subkey7 <=subkey7;
                subkey8 <=subkey8;
                subkey9 <=subkey9;
                subkey10<=subkey10;
                subkey11<=subkey11;
                subkey12<=subkey12;
                subkey13<=subkey13;
                subkey14<=subkey14;
                subkey15<=subkey15;
                subkey16<=subkey16;
            end
            endcase
    end
    else begin
                cnt<=cnt;
                key_ready<=key_ready;
                subkey1 <=subkey1;
                subkey2 <=subkey2;
                subkey3 <=subkey3;
                subkey4 <=subkey4;
                subkey5 <=subkey5;
                subkey6 <=subkey6;
                subkey7 <=subkey7;
                subkey8 <=subkey8;
                subkey9 <=subkey9;
                subkey10<=subkey10;
                subkey11<=subkey11;
                subkey12<=subkey12;
                subkey13<=subkey13;
                subkey14<=subkey14;
                subkey15<=subkey15;
                subkey16<=subkey16;
    end
end


    
    
des_pc2  des_pc2_inst1
(
    .li_28(subkey1_wire[55:28]),
    .ri_28(subkey1_wire[27:0]),
    .kout_48(subkey1_o)
);

des_pc2  des_pc2_inst2
(
    .li_28(subkey2_wire[55:28]),
    .ri_28(subkey2_wire[27:0]),
    .kout_48(subkey2_o)
);

des_pc2  des_pc2_inst3
(
    .li_28(subkey3_wire[55:28]),
    .ri_28(subkey3_wire[27:0]),
    .kout_48(subkey3_o)
);

des_pc2  des_pc2_inst4
(
    .li_28(subkey4_wire[55:28]),
    .ri_28(subkey4_wire[27:0]),
    .kout_48(subkey4_o)
);

des_pc2  des_pc2_inst5
(
    .li_28(subkey5_wire[55:28]),
    .ri_28(subkey5_wire[27:0]),
    .kout_48(subkey5_o)
);

des_pc2  des_pc2_inst6
(
    .li_28(subkey6_wire[55:28]),
    .ri_28(subkey6_wire[27:0]),
    .kout_48(subkey6_o)
);

des_pc2  des_pc2_inst7
(
    .li_28(subkey7_wire[55:28]),
    .ri_28(subkey7_wire[27:0]),
    .kout_48(subkey7_o)
);

des_pc2  des_pc2_inst8
(
    .li_28(subkey8_wire[55:28]),
    .ri_28(subkey8_wire[27:0]),
    .kout_48(subkey8_o)
);

des_pc2  des_pc2_inst9
(
    .li_28(subkey9_wire[55:28]),
    .ri_28(subkey9_wire[27:0]),
    .kout_48(subkey9_o)
);

des_pc2  des_pc2_inst10
(
    .li_28(subkey10_wire[55:28]),
    .ri_28(subkey10_wire[27:0]),
    .kout_48(subkey10_o)
);

des_pc2  des_pc2_inst11
(
    .li_28(subkey11_wire[55:28]),
    .ri_28(subkey11_wire[27:0]),
    .kout_48(subkey11_o)
);

des_pc2  des_pc2_inst12
(
    .li_28(subkey12_wire[55:28]),
    .ri_28(subkey12_wire[27:0]),
    .kout_48(subkey12_o)
);

des_pc2  des_pc2_inst13
(
    .li_28(subkey13_wire[55:28]),
    .ri_28(subkey13_wire[27:0]),
    .kout_48(subkey13_o)
);

des_pc2  des_pc2_inst14
(
    .li_28(subkey14_wire[55:28]),
    .ri_28(subkey14_wire[27:0]),
    .kout_48(subkey14_o)
);

des_pc2  des_pc2_inst15
(
    .li_28(subkey15_wire[55:28]),
    .ri_28(subkey15_wire[27:0]),
    .kout_48(subkey15_o)
);

des_pc2  des_pc2_inst16
(
    .li_28(subkey16_wire[55:28]),
    .ri_28(subkey16_wire[27:0]),
    .kout_48(subkey16_o)
);

endmodule