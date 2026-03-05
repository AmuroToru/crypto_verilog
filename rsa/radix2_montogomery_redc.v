/***
module radix2_montgomery_redc
//initial T=0 
//T=a*b[i]+T
//if T%2=1  T=(T+n)/2
//else T=T/2


#(
    parameter   width   =   256
)
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                en,
    input   wire    [width-1:0] in_a,
    input   wire    [width-1:0] in_b,
    input   wire    [width-1:0] in_n,
    output  reg     [width-1:0] abRinv,
    output  reg                 ready
);

localparam  IDLE        = 0,
            LOAD        = 1,
            ADDa        = 2,
            ADDn        = 3,
            SHIFT       = 4,
            SUBn        = 5,
            DONE        = 6,
            cnt_width   = $clog2(width);
            
            
reg     [2:0]               state,next_state;
reg                         add_en,sub,cnt_shift;
reg     [width-1:0]         a,b,n,add2;
reg     [width:0]           T;
reg     [cnt_width:0]       cnt;
wire    [width:0]           T_wire;
wire                        add_ready;  
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        next_state<=IDLE;
    end
    else    begin
        case(state)
            IDLE:begin 
                    if(en)
                        next_state<=LOAD;
                    else
                        next_state<=next_state;
                end
            LOAD:next_state<=ADDa;
            ADDa: begin
                        if(add_ready) begin
                            if(T_wire[0]==1'd1)
                                next_state<=ADDn;
                            else
                                next_state<=SHIFT;
                        end
                        else next_state<=next_state;
                end
            ADDn:begin
                    if(add_ready)
                        next_state<=SHIFT;
                    else
                        next_state<=next_state;
                end
            SHIFT:begin
                    if(cnt==0&&T_wire[width-1:0]<n)
                        next_state<=DONE;
                    else  if(cnt==0&&T_wire[width-1:0]>=n)
                        next_state<=SUBn;
                    else
                        next_state<=ADDa;
                end
            SUBn:begin
                if(add_ready)
                    next_state<=DONE;
                else next_state<=next_state;
            end
            DONE:next_state<=IDLE;
        endcase
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state<=IDLE;
    else    state<=next_state;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        abRinv<=0;
        ready<=0;
    end
    else begin 
    case(state)
        DONE:begin
            abRinv<=T[width-1:0];
            ready<=1'd1;
        end
        default begin
            abRinv<=0;
            ready<=0;
        end
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_shift<=0;
        a<=0;
        b<=0;
        add_en<=0;
        T<=0;
        add2<=0;
        cnt<=width;
        sub<=0;
    end
    else  begin
        case(state)
            LOAD: begin
                a<=in_a;
                b<=in_b;
                add_en<=0;
                T<=0;
                add2<=0;
                cnt<=cnt;
                sub<=0;
                cnt_shift<=0;
            end
            ADDa:begin
                if(add_ready) begin
                    T<=T_wire;
                    add_en<=1'd0;
                    add2<=0;
                    
                end
                else if(b[0])   begin
                    T<=T;
                    add_en<=1'd1;
                    add2<=a;
                end
                else if(!b[0]) begin
                    T<=T;
                    add_en<=1'd1;
                    add2<=0;
                end
                else begin
                    T<=T;
                    add_en<=add_en;
                    add2<=add2;
                end
                a<=a;
                b<=b;
                cnt<=cnt;
                sub<=0;
                cnt_shift<=0;
            end
            ADDn: begin
                if(add_ready) begin
                    T<=T_wire;
                    add_en<=1'd0;
                    add2<=0;
                    
                end
                else begin
                    T<=T;
                    add_en<=1'd1;
                    add2<=n;
                end
                a<=a;
                b<=b;
                cnt<=cnt;
                sub<=0;
                cnt_shift<=0;
            end
            SHIFT:begin
              if(cnt_shift==0)  begin
                b<=b>>1'd1;
                T<=T>>1'd1;
                cnt<=cnt-1'd1;
                end
              else begin
                b<=b;
                T<=T;
                cnt<=cnt;
                
              end
                a<=a;
                add_en<=0;
                add2<=0;
                sub<=0;
                cnt_shift<=cnt_shift+1'd1;
            end
            SUBn:begin
                if(add_ready) begin
                    T<=T_wire;
                    add_en<=1'd0;
                    add2<=0;
                    sub<=0;
                    
                end
                else begin
                    T<=T;
                    add_en<=add_en;
                    add2<=n;
                    sub<=1'd1;
                end
                a<=a;
                b<=b;
                cnt<=cnt;
                cnt_shift<=0;
            end
            default:begin
                b<=b;
                T<=T;
                a<=a;
                add_en<=0;
                cnt<=cnt;
                add2<=0;
                sub<=0;
                cnt_shift<=0;
            end
        endcase
    end
end
always@(posedge clk )begin
    if(!rst_n)
        n<=0;
    else if(state==LOAD)
        n<=in_n;
    else
        n<=n;
end  
adder
#(
    .width(width)
)
add
(
    .clk    (clk  )   ,
    .rst_n  (rst_n)   ,
    .en     (add_en)  ,
    .sub    (sub  )   ,
    .in_a   (T[width-1:0])  ,
    .in_b   (add2)   ,
    .res    (T_wire) ,
    .ready  (add_ready)
);
endmodule
***/
module radix2_montgomery_redc
//initial T=0 
//T=a*b[i]+T
//if T%2=1  T=(T+n)/2
//else T=T/2


#(
    parameter   width   =   256
)
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                en,
    input   wire    [width-1:0] in_a,
    input   wire    [width-1:0] in_b,
    input   wire    [width-1:0] in_n,
    output  reg     [width-1:0] abRinv,
    output  reg                 ready
);

