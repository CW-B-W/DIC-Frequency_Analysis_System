module Analysis(clk, rst, fft_valid,
           fft_d0, fft_d1, fft_d2 , fft_d3 , fft_d4 , fft_d5 , fft_d6 , fft_d7,
           fft_d8, fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15,
           done, freq);

input         clk, rst;
input         fft_valid;
input  [31:0] fft_d0;
input  [31:0] fft_d1;
input  [31:0] fft_d2;
input  [31:0] fft_d3;
input  [31:0] fft_d4;
input  [31:0] fft_d5;
input  [31:0] fft_d6;
input  [31:0] fft_d7;
input  [31:0] fft_d8;
input  [31:0] fft_d9;
input  [31:0] fft_d10;
input  [31:0] fft_d11;
input  [31:0] fft_d12;
input  [31:0] fft_d13;
input  [31:0] fft_d14;
input  [31:0] fft_d15;
output        done;
output  [3:0] freq;

wire [31:0] amp [15:0];
reg  [5:0]  fft_cnt;

assign amp[0] = ($signed(fft_d0[31:16]) * $signed(fft_d0[31:16])) + ($signed(fft_d0[15:0]) * $signed(fft_d0[15:0]));
assign amp[1] = ($signed(fft_d1[31:16]) * $signed(fft_d1[31:16])) + ($signed(fft_d1[15:0]) * $signed(fft_d1[15:0]));
assign amp[2] = ($signed(fft_d2[31:16]) * $signed(fft_d2[31:16])) + ($signed(fft_d2[15:0]) * $signed(fft_d2[15:0]));
assign amp[3] = ($signed(fft_d3[31:16]) * $signed(fft_d3[31:16])) + ($signed(fft_d3[15:0]) * $signed(fft_d3[15:0]));
assign amp[4] = ($signed(fft_d4[31:16]) * $signed(fft_d4[31:16])) + ($signed(fft_d4[15:0]) * $signed(fft_d4[15:0]));
assign amp[5] = ($signed(fft_d5[31:16]) * $signed(fft_d5[31:16])) + ($signed(fft_d5[15:0]) * $signed(fft_d5[15:0]));
assign amp[6] = ($signed(fft_d6[31:16]) * $signed(fft_d6[31:16])) + ($signed(fft_d6[15:0]) * $signed(fft_d6[15:0]));
assign amp[7] = ($signed(fft_d7[31:16]) * $signed(fft_d7[31:16])) + ($signed(fft_d7[15:0]) * $signed(fft_d7[15:0]));
assign amp[8] = ($signed(fft_d8[31:16]) * $signed(fft_d8[31:16])) + ($signed(fft_d8[15:0]) * $signed(fft_d8[15:0]));
assign amp[9] = ($signed(fft_d9[31:16]) * $signed(fft_d9[31:16])) + ($signed(fft_d9[15:0]) * $signed(fft_d9[15:0]));
assign amp[10] = ($signed(fft_d10[31:16]) * $signed(fft_d10[31:16])) + ($signed(fft_d10[15:0]) * $signed(fft_d10[15:0]));
assign amp[11] = ($signed(fft_d11[31:16]) * $signed(fft_d11[31:16])) + ($signed(fft_d11[15:0]) * $signed(fft_d11[15:0]));
assign amp[12] = ($signed(fft_d12[31:16]) * $signed(fft_d12[31:16])) + ($signed(fft_d12[15:0]) * $signed(fft_d12[15:0]));
assign amp[13] = ($signed(fft_d13[31:16]) * $signed(fft_d13[31:16])) + ($signed(fft_d13[15:0]) * $signed(fft_d13[15:0]));
assign amp[14] = ($signed(fft_d14[31:16]) * $signed(fft_d14[31:16])) + ($signed(fft_d14[15:0]) * $signed(fft_d14[15:0]));
assign amp[15] = ($signed(fft_d15[31:16]) * $signed(fft_d15[31:16])) + ($signed(fft_d15[15:0]) * $signed(fft_d15[15:0]));

genvar i;
generate
    wire [3:0] const_i [15:0];
    for (i = 0; i < 16; i = i + 1) begin: CONST_I
        assign const_i[i] = i;
    end

    wire [35:0] v1[7:0];
    for (i = 0; i < 16; i = i + 2) begin: MAX1
        max m1({amp[i], const_i[i]}, {amp[i+1], const_i[i+1]}, v1[i/2]);
    end

    wire [35:0] v2[3:0];
    for (i = 0; i < 8; i = i + 2) begin: MAX2
        max m2(v1[i], v1[i+1], v2[i/2]);
    end

    wire [35:0] v3[1:0];
    for (i = 0; i < 4; i = i + 2) begin: MAX3
        max m3(v2[i], v2[i+1], v3[i/2]);
    end

    wire [35:0] v4;
    max m4(v3[0], v3[1], v4);
endgenerate

assign freq = v4[3:0];
assign done = fft_valid && fft_cnt < (31) ? 1 : 0;

always@(posedge clk, posedge rst) begin
    if (rst)
        fft_cnt <= 0;
    else
        if (fft_valid)
            fft_cnt <= fft_cnt + 1;
end

endmodule

module max(a, b, value);
    input  [35:0] a;
    input  [35:0] b;
    output [35:0] value;

    assign value = (a >= b) ? a : b;
endmodule