module  montgomery_mod_multi
#(
    parameter       MPWID = 256
)
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                start,
    input   wire    [MPWID-1:0] in_a,
    input   wire    [MPWID-1:0] in_b,
    input   wire    [MPWID-1:0] in_n,
    input   wire    [MPWID-1:0] R2modN,
    output  reg     [MPWID-1:0] res ,
    output  reg                 ready
);
localparam  IDLE    =   3'd0,
            LOAD    =   3'd1,
            CAL_aR2 =   3'd2,
            CAL_bR2 =   3'd3,
            CAL_abR =   3'd4,
            CAL_ab  =   3'd5,
            DONE    =   3'd6;
            
reg     [MPWID-1:0]     R2;
reg     [MPWID-1:0]     a,b,n,Ma,Mb;
reg     [MPWID:0]       R;
reg                     Men;
reg     [2:0]           state,next_state;
wire    [MPWID-1:0]     Minv;
wire                    Mready;    

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state<=IDLE;
    end
    else begin
        state<=next_state;
    end
end  

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        next_state<=IDLE;
    end
    else begin
        case(state)
            IDLE:begin
                if(start)next_state<=LOAD;
                else    next_state<=next_state;
            end
            LOAD:next_state<=CAL_aR2;
            CAL_aR2:begin
                if(Mready)
                    next_state<=CAL_bR2;
                else
                    next_state<=next_state;
            end
            CAL_bR2:begin
                if(Mready)
                    next_state<=CAL_abR;
                else
                    next_state<=next_state;
            end
            CAL_abR:begin
                if(Mready)
                    next_state<=CAL_ab;
                else
                    next_state<=next_state;                
            end
            CAL_ab:begin
                if(Mready)
                    next_state<=DONE;
                else
                    next_state<=next_state;             
            end
            DONE:next_state<=IDLE;
            default:next_state<=IDLE;
        endcase
    end
end  

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        n<=0;
        R2<=0;
        R<=0;
    end
    else if(state==LOAD)begin
        n<=in_n;
        R2<=R2modN;
        R<={1'd1,{(MPWID){1'd0}}};
    end
    else if(state==IDLE) begin
        n<=0;
        R2<=0;
        R<=0;
    end
    else begin
        n<=n;
        R2<=R2;
        R<=R;
    end
end 

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        a<=0;
        b<=0;
        res<=0;
        Men<=0;
        Ma<=0;
        Mb<=0;
    end
    else begin
        case(state)
            IDLE:begin
                a<=0;
                b<=0;
                res<=0;
                Men<=0;
                Ma<=0;
                Mb<=0;            
            end
            LOAD:begin
                a<=in_a;
                b<=in_b;
                res<=0;
                Men<=0;
                Ma<=0;
                Mb<=0;
            end
            CAL_aR2:begin
                res<=0;
                b<=b;
                if(Mready)begin
                    a<=Minv;
                    Men<=0;
                    Ma<=0;
                    Mb<=0;
                end
                else begin
                    a<=a;
                    Men<=1'd1;
                    Ma<=a;
                    Mb<=R2;
                end
            end
            CAL_bR2:begin
                res<=0;
                a<=a;
                if(Mready)begin
                    b<=Minv;
                    Men<=0;
                    Ma<=0;
                    Mb<=0;
                end
                else begin
                    b<=b;
                    Men<=1'd1;
                    Ma<=b;
                    Mb<=R2;
                end            
            end
            CAL_abR:begin
                res<=0;
                if(Mready)begin
                    a<=Minv;
                    b<=b;
                    Men<=0;
                    Ma<=0;
                    Mb<=0;
                end
                else begin
                    a<=a;
                    b<=b;
                    Men<=1'd1;
                    Ma<=a;
                    Mb<=b;
                end            
            end
            CAL_ab:begin
                a<=a;
                b<=b;
                if(Mready)begin
                    res<=Minv;
                    Men<=0;
                    Ma<=0;
                    Mb<=0;
                end
                else begin
                    Men<=1'd1;
                    Ma<=a;
                    Mb<=1;
                end            
            end
            default:begin
                a<=a;
                b<=b;
                res<=res;
                Men<=0;
                Ma<=0;
                Mb<=0;
            end
        endcase
    end
end 
always@(posedge clk ) begin
    if(state==DONE) begin
        ready<=1'd1;
    end
    else begin
        ready<=0;
    end
end

 radix2_montgomery_redc
#(
    .width(MPWID)
)
u
(
    .clk(clk),
    .rst_n(rst_n),
    .en(Men),
    .in_a(Ma),
    .in_b(Mb),
    .in_n(n),
    .abRinv(Minv),
    .ready(Mready)
);
endmodule