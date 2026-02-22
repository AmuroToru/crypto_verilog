module enc_round_10(
    input   wire            clk,        
    input   wire            rst_n,      
    input   wire    [127:0] message_in,
    input   wire    [127:0] subkey,
    input   wire            en,
    output  wire     [127:0] message_out,
    output  reg             ready
);


reg [1:0]   cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt<=0;
        ready<=0;
    end
    else if(en)    begin
        case(cnt)
            2'b0:begin
                cnt<=cnt+1;
                ready<=0;
            end
            2'd1:begin
                cnt<=cnt+1;
                ready<=0;
            end
            2'd2:begin
                cnt<=cnt;
                ready<=0;
            end       
            default begin
                cnt<=cnt;
                ready<=ready;
            end
        endcase
      end 
    else begin
        cnt<=cnt;
        ready<=ready;
    end
end

// ============================================================
// 字节代换 (SubBytes)
// ============================================================
wire [127:0] sub_bytes_wire;

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : sbox_inst
        s_box sbox (
            .row  (message_in[127 - i*8 : 124 - i*8]),
            .col  (message_in[123 - i*8 : 120 - i*8]),
            .sout (sub_bytes_wire[127 - i*8 : 120 - i*8])
        );
    end
endgenerate




// ============================================================
// 行移位 (ShiftRows)和密钥加
// ============================================================


// 第0行 (字节0,4,8,12) - 不移位                       
assign message_out[127:120] = sub_bytes_wire[127:120] ^subkey[127:120];
assign message_out[95:88]   = sub_bytes_wire[95:88]   ^subkey[95:88];
assign message_out[63:56]   = sub_bytes_wire[63:56]   ^subkey[63:56];
assign message_out[31:24]   = sub_bytes_wire[31:24]   ^subkey[31:24];
                                                     
// 第1行 (字节1,5,9,13) - 左移1字节                  
assign message_out[119:112] = sub_bytes_wire[87:80]   ^subkey[119:112];
assign message_out[87:80]   = sub_bytes_wire[55:48]   ^subkey[87:80];
assign message_out[55:48]   = sub_bytes_wire[23:16]   ^subkey[55:48];
assign message_out[23:16]   = sub_bytes_wire[119:112] ^subkey[23:16];
                                                     
// 第2行 (字节2,6,10,14) - 左移2字节                 
assign message_out[111:104] = sub_bytes_wire[47:40]   ^subkey[111:104];
assign message_out[79:72]   = sub_bytes_wire[15:8]    ^subkey[79:72];
assign message_out[47:40]   = sub_bytes_wire[111:104] ^subkey[47:40];
assign message_out[15:8]    = sub_bytes_wire[79:72]   ^subkey[15:8];
                                                     
// 第3行 (字节3,7,11,15) - 左移3字节                 
assign message_out[103:96]  = sub_bytes_wire[7:0]     ^subkey[103:96];
assign message_out[71:64]   = sub_bytes_wire[103:96]  ^subkey[71:64];
assign message_out[39:32]   = sub_bytes_wire[71:64]   ^subkey[39:32];
assign message_out[7:0]     = sub_bytes_wire[39:32]   ^subkey[7:0];







endmodule