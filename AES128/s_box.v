module s_box(
    input   wire    [3:0] row,
    input   wire    [3:0] col,
    output reg [7:0] sout
);


    always @(*) begin
        case (row)
            4'h0: begin
                case (col)
                    4'h0: sout = 8'h63;
                    4'h1: sout = 8'h7C;
                    4'h2: sout = 8'h77;
                    4'h3: sout = 8'h7B;
                    4'h4: sout = 8'hF2;
                    4'h5: sout = 8'h6B;
                    4'h6: sout = 8'h6F;
                    4'h7: sout = 8'hC5;
                    4'h8: sout = 8'h30;
                    4'h9: sout = 8'h01;
                    4'hA: sout = 8'h67;
                    4'hB: sout = 8'h2B;
                    4'hC: sout = 8'hFE;
                    4'hD: sout = 8'hD7;
                    4'hE: sout = 8'hAB;
                    4'hF: sout = 8'h76;
                endcase
            end
            4'h1: begin
                case (col)
                    4'h0: sout = 8'hCA;
                    4'h1: sout = 8'h82;
                    4'h2: sout = 8'hC9;
                    4'h3: sout = 8'h7D;
                    4'h4: sout = 8'hFA;
                    4'h5: sout = 8'h59;
                    4'h6: sout = 8'h47;
                    4'h7: sout = 8'hF0;
                    4'h8: sout = 8'hAD;
                    4'h9: sout = 8'hD4;
                    4'hA: sout = 8'hA2;
                    4'hB: sout = 8'hAF;
                    4'hC: sout = 8'h9C;
                    4'hD: sout = 8'hA4;
                    4'hE: sout = 8'h72;
                    4'hF: sout = 8'hC0;
                endcase
            end
            4'h2: begin
                case (col)
                    4'h0: sout = 8'hB7;
                    4'h1: sout = 8'hFD;
                    4'h2: sout = 8'h93;
                    4'h3: sout = 8'h26;
                    4'h4: sout = 8'h36;
                    4'h5: sout = 8'h3F;
                    4'h6: sout = 8'hF7;
                    4'h7: sout = 8'hCC;
                    4'h8: sout = 8'h34;
                    4'h9: sout = 8'hA5;
                    4'hA: sout = 8'hE5;
                    4'hB: sout = 8'hF1;
                    4'hC: sout = 8'h71;
                    4'hD: sout = 8'hD8;
                    4'hE: sout = 8'h31;
                    4'hF: sout = 8'h15;
                endcase
            end
            4'h3: begin
                case (col)
                    4'h0: sout = 8'h04;
                    4'h1: sout = 8'hC7;
                    4'h2: sout = 8'h23;
                    4'h3: sout = 8'hC3;
                    4'h4: sout = 8'h18;
                    4'h5: sout = 8'h96;
                    4'h6: sout = 8'h05;
                    4'h7: sout = 8'h9A;
                    4'h8: sout = 8'h07;
                    4'h9: sout = 8'h12;
                    4'hA: sout = 8'h80;
                    4'hB: sout = 8'hE2;
                    4'hC: sout = 8'hEB;
                    4'hD: sout = 8'h27;
                    4'hE: sout = 8'hB2;
                    4'hF: sout = 8'h75;
                endcase
            end
            4'h4: begin
                case (col)
                    4'h0: sout = 8'h09;
                    4'h1: sout = 8'h83;
                    4'h2: sout = 8'h2C;
                    4'h3: sout = 8'h1A;
                    4'h4: sout = 8'h1B;
                    4'h5: sout = 8'h6E;
                    4'h6: sout = 8'h5A;
                    4'h7: sout = 8'hA0;
                    4'h8: sout = 8'h52;
                    4'h9: sout = 8'h3B;
                    4'hA: sout = 8'hD6;
                    4'hB: sout = 8'hB3;
                    4'hC: sout = 8'h29;
                    4'hD: sout = 8'hE3;
                    4'hE: sout = 8'h2F;
                    4'hF: sout = 8'h84;
                endcase
            end
            4'h5: begin
                case (col)
                    4'h0: sout = 8'h53;
                    4'h1: sout = 8'hD1;
                    4'h2: sout = 8'h00;
                    4'h3: sout = 8'hED;
                    4'h4: sout = 8'h20;
                    4'h5: sout = 8'hFC;
                    4'h6: sout = 8'hB1;
                    4'h7: sout = 8'h5B;
                    4'h8: sout = 8'h6A;
                    4'h9: sout = 8'hCB;
                    4'hA: sout = 8'hBE;
                    4'hB: sout = 8'h39;
                    4'hC: sout = 8'h4A;
                    4'hD: sout = 8'h4C;
                    4'hE: sout = 8'h58;
                    4'hF: sout = 8'hCF;
                endcase
            end
            4'h6: begin
                case (col)
                    4'h0: sout = 8'hD0;
                    4'h1: sout = 8'hEF;
                    4'h2: sout = 8'hAA;
                    4'h3: sout = 8'hFB;
                    4'h4: sout = 8'h43;
                    4'h5: sout = 8'h4D;
                    4'h6: sout = 8'h33;
                    4'h7: sout = 8'h85;
                    4'h8: sout = 8'h45;
                    4'h9: sout = 8'hF9;
                    4'hA: sout = 8'h02;
                    4'hB: sout = 8'h7F;
                    4'hC: sout = 8'h50;
                    4'hD: sout = 8'h3C;
                    4'hE: sout = 8'h9F;
                    4'hF: sout = 8'hA8;
                endcase
            end
            4'h7: begin
                case (col)
                    4'h0: sout = 8'h51;
                    4'h1: sout = 8'hA3;
                    4'h2: sout = 8'h40;
                    4'h3: sout = 8'h8F;
                    4'h4: sout = 8'h92;
                    4'h5: sout = 8'h9D;
                    4'h6: sout = 8'h38;
                    4'h7: sout = 8'hF5;
                    4'h8: sout = 8'hBC;
                    4'h9: sout = 8'hB6;
                    4'hA: sout = 8'hDA;
                    4'hB: sout = 8'h21;
                    4'hC: sout = 8'h10;
                    4'hD: sout = 8'hFF;
                    4'hE: sout = 8'hF3;
                    4'hF: sout = 8'hD2;
                endcase
            end
            4'h8: begin
                case (col)
                    4'h0: sout = 8'hCD;
                    4'h1: sout = 8'h0C;
                    4'h2: sout = 8'h13;
                    4'h3: sout = 8'hEC;
                    4'h4: sout = 8'h5F;
                    4'h5: sout = 8'h97;
                    4'h6: sout = 8'h44;
                    4'h7: sout = 8'h17;
                    4'h8: sout = 8'hC4;
                    4'h9: sout = 8'hA7;
                    4'hA: sout = 8'h7E;
                    4'hB: sout = 8'h3D;
                    4'hC: sout = 8'h64;
                    4'hD: sout = 8'h5D;
                    4'hE: sout = 8'h19;
                    4'hF: sout = 8'h73;
                endcase
            end
            4'h9: begin
                case (col)
                    4'h0: sout = 8'h60;
                    4'h1: sout = 8'h81;
                    4'h2: sout = 8'h4F;
                    4'h3: sout = 8'hDC;
                    4'h4: sout = 8'h22;
                    4'h5: sout = 8'h2A;
                    4'h6: sout = 8'h90;
                    4'h7: sout = 8'h88;
                    4'h8: sout = 8'h46;
                    4'h9: sout = 8'hEE;
                    4'hA: sout = 8'hB8;
                    4'hB: sout = 8'h14;
                    4'hC: sout = 8'hDE;
                    4'hD: sout = 8'h5E;
                    4'hE: sout = 8'h0B;
                    4'hF: sout = 8'hDB;
                endcase
            end
            4'hA: begin
                case (col)
                    4'h0: sout = 8'hE0;
                    4'h1: sout = 8'h32;
                    4'h2: sout = 8'h3A;
                    4'h3: sout = 8'h0A;
                    4'h4: sout = 8'h49;
                    4'h5: sout = 8'h06;
                    4'h6: sout = 8'h24;
                    4'h7: sout = 8'h5C;
                    4'h8: sout = 8'hC2;
                    4'h9: sout = 8'hD3;
                    4'hA: sout = 8'hAC;
                    4'hB: sout = 8'h62;
                    4'hC: sout = 8'h91;
                    4'hD: sout = 8'h95;
                    4'hE: sout = 8'hE4;
                    4'hF: sout = 8'h79;
                endcase
            end
            4'hB: begin
                case (col)
                    4'h0: sout = 8'hE7;
                    4'h1: sout = 8'hC8;
                    4'h2: sout = 8'h37;
                    4'h3: sout = 8'h6D;
                    4'h4: sout = 8'h8D;
                    4'h5: sout = 8'hD5;
                    4'h6: sout = 8'h4E;
                    4'h7: sout = 8'hA9;
                    4'h8: sout = 8'h6C;
                    4'h9: sout = 8'h56;
                    4'hA: sout = 8'hF4;
                    4'hB: sout = 8'hEA;
                    4'hC: sout = 8'h65;
                    4'hD: sout = 8'h7A;
                    4'hE: sout = 8'hAE;
                    4'hF: sout = 8'h08;
                endcase
            end
            4'hC: begin
                case (col)
                    4'h0: sout = 8'hBA;
                    4'h1: sout = 8'h78;
                    4'h2: sout = 8'h25;
                    4'h3: sout = 8'h2E;
                    4'h4: sout = 8'h1C;
                    4'h5: sout = 8'hA6;
                    4'h6: sout = 8'hB4;
                    4'h7: sout = 8'hC6;
                    4'h8: sout = 8'hE8;
                    4'h9: sout = 8'hDD;
                    4'hA: sout = 8'h74;
                    4'hB: sout = 8'h1F;
                    4'hC: sout = 8'h4B;
                    4'hD: sout = 8'hBD;
                    4'hE: sout = 8'h8B;
                    4'hF: sout = 8'h8A;
                endcase
            end
            4'hD: begin
                case (col)
                    4'h0: sout = 8'h70;
                    4'h1: sout = 8'h3E;
                    4'h2: sout = 8'hB5;
                    4'h3: sout = 8'h66;
                    4'h4: sout = 8'h48;
                    4'h5: sout = 8'h03;
                    4'h6: sout = 8'hF6;
                    4'h7: sout = 8'h0E;
                    4'h8: sout = 8'h61;
                    4'h9: sout = 8'h35;
                    4'hA: sout = 8'h57;
                    4'hB: sout = 8'hB9;
                    4'hC: sout = 8'h86;
                    4'hD: sout = 8'hC1;
                    4'hE: sout = 8'h1D;
                    4'hF: sout = 8'h9E;
                endcase
            end
            4'hE: begin
                case (col)
                    4'h0: sout = 8'hE1;
                    4'h1: sout = 8'hF8;
                    4'h2: sout = 8'h98;
                    4'h3: sout = 8'h11;
                    4'h4: sout = 8'h69;
                    4'h5: sout = 8'hD9;
                    4'h6: sout = 8'h8E;
                    4'h7: sout = 8'h94;
                    4'h8: sout = 8'h9B;
                    4'h9: sout = 8'h1E;
                    4'hA: sout = 8'h87;
                    4'hB: sout = 8'hE9;
                    4'hC: sout = 8'hCE;
                    4'hD: sout = 8'h55;
                    4'hE: sout = 8'h28;
                    4'hF: sout = 8'hDF;
                endcase
            end
            4'hF: begin
                case (col)
                    4'h0: sout = 8'h8C;
                    4'h1: sout = 8'hA1;
                    4'h2: sout = 8'h89;
                    4'h3: sout = 8'h0D;
                    4'h4: sout = 8'hBF;
                    4'h5: sout = 8'hE6;
                    4'h6: sout = 8'h42;
                    4'h7: sout = 8'h68;
                    4'h8: sout = 8'h41;
                    4'h9: sout = 8'h99;
                    4'hA: sout = 8'h2D;
                    4'hB: sout = 8'h0F;
                    4'hC: sout = 8'hB0;
                    4'hD: sout = 8'h54;
                    4'hE: sout = 8'hBB;
                    4'hF: sout = 8'h16;
                endcase
            end
        endcase
    end

endmodule