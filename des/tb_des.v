`timescale 1ns/1ns
module tb_des();
reg sys_clk;
reg sys_rst_n;
reg  [63:0] key_message_reg;
reg         sel_reg;
wire [63:0] enc;
wire        enc_ready;
wire        parity_check_error; 
initial
    begin
        sys_clk=1'b1;
        sys_rst_n<=1'b0;
        #20
        sys_rst_n<=1'b1;
        sel_reg=0;
        key_message_reg=64'h133457799BBCDFF1;
        #40
        sys_rst_n<=1'b1;
        sel_reg=1'd1;
        key_message_reg=64'h0123456789ABCDEF;
        
    end
always #10 sys_clk=~sys_clk;
des des_inst(
    .key_message(key_message_reg),
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .sel(sel_reg),//0 输入key，1输入message
    .enc(enc),
    . enc_ready(enc_ready)  ,
    .parity_check_error(parity_check_error),
);
endmodule