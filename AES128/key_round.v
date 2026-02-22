module key_round(
    input   wire            clk,
    input   wire            rst_n,
    input   wire    [127:0] key_in,
    input   wire    [3:0]   round,
    output  wire    [127:0] key_out,
    output  reg             key_ready
);
reg     [2:0]   cnt;

wire    [31:0]  key_shift;
wire    [31:0]  key_box; 
wire    [31:0]  key_xor;
reg     [7:0]   round_const;

assign key_shift={key_in[23:0],key_in[31:24]};
assign key_xor={key_box[31:24]^round_const,key_box[23:0]};
assign key_out[127:96]=key_in[127:96]^key_xor;
assign key_out[95:64]=key_out[127:96]^key_in[95:64];
assign key_out[63:32]=key_out[95:64]^key_in[63:32];
assign key_out[31:0]=key_out[63:32]^key_in[31:0];

s_box sbox1(
    .row(key_shift[31:28]),
    .col(key_shift[27:24]),
    .sout(key_box[31:24])
);

s_box sbox2(
    .row(key_shift[23:20]),
    .col(key_shift[19:16]),
    .sout(key_box[23:16])
);

s_box sbox3(
    .row(key_shift[15:12]),
    .col(key_shift[11:8]),
    .sout(key_box[15:8])
);

s_box sbox4(
    .row(key_shift[7:4]),
    .col(key_shift[3:0]),
    .sout(key_box[7:0])
);

//round 01 02 04 08 10 20 40 80 1B 36

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        round_const<=0;
    end
    else if(round) begin
        case(round)
        4'd1:begin
            round_const<=8'd1;
            end
        4'd2:begin
            round_const<=8'd2;
            end
        4'd3:begin
            round_const<=8'd4;
            end
        4'd4:begin
            round_const<=8'd8;
            end  
        4'd5:begin
            round_const<=8'h10;
            end
        4'd6:begin
            round_const<=8'h20;
            end
        4'd7:begin
            round_const<=8'h40;
            end
        4'd8:begin
            round_const<=8'h80;
            end
        4'd9:begin
            round_const<=8'h1b;
            end
        4'd10:begin
            round_const<=8'h36;
            end  
        default:begin
            round_const<=round_const;
            end
        endcase
    end
    else begin
        round_const<=round_const;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_ready<=0;
        cnt<=0;
    end
    else begin
        case(cnt) 
            3'd0, 3'd1, 3'd2, 3'd3: begin
                cnt <= cnt + 1'b1;
                key_ready <= 1'b0;
            end
            3'd4: begin
                cnt <= 3'd5;
                key_ready <= 1'b1; 
            end
            3'd5: begin
                cnt <= 3'd5; 
                key_ready <= 1'b1;
            end
            default: begin
                cnt <= 3'd0;
                key_ready <= 1'b0;
            end     
        endcase
        
    end
end
endmodule