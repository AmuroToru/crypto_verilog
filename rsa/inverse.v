module inverse
//C*a=a_new mod n
//A*n=n_new mod n
//initial C=1 A=0 a_new=a n_new=n
#(
    parameter   width   =   32
)
(   
    input    wire                   clk,
    input    wire                   rst_n,
    input    wire                   en,
    input    wire     [width-1:0]   a,
    input    wire     [width-1:0]   n,
    output   reg                    ready,
    output   reg      [width-1:0]   a_inv
);

localparam              IDLE        =   3'd0,
                        LOAD        =   3'd1,
                        SWITCH      =   3'd2,
                        VAR_UPDATE  =   3'd3,
                        DIVID       =   3'd4,
                        DONE        =   3'd5;
                        
reg     [width:0]     a_reg;
reg     [width:0]     n_reg;
reg     [width:0]     a_new;
reg     [width:0]     n_new;
reg     [width:0]       A;
reg     [width:0]       C;
reg     [2:0]           state,next_state;
reg                     flag;

reg     [width:0]       mulb,divid_res;
reg                     divid_ok,multi_start;
reg     [2*width+1:0]   mul_dividend;
wire    [2*width+1:0]   mul_res_wire,dividend_wire;
wire                    divid_ready,multi_ready;
wire    [width:0]       divid_res_wire;
assign  dividend_wire=mul_dividend;
always @(posedge clk  or  negedge  rst_n)begin
    if(!rst_n) begin
        state<=IDLE;
    end
    else
        state<=next_state;
end

always @(posedge clk  or  negedge  rst_n)begin
    if(!rst_n) begin
        next_state<=IDLE;
    end
    else begin
        case(next_state) 
            IDLE:
                if(en)
                    next_state<=LOAD;
                else
                    next_state<=next_state;
            LOAD:
                    next_state<=SWITCH;
            SWITCH:
                    next_state<=VAR_UPDATE;
            VAR_UPDATE:if(a_new==1'd1 || n_new==1'd1)
                        next_state<=DIVID;
                    else
                        next_state<=next_state;
            DIVID:if(divid_ok)
                    next_state<=DONE;
                  else
                    next_state<=next_state;
            DONE:   next_state<=IDLE;     
            default
                    next_state<=IDLE;
        endcase
    end
end

always @(posedge clk  or  negedge  rst_n)begin
    if(!rst_n) begin
        a_reg<=0;
        n_reg<=0;
        a_new<=0;
        n_new<=0;
        A<=0;
        C<=0;
        flag<=0;
    end
    else case(state)
        IDLE:begin
            a_reg<=0;
            n_reg<=0;
            a_new<=0;
            n_new<=0;
            A<=0;
            C<=0;
            flag<=0;
        end
        LOAD:begin
            a_reg<={1'd0,a};
            n_reg<={1'd0,n};
            a_new<={1'd0,a};
            n_new<={1'd0,n};
            A<=0;
            C<=1'd1;
            flag<=0;
        end
        SWITCH:begin
            A<=0;
            C<=1'd1;
            if(n_reg[0]==0)begin
                a_reg<=n_reg;
                n_reg<=a_reg;
                n_new<=a_new;
                a_new<=n_reg;
                flag<=1'd1;
            end
            else begin
                a_reg<=a_reg;
                n_reg<=n_reg;
                n_new<=n_new;
                a_new<=a_reg;
                flag<=flag;
            end
        end
        VAR_UPDATE:begin
            a_reg<=a_reg;
            n_reg<=n_reg;
            flag<=flag;
            
            if(!a_new[0]) begin
                a_new<=a_new>>1'd1;
                n_new<=n_new;
                A<=A;
                if(!C[0]) C<=C>>1'd1;
                else C<=(C+n_reg)>>1'd1;
            end
            else if(!n_new[0]) begin
                n_new<=n_new>>1'd1;
                a_new<=a_new;
                C<=C;
                if(!A[0])  A<=A>>1'd1;
                else  A<=(A+n_reg)>>1'd1;
            end
            else    begin
                if(a_new>n_new)begin
                    a_new<=a_new-n_new;
                    C<=C-A;
                    n_new<=n_new;
                    A<=A;
                end
                else begin
                    n_new<=n_new-a_new;
                    A<=A-C;
                    a_new<=a_new;
                    C<=C;
                end

            end
            
        end
        default begin
            flag<=flag;
            a_reg<=a_reg;
            n_reg<=n_reg;
            a_new<=a_new;
            n_new<=n_new;
            A<=A;
            C<=C;
        end
    endcase
end
always @(posedge clk)begin
    if(state==DONE) begin
        ready<=1'd1;
        if(!flag) begin
            if(a_new==1'd1)
                a_inv<=C;
            else
                a_inv<=A;
        end
        else begin
                a_inv<=(a_reg-divid_res);
        end
    end
    else begin
        ready<=0;
        a_inv<=0;
    end    
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        divid_ok<=0;
        multi_start<=0;
        mulb<=0;
        divid_res<=0;
        mul_dividend<=0;
    end
    else if(state==DIVID) begin
        if(flag==1'd1)begin
            if(!divid_ready) begin
                divid_res<=divid_res;
                divid_ok<=0;
                multi_start<=1'd1;
                if(a_new==1) begin
                    mulb<=C;
                end
                else mulb<=A;
                if(multi_ready)
                    mul_dividend<=mul_res_wire;
                else
                    mul_dividend<=mul_dividend;
            end
            else begin
                divid_res<=divid_res_wire;
                divid_ok<=1'd1;
                multi_start<=0;
                mulb<=0;
                mul_dividend<=0;
            end
        end
        else begin
            divid_ok<=1'd1;
            multi_start<=0;
            mulb<=0;
            divid_res<=0;
            mul_dividend<=0;
        end
    end
    else begin
        divid_ok<=divid_ok;
        multi_start<=multi_start;
        mulb<=mulb;
        divid_res<=divid_res;
        mul_dividend<=mul_dividend;
    end
end
divid
#(
    .width(2*width+2)
)
u_divid
(   .clk(clk),
    .rst_n(rst_n),
    .    en(multi_ready),
    .dividend(dividend_wire),
    .divisor({{(width+1){1'b0}},n_reg}),
    .quotient(divid_res_wire),
    .ready(divid_ready)
);
multi_without_add_function #(
    .MPWID      (width+1)
) u_multi (
    .clk        (clk),
    .rst_n      (rst_n),
    .start      (multi_start),
    .in_a       (a_reg),
    .in_b       (mulb),
    .mul        (mul_res_wire),
    .ready      (multi_ready)
);

endmodule