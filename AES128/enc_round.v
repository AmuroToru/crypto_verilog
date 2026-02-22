module enc_round(
    input   wire            clk,
    input   wire            rst_n,
    input   wire    [127:0] message_in,
    input   wire    [127:0] subkey,
    input   wire            en,
    output  reg     [127:0] message_out,
    output  reg             ready
);

// 流水线寄存器

reg [1:0]   cnt;

// 2位计数器（4个周期）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 2'd0;
        ready <= 1'b0;
    end
    else if (en) begin
        if (cnt == 2'd3) begin
            cnt <= cnt;
            ready <= 1'b1;
        end
        else begin
            cnt <= cnt + 2'd1;
            ready <= 1'b0;
        end
    end
    else begin
        cnt <= 2'd0;
        ready <= 1'b0;
    end
end

// ============================================================
// 字节代换 (SubBytes) - 使用查找表
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
// 行移位 (ShiftRows)
// ============================================================
wire [127:0] shift_rows_wire;

// 第0行
assign shift_rows_wire[127:120] = sub_bytes_wire[127:120];
assign shift_rows_wire[95:88]   = sub_bytes_wire[95:88];
assign shift_rows_wire[63:56]   = sub_bytes_wire[63:56];
assign shift_rows_wire[31:24]   = sub_bytes_wire[31:24];
                                            
// 第1行                                    
assign shift_rows_wire[119:112] = sub_bytes_wire[87:80];
assign shift_rows_wire[87:80]   = sub_bytes_wire[55:48];
assign shift_rows_wire[55:48]   = sub_bytes_wire[23:16];
assign shift_rows_wire[23:16]   = sub_bytes_wire[119:112];

// 第2行
assign shift_rows_wire[111:104] = sub_bytes_wire[47:40];
assign shift_rows_wire[79:72]   = sub_bytes_wire[15:8];
assign shift_rows_wire[47:40]   = sub_bytes_wire[111:104];
assign shift_rows_wire[15:8]    = sub_bytes_wire[79:72];
                                            
// 第3行                                    
assign shift_rows_wire[103:96]  = sub_bytes_wire[7:0];
assign shift_rows_wire[71:64]   = sub_bytes_wire[103:96];
assign shift_rows_wire[39:32]   = sub_bytes_wire[71:64];
assign shift_rows_wire[7:0]     = sub_bytes_wire[39:32];



// ============================================================
// 列混淆 (MixColumns) 
// ============================================================
wire [127:0] mix_columns_wire;

// 预计算的乘2查找表 (ROM)
function [7:0] mul2;
    input [7:0] x;
    reg [7:0] result;
    begin
        case (x)
            8'h00: result = 8'h00; 8'h01: result = 8'h02; 8'h02: result = 8'h04; 8'h03: result = 8'h06;
            8'h04: result = 8'h08; 8'h05: result = 8'h0a; 8'h06: result = 8'h0c; 8'h07: result = 8'h0e;
            8'h08: result = 8'h10; 8'h09: result = 8'h12; 8'h0a: result = 8'h14; 8'h0b: result = 8'h16;
            8'h0c: result = 8'h18; 8'h0d: result = 8'h1a; 8'h0e: result = 8'h1c; 8'h0f: result = 8'h1e;
            8'h10: result = 8'h20; 8'h11: result = 8'h22; 8'h12: result = 8'h24; 8'h13: result = 8'h26;
            8'h14: result = 8'h28; 8'h15: result = 8'h2a; 8'h16: result = 8'h2c; 8'h17: result = 8'h2e;
            8'h18: result = 8'h30; 8'h19: result = 8'h32; 8'h1a: result = 8'h34; 8'h1b: result = 8'h36;
            8'h1c: result = 8'h38; 8'h1d: result = 8'h3a; 8'h1e: result = 8'h3c; 8'h1f: result = 8'h3e;
            8'h20: result = 8'h40; 8'h21: result = 8'h42; 8'h22: result = 8'h44; 8'h23: result = 8'h46;
            8'h24: result = 8'h48; 8'h25: result = 8'h4a; 8'h26: result = 8'h4c; 8'h27: result = 8'h4e;
            8'h28: result = 8'h50; 8'h29: result = 8'h52; 8'h2a: result = 8'h54; 8'h2b: result = 8'h56;
            8'h2c: result = 8'h58; 8'h2d: result = 8'h5a; 8'h2e: result = 8'h5c; 8'h2f: result = 8'h5e;
            8'h30: result = 8'h60; 8'h31: result = 8'h62; 8'h32: result = 8'h64; 8'h33: result = 8'h66;
            8'h34: result = 8'h68; 8'h35: result = 8'h6a; 8'h36: result = 8'h6c; 8'h37: result = 8'h6e;
            8'h38: result = 8'h70; 8'h39: result = 8'h72; 8'h3a: result = 8'h74; 8'h3b: result = 8'h76;
            8'h3c: result = 8'h78; 8'h3d: result = 8'h7a; 8'h3e: result = 8'h7c; 8'h3f: result = 8'h7e;
            8'h40: result = 8'h80; 8'h41: result = 8'h82; 8'h42: result = 8'h84; 8'h43: result = 8'h86;
            8'h44: result = 8'h88; 8'h45: result = 8'h8a; 8'h46: result = 8'h8c; 8'h47: result = 8'h8e;
            8'h48: result = 8'h90; 8'h49: result = 8'h92; 8'h4a: result = 8'h94; 8'h4b: result = 8'h96;
            8'h4c: result = 8'h98; 8'h4d: result = 8'h9a; 8'h4e: result = 8'h9c; 8'h4f: result = 8'h9e;
            8'h50: result = 8'ha0; 8'h51: result = 8'ha2; 8'h52: result = 8'ha4; 8'h53: result = 8'ha6;
            8'h54: result = 8'ha8; 8'h55: result = 8'haa; 8'h56: result = 8'hac; 8'h57: result = 8'hae;
            8'h58: result = 8'hb0; 8'h59: result = 8'hb2; 8'h5a: result = 8'hb4; 8'h5b: result = 8'hb6;
            8'h5c: result = 8'hb8; 8'h5d: result = 8'hba; 8'h5e: result = 8'hbc; 8'h5f: result = 8'hbe;
            8'h60: result = 8'hc0; 8'h61: result = 8'hc2; 8'h62: result = 8'hc4; 8'h63: result = 8'hc6;
            8'h64: result = 8'hc8; 8'h65: result = 8'hca; 8'h66: result = 8'hcc; 8'h67: result = 8'hce;
            8'h68: result = 8'hd0; 8'h69: result = 8'hd2; 8'h6a: result = 8'hd4; 8'h6b: result = 8'hd6;
            8'h6c: result = 8'hd8; 8'h6d: result = 8'hda; 8'h6e: result = 8'hdc; 8'h6f: result = 8'hde;
            8'h70: result = 8'he0; 8'h71: result = 8'he2; 8'h72: result = 8'he4; 8'h73: result = 8'he6;
            8'h74: result = 8'he8; 8'h75: result = 8'hea; 8'h76: result = 8'hec; 8'h77: result = 8'hee;
            8'h78: result = 8'hf0; 8'h79: result = 8'hf2; 8'h7a: result = 8'hf4; 8'h7b: result = 8'hf6;
            8'h7c: result = 8'hf8; 8'h7d: result = 8'hfa; 8'h7e: result = 8'hfc; 8'h7f: result = 8'hfe;
            8'h80: result = 8'h1b; 8'h81: result = 8'h19; 8'h82: result = 8'h1f; 8'h83: result = 8'h1d;
            8'h84: result = 8'h13; 8'h85: result = 8'h11; 8'h86: result = 8'h17; 8'h87: result = 8'h15;
            8'h88: result = 8'h0b; 8'h89: result = 8'h09; 8'h8a: result = 8'h0f; 8'h8b: result = 8'h0d;
            8'h8c: result = 8'h03; 8'h8d: result = 8'h01; 8'h8e: result = 8'h07; 8'h8f: result = 8'h05;
            8'h90: result = 8'h3b; 8'h91: result = 8'h39; 8'h92: result = 8'h3f; 8'h93: result = 8'h3d;
            8'h94: result = 8'h33; 8'h95: result = 8'h31; 8'h96: result = 8'h37; 8'h97: result = 8'h35;
            8'h98: result = 8'h2b; 8'h99: result = 8'h29; 8'h9a: result = 8'h2f; 8'h9b: result = 8'h2d;
            8'h9c: result = 8'h23; 8'h9d: result = 8'h21; 8'h9e: result = 8'h27; 8'h9f: result = 8'h25;
            8'ha0: result = 8'h5b; 8'ha1: result = 8'h59; 8'ha2: result = 8'h5f; 8'ha3: result = 8'h5d;
            8'ha4: result = 8'h53; 8'ha5: result = 8'h51; 8'ha6: result = 8'h57; 8'ha7: result = 8'h55;
            8'ha8: result = 8'h4b; 8'ha9: result = 8'h49; 8'haa: result = 8'h4f; 8'hab: result = 8'h4d;
            8'hac: result = 8'h43; 8'had: result = 8'h41; 8'hae: result = 8'h47; 8'haf: result = 8'h45;
            8'hb0: result = 8'h7b; 8'hb1: result = 8'h79; 8'hb2: result = 8'h7f; 8'hb3: result = 8'h7d;
            8'hb4: result = 8'h73; 8'hb5: result = 8'h71; 8'hb6: result = 8'h77; 8'hb7: result = 8'h75;
            8'hb8: result = 8'h6b; 8'hb9: result = 8'h69; 8'hba: result = 8'h6f; 8'hbb: result = 8'h6d;
            8'hbc: result = 8'h63; 8'hbd: result = 8'h61; 8'hbe: result = 8'h67; 8'hbf: result = 8'h65;
            8'hc0: result = 8'h9b; 8'hc1: result = 8'h99; 8'hc2: result = 8'h9f; 8'hc3: result = 8'h9d;
            8'hc4: result = 8'h93; 8'hc5: result = 8'h91; 8'hc6: result = 8'h97; 8'hc7: result = 8'h95;
            8'hc8: result = 8'h8b; 8'hc9: result = 8'h89; 8'hca: result = 8'h8f; 8'hcb: result = 8'h8d;
            8'hcc: result = 8'h83; 8'hcd: result = 8'h81; 8'hce: result = 8'h87; 8'hcf: result = 8'h85;
            8'hd0: result = 8'hbb; 8'hd1: result = 8'hb9; 8'hd2: result = 8'hbf; 8'hd3: result = 8'hbd;
            8'hd4: result = 8'hb3; 8'hd5: result = 8'hb1; 8'hd6: result = 8'hb7; 8'hd7: result = 8'hb5;
            8'hd8: result = 8'hab; 8'hd9: result = 8'ha9; 8'hda: result = 8'haf; 8'hdb: result = 8'had;
            8'hdc: result = 8'ha3; 8'hdd: result = 8'ha1; 8'hde: result = 8'ha7; 8'hdf: result = 8'ha5;
            8'he0: result = 8'hdb; 8'he1: result = 8'hd9; 8'he2: result = 8'hdf; 8'he3: result = 8'hdd;
            8'he4: result = 8'hd3; 8'he5: result = 8'hd1; 8'he6: result = 8'hd7; 8'he7: result = 8'hd5;
            8'he8: result = 8'hcb; 8'he9: result = 8'hc9; 8'hea: result = 8'hcf; 8'heb: result = 8'hcd;
            8'hec: result = 8'hc3; 8'hed: result = 8'hc1; 8'hee: result = 8'hc7; 8'hef: result = 8'hc5;
            8'hf0: result = 8'hfb; 8'hf1: result = 8'hf9; 8'hf2: result = 8'hff; 8'hf3: result = 8'hfd;
            8'hf4: result = 8'hf3; 8'hf5: result = 8'hf1; 8'hf6: result = 8'hf7; 8'hf7: result = 8'hf5;
            8'hf8: result = 8'heb; 8'hf9: result = 8'he9; 8'hfa: result = 8'hef; 8'hfb: result = 8'hed;
            8'hfc: result = 8'he3; 8'hfd: result = 8'he1; 8'hfe: result = 8'he7; 8'hff: result = 8'he5;
            default: result = 8'h00;
        endcase
        mul2 = result;
    end
endfunction

function [7:0] mul3;
    input [7:0] x;
    begin
        mul3 = mul2(x) ^ x;
    end
endfunction

// 第0列
assign mix_columns_wire[127:120] = mul2(shift_rows_wire[127:120]) ^ mul3(shift_rows_wire[119:112]) ^      shift_rows_wire[111:104]  ^      shift_rows_wire[103:96];
assign mix_columns_wire[119:112] =      shift_rows_wire[127:120]  ^ mul2(shift_rows_wire[119:112]) ^ mul3(shift_rows_wire[111:104]) ^      shift_rows_wire[103:96];
assign mix_columns_wire[111:104] =      shift_rows_wire[127:120]  ^      shift_rows_wire[119:112]  ^ mul2(shift_rows_wire[111:104]) ^ mul3(shift_rows_wire[103:96]);
assign mix_columns_wire[103:96]  = mul3(shift_rows_wire[127:120]) ^      shift_rows_wire[119:112]  ^      shift_rows_wire[111:104]  ^ mul2(shift_rows_wire[103:96]);
                                                                                                                
// 第1列                                                                                                        
assign mix_columns_wire[95:88] = mul2(shift_rows_wire[95:88])     ^ mul3(shift_rows_wire[87:80])   ^      shift_rows_wire[79:72]    ^      shift_rows_wire[71:64];
assign mix_columns_wire[87:80] =      shift_rows_wire[95:88]      ^ mul2(shift_rows_wire[87:80])   ^ mul3(shift_rows_wire[79:72])   ^      shift_rows_wire[71:64];
assign mix_columns_wire[79:72] =      shift_rows_wire[95:88]      ^      shift_rows_wire[87:80]    ^ mul2(shift_rows_wire[79:72])   ^ mul3(shift_rows_wire[71:64]);
assign mix_columns_wire[71:64] = mul3(shift_rows_wire[95:88])     ^      shift_rows_wire[87:80]    ^      shift_rows_wire[79:72]    ^ mul2(shift_rows_wire[71:64]);
                                                 
                                                 
assign mix_columns_wire[63:56] = mul2(shift_rows_wire[63:56])     ^ mul3(shift_rows_wire[55:48])   ^      shift_rows_wire[47:40]    ^      shift_rows_wire[39:32];
assign mix_columns_wire[55:48] =      shift_rows_wire[63:56]      ^ mul2(shift_rows_wire[55:48])   ^ mul3(shift_rows_wire[47:40])   ^      shift_rows_wire[39:32];
assign mix_columns_wire[47:40] =      shift_rows_wire[63:56]      ^      shift_rows_wire[55:48]    ^ mul2(shift_rows_wire[47:40])   ^ mul3(shift_rows_wire[39:32]);
assign mix_columns_wire[39:32] = mul3(shift_rows_wire[63:56])     ^      shift_rows_wire[55:48]    ^      shift_rows_wire[47:40]    ^ mul2(shift_rows_wire[39:32]);
                                                 
                                                 
assign mix_columns_wire[31:24] = mul2(shift_rows_wire[31:24])     ^ mul3(shift_rows_wire[23:16])   ^      shift_rows_wire[15:8]     ^      shift_rows_wire[7:0];
assign mix_columns_wire[23:16] =      shift_rows_wire[31:24]      ^ mul2(shift_rows_wire[23:16])   ^ mul3(shift_rows_wire[15:8])    ^      shift_rows_wire[7:0];
assign mix_columns_wire[15:8]  =      shift_rows_wire[31:24]      ^      shift_rows_wire[23:16]    ^ mul2(shift_rows_wire[15:8])    ^ mul3(shift_rows_wire[7:0]);
assign mix_columns_wire[7:0]   = mul3(shift_rows_wire[31:24])     ^      shift_rows_wire[23:16]    ^      shift_rows_wire[15:8]     ^ mul2(shift_rows_wire[7:0]);



// ============================================================
// 密钥加 (AddRoundKey)
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        message_out <= 128'h0;
    else if (en)
        message_out <= mix_columns_wire ^ subkey;
end

endmodule