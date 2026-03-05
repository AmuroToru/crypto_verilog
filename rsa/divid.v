module divid
#(
    parameter   width   =   32
)
(   input   wire                    clk,
    input   wire                    rst_n,
    input   wire                        en,
    input   wire    [width-1:0]     dividend,
    input   wire    [width-1:0]     divisor,
    output  reg     [width-1:0]     quotient,
    output  reg     [width-1:0]     reminder,
    output  reg                     ready
);

localparam  IDLE        =0,
            LOAD        =1,
            SHIFT       =2,
            CAL         =3,
            DONE        =4,
            cnt_width   =$clog2(width+1'd1);

reg     [width-1:0]         dividend_reg;
reg     [width-1:0]         divisor_reg;
reg     [2:0]               state,next_state;
reg     [cnt_width-1:0]     width_dividend,width_divisor;
reg                         shift_ready;
        

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        next_state<=IDLE;
    end
    else begin
        case(next_state)
            IDLE: if(en)
                    next_state<=LOAD;
                  else
                    next_state<=next_state;
            LOAD:
                    next_state<=SHIFT;
            SHIFT:if(shift_ready)
                    next_state<=CAL;
                  else
                    next_state<=next_state;
            CAL:
                if(width_divisor<width_dividend)
                    next_state<=DONE;
                else
                    next_state<=next_state;
            DONE:
                next_state<=IDLE;
            default
                next_state<=next_state;
        endcase
    end

end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state<=IDLE;
    end
    else
        state<=next_state;
end
always@(posedge clk) begin
    if(state==DONE) begin
        ready<=1'd1;
        reminder<=dividend_reg>>(width_dividend-1'd1);
    end
    else begin
        ready<=0;
        reminder<=dividend_reg;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dividend_reg<=0;
        divisor_reg<=0;
        quotient<=0;
        shift_ready<=0;
        width_dividend<=1'd1;
        shift_ready<=0;
        width_divisor<=1'd1;
    end
    else begin
        case(state)
            IDLE:begin
                dividend_reg<=0;
                divisor_reg<=0;
                quotient<=0;
                shift_ready<=0;
                width_dividend<=1'd1;
                width_divisor<=1'd1;
                shift_ready<=0;
            end
            LOAD:begin
                dividend_reg<=dividend;
                divisor_reg<=divisor;
                quotient<=0;
                shift_ready<=0;
                width_dividend<=1'd1;
                width_divisor<=1'd1;
                shift_ready<=0;
            end
            SHIFT:begin
                    if((divisor_reg[width-1]==0)&&(!shift_ready))begin
                        if(dividend_reg[width-1]==0)begin
                            dividend_reg<=dividend_reg<<1;
                            divisor_reg<=divisor_reg<<1;
                            width_dividend<=width_dividend+1'd1;
                            width_divisor<=width_divisor+1'd1;
                        end

                        else begin
                            dividend_reg<=dividend_reg;
                            divisor_reg<=divisor_reg<<1;
                            width_dividend<=width_dividend;
                            width_divisor<=width_divisor+1'd1;                            
                        end
                        shift_ready<=0;
                    end
                    else if(divisor_reg[width-1]&&(!shift_ready)) begin
                        shift_ready<=1'd1;
                        dividend_reg<=dividend_reg;
                        divisor_reg<=divisor_reg;
                        width_dividend<=width_dividend;
                        width_divisor<=width_divisor; 
                    end
                    else begin
                        shift_ready<=shift_ready;
                        dividend_reg<=dividend_reg;
                        divisor_reg<=divisor_reg;
                        width_dividend<=width_dividend;
                        width_divisor<=width_divisor;
                    end
                    quotient<=0;
            end
            CAL:begin
                width_divisor<=width_divisor;
                shift_ready<=shift_ready;
                if(width_divisor>=width_dividend) begin
                    width_dividend<=width_dividend;
                    width_divisor<=width_divisor-1'd1;
                    divisor_reg<=divisor_reg>>1'd1;
                    if(dividend_reg>=divisor_reg)begin
                        quotient<={quotient[width-2:0],1'd1};
                        dividend_reg<=(dividend_reg-divisor_reg);                        
                    end
                    else if(dividend_reg<divisor_reg)  begin
                        quotient<={quotient[width-2:0],1'd0};
                        dividend_reg<=dividend_reg;
                    end
                end
                else begin
                    width_dividend<=width_dividend;
                    dividend_reg<=dividend_reg;
                    quotient<=quotient;
                    dividend_reg<=dividend_reg;
                    divisor_reg<=divisor_reg>>1'd1;
                end  
            end
            DONE:begin
                dividend_reg<=dividend_reg;
                divisor_reg<=divisor_reg;
                quotient<=quotient;
                shift_ready<=shift_ready;
                width_dividend<=width_dividend;
                shift_ready<=shift_ready;
            end
            default begin
                dividend_reg<=dividend_reg;
                divisor_reg<=divisor_reg;
                quotient<=quotient;
                shift_ready<=shift_ready;
                width_dividend<=width_dividend;
                shift_ready<=shift_ready;          
            end
        endcase
    end
end

endmodule