localparam  IDLE        = 0,
            LOAD        = 1,
            ADDa        = 2,
            ADDn        = 3,
            SHIFT       = 4,
            SUBn        = 5,
            DONE        = 6,
            cnt_width   = $clog2(width);
            
            
reg     [2:0]               state,next_state;
reg                         add_en,sub,cnt_shift,cnt_shift1;
reg     [width-1:0]         a,b,n,add2;
reg     [width+1:0]             T;
reg     [cnt_width:0]       cnt;
wire    [width:0]           T_wire;
wire                        add_ready;  
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        next_state<=IDLE;
    end
    else    begin
        case(state)
            IDLE:begin 
                    if(en)
                        next_state<=LOAD;
                    else
                        next_state<=next_state;
                end
            LOAD:next_state<=ADDa;
            ADDa: begin
                        if(add_ready) begin
                            if(T_wire[0]==1'd1)
                                next_state<=ADDn;
                            else
                                next_state<=SHIFT;
                        end
                        else next_state<=next_state;
                end
            ADDn:begin
                    if(add_ready)
                        next_state<=SHIFT;
                    else
                        next_state<=next_state;
                end
            SHIFT:begin
                    if(cnt==0&&T_wire[width-1:0]<n)
                        next_state<=DONE;
                    else  if(cnt==0&&T_wire[width-1:0]>=n)
                        next_state<=SUBn;
                    else
                        next_state<=ADDa;
                end
            SUBn:begin
                if(add_ready)
                    next_state<=DONE;
                else next_state<=next_state;
            end
            DONE:next_state<=IDLE;
        endcase
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state<=IDLE;
    else    state<=next_state;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        abRinv<=0;
        ready<=0;
    end
    else begin 
    case(state)
        DONE:begin
            abRinv<=T[width-1:0];
            ready<=1'd1;
        end
        default begin
            abRinv<=0;
            ready<=0;
        end
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_shift<=0;
        a<=0;
        b<=0;
        add_en<=0;
        T<=0;
        add2<=0;
        cnt<=width;
        sub<=0;
        cnt_shift1<=0;
    end
    else  begin
        case(state)
            LOAD: begin
                a<=in_a;
                b<=in_b;
                add_en<=0;
                T<=0;
                add2<=0;
                cnt<=width;
                sub<=0;
                cnt_shift<=0;
                cnt_shift1<=0;
            end
            ADDa:begin
                if(add_ready) begin
                    if(cnt_shift==1'd0) begin
                        T <= T;
                        add_en<=1'd0;
                        add2<=0;
                        cnt<=cnt-1'd1;
                        cnt_shift<=1'd1;
                    end
                    else begin
                        T <= {T[width] + T_wire[width], T_wire[width-1:0]};
                        add_en<=1'd0;
                        add2<=0;
                        cnt<=cnt;
                        cnt_shift<=1'd0;                    
                    end
                end
                else if(b[0])   begin
                    T<=T;
                    add_en<=1'd1;
                    add2<=a;
                    cnt<=cnt;
                end
                else if(!b[0]) begin
                    T<=T;
                    add_en<=1'd1;
                    add2<=0;
                    cnt<=cnt;
                end
                else begin
                    T<=T;
                    add_en<=add_en;
                    add2<=add2;
                    cnt<=cnt;
                end
                a<=a;
                b<=b;
                sub<=0;
            end
            ADDn: begin
                if(add_ready) begin
                    if(cnt_shift1==1'd1)begin
                     T <= T;
                     cnt_shift1<=1'd0;
                    end
                    else begin
                     T<={T[width+1:width] + T_wire[width], T_wire[width-1:0]};
                     cnt_shift1<=1'd1;
                    end
                     add_en<=1'd0;
                     add2<=0;
                end
                else begin
                    T<=T;
                    add_en<=1'd1;
                    add2<=n;
                end
                a<=a;
                b<=b;
                cnt<=cnt;
                sub<=0;
                cnt_shift<=0;
            end
            SHIFT:begin
              if(cnt_shift==0)  begin
                b<=b>>1'd1;
                T<=T>>1'd1;
                end
              else begin
                b<=b;
                T<=T;
                
              end
                a<=a;
                add_en<=0;
                add2<=0;
                sub<=0;
                cnt<=cnt;
                cnt_shift<=cnt_shift+1'd1;
            end
            SUBn:begin
                if(add_ready) begin
                    T<=T_wire;
                    add_en<=1'd0;
                    add2<=0;
                    sub<=0;
                    
                end
                else begin
                    T<=T;
                    add_en<=add_en;
                    add2<=n;
                    sub<=1'd1;
                end
                a<=a;
                b<=b;
                cnt<=cnt;
                cnt_shift<=0;
            end
            default:begin
                b<=b;
                T<=T;
                a<=a;
                add_en<=0;
                cnt<=cnt;
                add2<=0;
                sub<=0;
                cnt_shift<=0;
                cnt_shift1<=0;
            end
        endcase
    end
end
always@(posedge clk )begin
    if(!rst_n)
        n<=0;
    else if(state==LOAD)
        n<=in_n;
    else
        n<=n;
end  
adder
#(
    .width(width)
)
add
(
    .clk    (clk  )   ,
    .rst_n  (rst_n)   ,
    .en     (add_en)  ,
    .sub    (sub  )   ,
    .in_a   (T[width-1:0])  ,
    .in_b   (add2)   ,
    .res    (T_wire) ,
    .ready  (add_ready)
);
endmodule