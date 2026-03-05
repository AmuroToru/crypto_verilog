module  multi_without_add_function
#(
    parameter       MPWID       = 256
)
(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire                    start,
    input   wire    [MPWID-1:0]     in_a,
    input   wire    [MPWID-1:0]     in_b,
    output  wire    [MPWID*2-1:0]   mul, 
    output  wire                    ready
);
localparam  idle        =1'b0,
            data_in     =1'b1,
            calculate   =2'b10,
            compelete   =2'b11,
            cnt_width   =$clog2(MPWID+1'd1);

reg     [1:0]           state,next_state;
reg     [MPWID*2-1:0]  res;//保存最终结果
reg                     c,add_en;//进位寄存器
reg                     ready_reg;    
reg     [cnt_width-1:0]   cnt;//计数器，计算位移次数
reg     [MPWID-1:0]     mul_a;
reg     [MPWID:0]       add_res_reg;
reg                     cnt_mul;//cnt=0,加法，cnt=1，右移
wire                    sub,add_ready;
wire    [MPWID:0]       add_res;
assign  sub=1'd0;

assign  ready=ready_reg;
assign  mul=res;

always @(posedge clk  or  negedge  rst_n)begin
    if(!rst_n) begin
        next_state<=idle;
    end
    else begin
        case(next_state) 
            idle:if(start)
                    next_state<=data_in;
            data_in:
                    next_state<=calculate;
            calculate:if(cnt==0)
                    next_state<=compelete;
            compelete:
                    next_state<=idle;
            default
                    next_state<=idle;
        endcase
    end
end

always @(posedge clk  or  negedge  rst_n)begin
    if(!rst_n) begin
        state<=idle;
    end
    else
        state<=next_state;
end


always @(posedge clk  or  negedge  rst_n)begin
    if(!rst_n) begin
        res<=0;
        mul_a<=0;
        c<=0;
        cnt_mul<=0;
    end
    else if(state==data_in) begin
        res<={{MPWID{1'b0}},in_b};
        c<=0;
        cnt_mul<=0;
        mul_a<=in_a;
        cnt<=MPWID;
    end
    else if(state==calculate&&cnt_mul==0) begin//add
        if(res[0])begin
            if(add_ready)begin
                {c,res[MPWID*2-1:MPWID]}<=add_res_reg;
                add_en<=1'd0;
                cnt_mul<=1'd1;
            end
            else begin
                {c,res[MPWID*2-1:MPWID]}<={c,res[MPWID*2-1:MPWID]};
                add_en<=1'd1;
                cnt_mul<=1'd0;
            end
        end
        else begin
            {c,res[MPWID*2-1:MPWID]}<={1'd0,res[MPWID*2-1:MPWID]};
            cnt_mul<=1'd1;
            add_en<=1'd0;
        end
        cnt<=cnt;        
        mul_a<=mul_a;
 
    end
    else if(state==calculate&&cnt_mul==1) begin//shift
        res<={c,res[2*MPWID-1:1]};
        cnt_mul<=0;
        mul_a<=mul_a;
        c<=c;
        cnt<=cnt-1'd1;
        add_en<=1'd0;
    end
    else begin
        res<=res;
        cnt_mul<=cnt_mul;
        mul_a<=mul_a;
        c<=c;
        cnt<=cnt;
        add_en<=1'd0;
    end
end
always @(posedge clk )begin
        if(state==compelete)
            ready_reg<=1'd1;
        else
            ready_reg<=0;
end

always @(posedge clk )begin
    add_res_reg<=add_res;
end 

adder
#(
    .width(MPWID)
)
add
(
    .clk    (clk  )   ,
    .rst_n  (rst_n)   ,
    .en     (add_en)  ,
    .sub    (sub  )   ,
    .in_a   (res[MPWID*2-1:MPWID])   ,
    .in_b   (mul_a)   ,
    .res    (add_res) ,
    .ready  (add_ready)
);
endmodule