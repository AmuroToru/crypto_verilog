
module adder
#(
    parameter width     =   256
)
(
    input   wire                    clk     ,
    input   wire                    rst_n   ,
    input   wire                    en      ,
    input   wire                    sub     ,
    input   wire    [width-1:0]     in_a    ,
    input   wire    [width-1:0]     in_b    ,
    output  reg     [width:0]       res     ,
    output  reg                     ready
);
localparam  cnt_width   =   $clog2(width/128+1'd1),
            round       =   width/128,
            idle        =   0,
            load        =   1,
            add         =   2,
            done        =   3;

reg     [width-1:0]     a,b;
reg                     c,substract;//进位
reg     [1:0]           state,next_state;
reg     [cnt_width-1:0] cnt;
wire    [128:0]         mid_res;
assign  mid_res=a[127:0]+b[127:0]+c;


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        next_state<=idle;
    end
    else begin
        case(state)
            idle:begin
                if(en) next_state<=load;
                else   next_state<=next_state;
                end
            load:begin 
                next_state<=add;
                end
            add:begin
                if(!cnt)
                    next_state<=done;
                else
                    next_state<=next_state;
                end
            done:next_state<=idle;
        endcase
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) state<=idle;
    else state<=next_state;

end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        a<=0;
        b<=0;
        res<=0;
        c<=0;
        cnt<=round;
    end
    else  begin
        case(state)
        idle:begin
            a<=0;
            b<=0;
            res<=0;
            c<=0;
            cnt<=round;
        end
        load:begin
            a<=in_a;
            res<=0;
            c<=sub;
            cnt<=round;
            if(sub) b<=~in_b;
            else    b<=in_b;
        end
        add:begin
            if(cnt!=1'd0) begin
                res<={1'd0,mid_res[127:0],res[width-1:128]};
                c<=mid_res[128];
                a<=a>>128;
                b<=b>>128;
                cnt<=cnt-1'd1;
            end
            else begin
                a<=a;
                b<=b;
                res<=res;
                c<=c;
                cnt<=cnt;
            end
        end
        done:begin
            a<=a;
            b<=b;
            res[width]<=c^substract;
            res[width-1:0]<=res[width-1:0];
            c<=c;
            cnt<=cnt;            
        end
        default:begin
            a<=a;
            b<=b;
            c<=c;
            res<=res;
            cnt<=cnt; 
        end
        endcase
    end
end

always@(posedge clk) begin
    if(state==done&&rst_n)
        ready<=1'd1;
    else
        ready<=1'd0;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        substract<=1'd0;
    else if(state==load)
        substract<=sub;
    else
        substract<=substract;
end
endmodule