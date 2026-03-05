module RSA
//enc or dec
//data stream high→low
#(
parameter   width       =   256
 
)
(
input   wire                clk,
input   wire                rst_n,
input   wire                en,
input   wire    [7:0]       in_N,
input   wire    [7:0]       in_key,//enc:e  dec:d
input   wire    [7:0]       in_data,
output  reg     [7:0]       out_data,
output  reg                 ready,
output  reg                 out_start

);
localparam      in_round    =        $clog2(width/8+1),
                cnt         =                width/8 ,
                IDLE        =                        0,
                LOAD        =                        1,
                CALR2       =                        2,
                CASE0       =                        3,//key lsb 0
                CASE1       =                        4,//key lsb 1
                SHIFT       =                        5,
                OUT         =                        6,
                DONE        =                        7;
                
                

reg     [width-1:0]         mod_n,data,key,mide_value,R2modN,mod_a,mod_b;
reg     [2:0]               state,next_state;
reg     [in_round-1:0]      round;
reg                         mod_start,divid_en,c;
wire                        mod_ready,divid_ready;
wire    [width-1:0]         R2modN_wire,mod_res;
wire    [2*width:0]           R;
assign  R[2*width]    =1'd1;
assign  R[2*width-1:0]  =0;
/***
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state<=IDLE;
    end
    else if(en&&state==IDLE)
        state<=LOAD;
    else begin
        state<=next_state;
    end
end***/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state<=IDLE;
    end
    else begin
        case(state)
            IDLE:begin 
                if(en)
                state<=LOAD;
                else
                state<=state;
            end

            LOAD:begin
                if(round==2'd1)
                    state<=CALR2;
                else state<=LOAD;
            end
            CALR2:begin
                if(divid_ready) begin
                    state<=SHIFT;
                end
                else
                    state<=CALR2;
            end
            CASE1:begin
                if(mod_ready&&c)
                state<=CASE0;
                else
                state<=CASE1;
            end  
            CASE0:begin
                if(key==0) begin
                    state<=OUT;
                end
                else if(mod_ready&&c) begin
                    state<=SHIFT;
                end
                else
                state<=state;
            end
            SHIFT:begin
                  if(key[0])
                    state<=CASE1;
                  else state<=CASE0;
            end
            OUT:begin
                if(round==cnt)
                state<=DONE;
                else
                state<=OUT;
            end
            DONE:state<=IDLE;
            default:state<=IDLE;
        endcase
        
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data<=0;
        mod_a<=0;
        mod_b<=0;
        mod_n<=0;
        key<=0;
        mod_start<=0;
        round<=cnt;
        mide_value<=0;
        //c<=0;
        out_data<=0;
        out_start<=0;
    end
    else begin
        case(state)
        IDLE:begin
            data<=0;
            mod_a<=0;
            mod_b<=0;
            mod_n<=0;
            key<=0;
            mod_start<=0;
            round<=cnt;
            mide_value<=0;
            c<=0;
            out_data<=0;
            out_start<=0;
        end
        LOAD:begin
            data<={data[width-9:0],in_data};
            mod_n<={mod_n[width-9:0],in_N};
            key<={key[width-9:0],in_key};
            mod_a<=0;
            mod_b<=0;
            mod_start<=0;
            round<=round-1'd1;
            mide_value<=256'd1;
            c<=0;
            out_data<=0;
            out_start<=0;
        end
        CASE1:begin
            key<=key;
            c<=c;
            round<=round;
            mod_n<=mod_n;
            data<=data;
            out_data<=0;
            out_start<=0;
            if(mod_ready) begin
                mide_value<=mod_res;
                mod_a<=0;
                mod_b<=0;
                mod_start<=1'd0; 
                c<=c+1'd1;
            end
            else begin
                mod_a<=mide_value;
                mod_b<=data;
                mod_start<=1'd1;
                mide_value<=mide_value;
            end
        end
        CALR2:begin
            if(key[0])
                mide_value<=256'd1;
            else
                mide_value<=data;
        end
        CASE0:begin
            key<=key;
            c<=c;
            round<=round;
            mod_n<=mod_n;
            data<=data;
            out_data<=0;
            out_start<=0;
            if(mod_ready) begin
                data<=mod_res;
                mod_a<=0;
                mod_b<=0;
                mod_start<=1'd0;
                c<=c+1'd1;
                
            end
            else begin
                mod_a<=data;
                mod_b<=data;
                mod_start<=1'd1;
                mide_value<=mide_value;
                out_data<=1'd0;
            end        
        end
        SHIFT:begin
            key=key>>1;
            round=round;
            mod_n=mod_n;            
            mod_a=0;
            mod_b=0;
            mod_start=1'd0;
            mide_value=mide_value;  
            data=data;
            out_data<=0;
            out_start<=0;
        end
        OUT:begin
            c=0;
            key=key;
            mod_n=mod_n;
            mod_a=0;
            mod_b=0;
            mod_start=0;
            round=round+1'd1;
            out_data=mide_value[7:0];
            mide_value=mide_value>>8;
            if(round==cnt)
                out_start<=1'd0;
            else
                out_start<=1'd1;
        end
        default:begin
            c=0;
            key=key;
            round<=round;
            mod_n<=mod_n;            
            mod_a<=0;
            mod_b<=0;
            mod_start<=1'd0;
            mide_value<=mide_value;
            out_data<=1'd0;
            data<=data;
            out_start<=1'd0;
        end
        endcase  
    end
end

always@(posedge clk) begin
    if(state==DONE)
        ready<=1'd1;
    else
        ready<=1'd0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        divid_en<=0;
        R2modN<=0;
    end
    else begin
        case(state)
            IDLE:begin
                divid_en<=0;
                R2modN<=0;
            end
            CALR2:begin
                if(divid_ready)begin
                    divid_en<=0;
                    R2modN<=R2modN_wire;
                end
                else begin
                    divid_en<=1'd1;
                    R2modN<=0;
                end
            end
            default:begin
                divid_en<=0;
                R2modN<=R2modN;
            end
        endcase
    end
end

montgomery_mod_multi
#(
    .MPWID(width)
)
M
(
    .clk(clk),
    .rst_n(rst_n),
    .start(mod_start),
    .in_a(mod_a),
    .in_b(mod_b),
    .in_n(mod_n),
    .R2modN(R2modN),
    .res(mod_res),
    .ready(mod_ready)
);
divid
#(
    .width(2*width+1)
)
divid_inst
(   .clk(clk),
    .rst_n(rst_n),
    .en(divid_en),
    .dividend(R),
    .divisor({{(width+1){1'd0}},mod_n}),
    .quotient(),
    .reminder(R2modN_wire),
    .ready(divid_ready)
);
endmodule