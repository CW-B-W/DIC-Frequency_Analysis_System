module FIR(clk, rst, data_valid, data, fir_valid, fir_d);

input              clk, rst;
input              data_valid;
input       [15:0] data;
output reg         fir_valid;
output reg  [15:0] fir_d;

reg         [10:0] sig_idx;
reg         [15:0] sig      [31:0]; /* should always be positive */
wire        [23:0] v        [31:0]; /* 1 bit, 7 bits, 16 bits    */
wire        [23:0] y;

reg         [19:0] FIR_C [31:0];

integer i;

task fp_mul;
    input  signed     [19:0] vc; /* 1 bit, 3 bits, 16 bits */
    input  signed     [15:0] vx; /* 1 bit, 7 bits,  8 bits */
    output reg signed [23:0] vy; /* 1 bit, 7 bits, 16 bits */
    reg signed        [31:0] vt; /* intermediate value     */

    begin
        vt = vc * vx;
        vy = vt[31:8];
    end
endtask

always@(posedge clk, posedge rst) begin
    if (rst) begin
        fir_valid <= 0;
        fir_d     <= 0;
        sig_idx   <= 0;
        for (i = 0; i < 32; i = i + 1) begin
            sig[i] <= 0;
        end

        FIR_C[00] = 20'hFFF9E ;
        FIR_C[01] = 20'hFFF86 ;
        FIR_C[02] = 20'hFFFA7 ;
        FIR_C[03] = 20'h0003B ;
        FIR_C[04] = 20'h0014B ;
        FIR_C[05] = 20'h0024A ;
        FIR_C[06] = 20'h00222 ;
        FIR_C[07] = 20'hFFFE4 ;
        FIR_C[08] = 20'hFFBC5 ;
        FIR_C[09] = 20'hFF7CA ;
        FIR_C[10] = 20'hFF74E ;
        FIR_C[11] = 20'hFFD74 ;
        FIR_C[12] = 20'h00B1A ;
        FIR_C[13] = 20'h01DAC ;
        FIR_C[14] = 20'h02F9E ;
        FIR_C[15] = 20'h03AA9 ;
        FIR_C[16] = 20'h03AA9 ;
        FIR_C[17] = 20'h02F9E ;
        FIR_C[18] = 20'h01DAC ;
        FIR_C[19] = 20'h00B1A ;
        FIR_C[20] = 20'hFFD74 ;
        FIR_C[21] = 20'hFF74E ;
        FIR_C[22] = 20'hFF7CA ;
        FIR_C[23] = 20'hFFBC5 ;
        FIR_C[24] = 20'hFFFE4 ;
        FIR_C[25] = 20'h00222 ;
        FIR_C[26] = 20'h0024A ;
        FIR_C[27] = 20'h0014B ;
        FIR_C[28] = 20'h0003B ;
        FIR_C[29] = 20'hFFFA7 ;
        FIR_C[30] = 20'hFFF86 ;
        FIR_C[31] = 20'hFFF9E ;
    end
    else begin
        if (sig_idx >= 32) begin
            fir_valid <= 1;
            fir_d     <= {y[23:8] + y[23]}; // !!! WHY??? if without `+ y[23]`, precision error happens
        end
        else if (sig_idx >= 1024+32) begin
            fir_valid <= 0;
            fir_d     <= 0;
        end

        for (i = 0; i <= 30; i = i + 1) begin
            sig[i] <= sig[i+1];
        end
        if (sig_idx < 1024)
            sig[31] <= data;
        else
            sig[31] <= 0;

        sig_idx <= sig_idx + 1;
    end
end

// https://ideone.com/TK8V0C
assign y = (((((v[0]) + (v[1])) + ((v[2]) + (v[3]))) + (((v[4]) + (v[5])) + ((v[6]) + (v[7])))) + ((((v[8]) + (v[9])) + ((v[10]) + (v[11]))) + (((v[12]) + (v[13])) + ((v[14]) + (v[15]))))) + (((((v[16]) + (v[17])) + ((v[18]) + (v[19]))) + (((v[20]) + (v[21])) + ((v[22]) + (v[23])))) + ((((v[24]) + (v[25])) + ((v[26]) + (v[27]))) + (((v[28]) + (v[29])) + ((v[30]) + (v[31])))));

genvar idx;
generate
    for (idx = 0; idx < 32; idx = idx + 1) begin: FIR_BLOCK
        fp_mul_fir m_fir(FIR_C[idx], sig[idx], v[idx]);
    end
endgenerate

endmodule

//----------------------------------------------------------------
module fp_mul_fir(vc, vx, vy);
//----------------------------------------------------------------
    input  signed [19:0] vc; /* 1 bit, 3 bits, 16 bits */
    input  signed [15:0] vx; /* 1 bit, 7 bits,  8 bits */
    output signed [23:0] vy; /* 1 bit, 7 bits, 16 bits */
    wire   signed [31:0] vt; /* intermediate value     */

    assign vt = vc * vx;
    assign vy = vt[31:8];
endmodule