module padding_shake128(
    input               clk,
    input               rst_n,
    input      [7:0]    in_byte,
    input               in_valid,
    input               is_last,
    output              in_ready,
    input               out_ready,
    output  reg            out_valid,
    output reg [1343:0] out,
    output              msg_done        // 整个消息完成标志
);

    // SHAKE128参数
    localparam RATE_BYTES  = 8'd168;   // 1344/8 = 168字节
    localparam RATE_LAST   = 8'd167;
    localparam RATE_BITS   = 1344;

    localparam S_ABSORB     = 2'd0;
    localparam S_PAD_DOMAIN = 2'd1;
    localparam S_PAD_FILL   = 2'd2;
    localparam S_DONE       = 2'd3;

    reg [1:0] state, next_state;

    wire f_ack = out_valid & out_ready;

    reg [7:0] cnt_byte;
    assign in_ready = (state == S_ABSORB) && (cnt_byte < RATE_BYTES);
    wire accept = in_valid & in_ready;

    reg        wr_en;
    reg [7:0]  wr_byte;
    reg need_extra;
    
    // 标志信号
    reg msg_done_reg;
    reg last_block_processed;
    

    assign msg_done = msg_done_reg;

    // need_extra 逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            need_extra <= 1'b0;
        end else begin
            if (f_ack && need_extra) begin
                need_extra <= 1'b0;
            end else if (accept && is_last && (cnt_byte == RATE_LAST)) begin
                need_extra <= 1'b1;
            end
        end
    end

    // out 寄存器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= {RATE_BITS{1'b0}};
        end else if (f_ack) begin
            out <= {RATE_BITS{1'b0}};
        end else if (wr_en) begin
            out <= {out[RATE_BITS-9:0], wr_byte};
        end
    end

    // cnt_byte 计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_byte <= 8'd0;
        end else if (f_ack) begin
            cnt_byte <= 8'd0;
        end else if (wr_en) begin
            cnt_byte <= cnt_byte + 8'd1;
        end
    end

    // 状态寄存器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_ABSORB;
        end else begin
            state <= next_state;
        end
    end

    // msg_done 标志生成
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            msg_done_reg <= 1'b0;
            last_block_processed <= 1'b0;
        end else begin
            msg_done_reg <= 1'b0;
            
            if (accept && is_last) begin
                last_block_processed <= 1'b1;
            end
            
            if (last_block_processed  && !need_extra) begin
                msg_done_reg <= 1'b1;
                last_block_processed <= 1'b0;
            end
        end
    end


    always @(*) begin
        // 默认值
        next_state <= state;
        wr_en      <= 1'b0;
        wr_byte    <= 8'h00;
        out_valid<=1'd0;

        case (state)
            S_ABSORB: begin
                out_valid  = 1'd0;
                if (accept) begin
                    wr_en   <= 1'b1;
                    wr_byte <= in_byte;

                    if (cnt_byte == RATE_LAST) begin
                        next_state <= S_DONE;
                    end else if (is_last) begin
                        next_state <= S_PAD_DOMAIN;
                    end
                end
            end

            S_PAD_DOMAIN: begin
                wr_en <= 1'b1;
                out_valid  = 1'd0;
                if (cnt_byte == RATE_LAST) begin
                    wr_byte    <= 8'hF9;   // SHAKE使用0x9F
                    next_state <= S_DONE;
                end else begin
                    wr_byte    <= 8'hF8;   // SHAKE使用0x1F
                    next_state <= S_PAD_FILL;
                end
            end

            S_PAD_FILL: begin
                wr_en <= 1'b1;
                out_valid  = 1'd0;
                if (cnt_byte == RATE_LAST) begin
                    wr_byte    <= 8'h01;
                    next_state <= S_DONE;
                end else begin
                    wr_byte    <= 8'h00;
                    next_state <= S_PAD_FILL;
                end
            end

            S_DONE: begin
                out_valid<=1'd1;
                if (out_ready) begin
                    next_state <= need_extra ? S_PAD_DOMAIN : S_ABSORB;
                end
            end

            default: begin
                next_state <= S_ABSORB;
                out_valid  = 1'd0;
            end
        endcase
    end

endmodule