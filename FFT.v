module FFT(clk, rst, fir_valid, fir_d, fft_valid,
           fft_d0, fft_d1, fft_d2 , fft_d3 , fft_d4 , fft_d5 , fft_d6 , fft_d7,
           fft_d8, fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15);

// https://ideone.com/rQX0oSs
parameter [31:0] W_REAL_00 = 32'h00010000;
parameter [31:0] W_REAL_01 = 32'h0000EC83;
parameter [31:0] W_REAL_02 = 32'h0000B504;
parameter [31:0] W_REAL_03 = 32'h000061F7;
parameter [31:0] W_REAL_04 = 32'h00000000;
parameter [31:0] W_REAL_05 = 32'hFFFF9E09;
parameter [31:0] W_REAL_06 = 32'hFFFF4AFC;
parameter [31:0] W_REAL_07 = 32'hFFFF137D;
parameter [31:0] W_IMAG_00 = 32'h00000000;
parameter [31:0] W_IMAG_01 = 32'hFFFF9E09;
parameter [31:0] W_IMAG_02 = 32'hFFFF4AFC;
parameter [31:0] W_IMAG_03 = 32'hFFFF137D;
parameter [31:0] W_IMAG_04 = 32'hFFFF0000;
parameter [31:0] W_IMAG_05 = 32'hFFFF137D;
parameter [31:0] W_IMAG_06 = 32'hFFFF4AFC;
parameter [31:0] W_IMAG_07 = 32'hFFFF9E09;

input             clk, rst;
input             fir_valid;
input      [15:0] fir_d;
output reg        fft_valid;
output reg [31:0] fft_d0;
output reg [31:0] fft_d1;
output reg [31:0] fft_d2;
output reg [31:0] fft_d3;
output reg [31:0] fft_d4;
output reg [31:0] fft_d5;
output reg [31:0] fft_d6;
output reg [31:0] fft_d7;
output reg [31:0] fft_d8;
output reg [31:0] fft_d9;
output reg [31:0] fft_d10;
output reg [31:0] fft_d11;
output reg [31:0] fft_d12;
output reg [31:0] fft_d13;
output reg [31:0] fft_d14;
output reg [31:0] fft_d15;

reg        [ 3:0] rd_idx;

reg        [31:0] x_d4_real [15:0];
// reg        [31:0] x_d4_imag [15:0]; /* always 0 */

integer i;

task fp_mul;
    input      [31:0] vc; /* 1 bit, 15 bits, 16 bits    */
    input      [31:0] vx; /* 1 bit, 15 bits, 16 bits    */
    output reg [31:0] vy; /* 1 bit, 15 bits, 16 bits    */
    reg        [47:0] vt; /* intermediate value         */

    reg s = vc[31] ^ vx[31];

    begin
        if (vc[31])
            vc = ~vc + 1;
        if (vx[31])
            vx = ~vx + 1;

        vt = vc * vx;
        if (s == 0)
            vy = vt[47:16] + vt[15];
        else
            vy = ~(vt[47:16] + vt[15]) + 1;
    end
endtask

task complex_mul;
    // a + bi
    input      [31:0] a;
    input      [31:0] b;
    // c + di
    input      [31:0] c;
    input      [31:0] d;
    // e + fi
    output reg [31:0] e; // ac - bd
    output reg [31:0] f; // ad + bc
    reg [31:0] ac;
    reg [31:0] bd;
    reg [31:0] ad;
    reg [31:0] bc;
    
    begin
        fp_mul(a, c, ac);
        fp_mul(b, d, bd);
        e = ac - bd;
        fp_mul(a, d, ad);
        fp_mul(b, c, bc);
        f = ad + bc;
    end
endtask

always@(posedge clk, posedge rst) begin
    if (rst) begin
        rd_idx <= 0;
    end
    else begin
        if (rd_idx == 15) begin
            fft_valid = 1;
            fft_d0  <= ({16'd0, x_d0_real[0]} << 16)  | x_d0_imag[0];
            fft_d1  <= ({16'd0, x_d0_real[1]} << 16)  | x_d0_imag[1];
            fft_d2  <= ({16'd0, x_d0_real[2]} << 16)  | x_d0_imag[2];
            fft_d3  <= ({16'd0, x_d0_real[3]} << 16)  | x_d0_imag[3];
            fft_d4  <= ({16'd0, x_d0_real[4]} << 16)  | x_d0_imag[4];
            fft_d5  <= ({16'd0, x_d0_real[5]} << 16)  | x_d0_imag[5];
            fft_d6  <= ({16'd0, x_d0_real[6]} << 16)  | x_d0_imag[6];
            fft_d7  <= ({16'd0, x_d0_real[7]} << 16)  | x_d0_imag[7];
            fft_d8  <= ({16'd0, x_d0_real[8]} << 16)  | x_d0_imag[8];
            fft_d9  <= ({16'd0, x_d0_real[9]} << 16)  | x_d0_imag[9];
            fft_d10 <= ({16'd0, x_d0_real[10]} << 16) | x_d0_imag[10];
            fft_d11 <= ({16'd0, x_d0_real[11]} << 16) | x_d0_imag[11];
            fft_d12 <= ({16'd0, x_d0_real[12]} << 16) | x_d0_imag[12];
            fft_d13 <= ({16'd0, x_d0_real[13]} << 16) | x_d0_imag[13];
            fft_d14 <= ({16'd0, x_d0_real[14]} << 16) | x_d0_imag[14];
            fft_d15 <= ({16'd0, x_d0_real[15]} << 16) | x_d0_imag[15];
        end
        
        for (i = 0; i  <= 14; i = i + 1) begin
            x_d4_real[i] <= x_d4_real[i+1];
        end
        x_d4_real[15]    <= {{8{fir_d[15]}}, fir_d, 8'b0};
        
        if (rd_idx == 15) begin
            rd_idx <= 0;
        end
        else begin
            rd_idx <= rd_idx + 1;
        end
    end
end

// generate below: https://ideone.com/YKCI9I
/******************** depth 3 ********************/
wire [31:0] x_d3_real [15:0];
wire [31:0] x_d3_imag [15:0];

    /*-------------------- pair 0 -------------------*/
    wire [31:0] w0x8_real;
    wire [31:0] w0x8_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[8], 0, w0x8_real, w0x8_imag);
    assign x_d3_real[0] = x_d4_real[0] + w0x8_real;
    assign x_d3_imag[0] = 0 + w0x8_imag;
    assign x_d3_real[8] = x_d4_real[0] + w0x8_real;
    assign x_d3_imag[8] = 0 + w0x8_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 1 -------------------*/
    wire [31:0] w0x12_real;
    wire [31:0] w0x12_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[12], 0, w0x12_real, w0x12_imag);
    assign x_d3_real[4] = x_d4_real[4] + w0x12_real;
    assign x_d3_imag[4] = 0 + w0x12_imag;
    assign x_d3_real[12] = x_d4_real[4] + w0x12_real;
    assign x_d3_imag[12] = 0 + w0x12_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 2 -------------------*/
    wire [31:0] w0x10_real;
    wire [31:0] w0x10_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[10], 0, w0x10_real, w0x10_imag);
    assign x_d3_real[2] = x_d4_real[2] + w0x10_real;
    assign x_d3_imag[2] = 0 + w0x10_imag;
    assign x_d3_real[10] = x_d4_real[2] + w0x10_real;
    assign x_d3_imag[10] = 0 + w0x10_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 3 -------------------*/
    wire [31:0] w0x14_real;
    wire [31:0] w0x14_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[14], 0, w0x14_real, w0x14_imag);
    assign x_d3_real[6] = x_d4_real[6] + w0x14_real;
    assign x_d3_imag[6] = 0 + w0x14_imag;
    assign x_d3_real[14] = x_d4_real[6] + w0x14_real;
    assign x_d3_imag[14] = 0 + w0x14_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 4 -------------------*/
    wire [31:0] w0x9_real;
    wire [31:0] w0x9_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[9], 0, w0x9_real, w0x9_imag);
    assign x_d3_real[1] = x_d4_real[1] + w0x9_real;
    assign x_d3_imag[1] = 0 + w0x9_imag;
    assign x_d3_real[9] = x_d4_real[1] + w0x9_real;
    assign x_d3_imag[9] = 0 + w0x9_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 5 -------------------*/
    wire [31:0] w0x13_real;
    wire [31:0] w0x13_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[13], 0, w0x13_real, w0x13_imag);
    assign x_d3_real[5] = x_d4_real[5] + w0x13_real;
    assign x_d3_imag[5] = 0 + w0x13_imag;
    assign x_d3_real[13] = x_d4_real[5] + w0x13_real;
    assign x_d3_imag[13] = 0 + w0x13_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 6 -------------------*/
    wire [31:0] w0x11_real;
    wire [31:0] w0x11_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[11], 0, w0x11_real, w0x11_imag);
    assign x_d3_real[3] = x_d4_real[3] + w0x11_real;
    assign x_d3_imag[3] = 0 + w0x11_imag;
    assign x_d3_real[11] = x_d4_real[3] + w0x11_real;
    assign x_d3_imag[11] = 0 + w0x11_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 7 -------------------*/
    wire [31:0] w0x15_real;
    wire [31:0] w0x15_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d4_real[15], 0, w0x15_real, w0x15_imag);
    assign x_d3_real[7] = x_d4_real[7] + w0x15_real;
    assign x_d3_imag[7] = 0 + w0x15_imag;
    assign x_d3_real[15] = x_d4_real[7] + w0x15_real;
    assign x_d3_imag[15] = 0 + w0x15_imag;
    /*---------------------- End ---------------------*/

/********************** End **********************/
/******************** depth 2 ********************/
wire [31:0] x_d2_real [15:0];
wire [31:0] x_d2_imag [15:0];

    /*-------------------- pair 0 -------------------*/
    wire [31:0] w0x4_real;
    wire [31:0] w0x4_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d3_real[4], x_d3_imag[4], w0x4_real, w0x4_imag);
    assign x_d2_real[0] = x_d3_real[0] + w0x4_real;
    assign x_d2_imag[0] = x_d3_imag[0] + w0x4_imag;
    assign x_d2_real[4] = x_d3_real[0] + w0x4_real;
    assign x_d2_imag[4] = x_d3_imag[0] + w0x4_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 1 -------------------*/
    wire [31:0] w4x12_real;
    wire [31:0] w4x12_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d3_real[12], x_d3_imag[12], w4x12_real, w4x12_imag);
    assign x_d2_real[8] = x_d3_real[8] + w4x12_real;
    assign x_d2_imag[8] = x_d3_imag[8] + w4x12_imag;
    assign x_d2_real[12] = x_d3_real[8] + w4x12_real;
    assign x_d2_imag[12] = x_d3_imag[8] + w4x12_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 2 -------------------*/
    wire [31:0] w0x6_real;
    wire [31:0] w0x6_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d3_real[6], x_d3_imag[6], w0x6_real, w0x6_imag);
    assign x_d2_real[2] = x_d3_real[2] + w0x6_real;
    assign x_d2_imag[2] = x_d3_imag[2] + w0x6_imag;
    assign x_d2_real[6] = x_d3_real[2] + w0x6_real;
    assign x_d2_imag[6] = x_d3_imag[2] + w0x6_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 3 -------------------*/
    wire [31:0] w4x14_real;
    wire [31:0] w4x14_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d3_real[14], x_d3_imag[14], w4x14_real, w4x14_imag);
    assign x_d2_real[10] = x_d3_real[10] + w4x14_real;
    assign x_d2_imag[10] = x_d3_imag[10] + w4x14_imag;
    assign x_d2_real[14] = x_d3_real[10] + w4x14_real;
    assign x_d2_imag[14] = x_d3_imag[10] + w4x14_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 4 -------------------*/
    wire [31:0] w0x5_real;
    wire [31:0] w0x5_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d3_real[5], x_d3_imag[5], w0x5_real, w0x5_imag);
    assign x_d2_real[1] = x_d3_real[1] + w0x5_real;
    assign x_d2_imag[1] = x_d3_imag[1] + w0x5_imag;
    assign x_d2_real[5] = x_d3_real[1] + w0x5_real;
    assign x_d2_imag[5] = x_d3_imag[1] + w0x5_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 5 -------------------*/
    wire [31:0] w4x13_real;
    wire [31:0] w4x13_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d3_real[13], x_d3_imag[13], w4x13_real, w4x13_imag);
    assign x_d2_real[9] = x_d3_real[9] + w4x13_real;
    assign x_d2_imag[9] = x_d3_imag[9] + w4x13_imag;
    assign x_d2_real[13] = x_d3_real[9] + w4x13_real;
    assign x_d2_imag[13] = x_d3_imag[9] + w4x13_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 6 -------------------*/
    wire [31:0] w0x7_real;
    wire [31:0] w0x7_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d3_real[7], x_d3_imag[7], w0x7_real, w0x7_imag);
    assign x_d2_real[3] = x_d3_real[3] + w0x7_real;
    assign x_d2_imag[3] = x_d3_imag[3] + w0x7_imag;
    assign x_d2_real[7] = x_d3_real[3] + w0x7_real;
    assign x_d2_imag[7] = x_d3_imag[3] + w0x7_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 7 -------------------*/
    wire [31:0] w4x15_real;
    wire [31:0] w4x15_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d3_real[15], x_d3_imag[15], w4x15_real, w4x15_imag);
    assign x_d2_real[11] = x_d3_real[11] + w4x15_real;
    assign x_d2_imag[11] = x_d3_imag[11] + w4x15_imag;
    assign x_d2_real[15] = x_d3_real[11] + w4x15_real;
    assign x_d2_imag[15] = x_d3_imag[11] + w4x15_imag;
    /*---------------------- End ---------------------*/

/********************** End **********************/
/******************** depth 1 ********************/
wire [31:0] x_d1_real [15:0];
wire [31:0] x_d1_imag [15:0];

    /*-------------------- pair 0 -------------------*/
    wire [31:0] w0x2_real;
    wire [31:0] w0x2_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d2_real[2], x_d2_imag[2], w0x2_real, w0x2_imag);
    assign x_d1_real[0] = x_d2_real[0] + w0x2_real;
    assign x_d1_imag[0] = x_d2_imag[0] + w0x2_imag;
    assign x_d1_real[2] = x_d2_real[0] + w0x2_real;
    assign x_d1_imag[2] = x_d2_imag[0] + w0x2_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 1 -------------------*/
    wire [31:0] w2x6_real;
    wire [31:0] w2x6_imag;
    always@(*) complex_mul(W_REAL_02, W_IMAG_02, x_d2_real[6], x_d2_imag[6], w2x6_real, w2x6_imag);
    assign x_d1_real[4] = x_d2_real[4] + w2x6_real;
    assign x_d1_imag[4] = x_d2_imag[4] + w2x6_imag;
    assign x_d1_real[6] = x_d2_real[4] + w2x6_real;
    assign x_d1_imag[6] = x_d2_imag[4] + w2x6_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 2 -------------------*/
    wire [31:0] w4x10_real;
    wire [31:0] w4x10_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d2_real[10], x_d2_imag[10], w4x10_real, w4x10_imag);
    assign x_d1_real[8] = x_d2_real[8] + w4x10_real;
    assign x_d1_imag[8] = x_d2_imag[8] + w4x10_imag;
    assign x_d1_real[10] = x_d2_real[8] + w4x10_real;
    assign x_d1_imag[10] = x_d2_imag[8] + w4x10_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 3 -------------------*/
    wire [31:0] w6x14_real;
    wire [31:0] w6x14_imag;
    always@(*) complex_mul(W_REAL_06, W_IMAG_06, x_d2_real[14], x_d2_imag[14], w6x14_real, w6x14_imag);
    assign x_d1_real[12] = x_d2_real[12] + w6x14_real;
    assign x_d1_imag[12] = x_d2_imag[12] + w6x14_imag;
    assign x_d1_real[14] = x_d2_real[12] + w6x14_real;
    assign x_d1_imag[14] = x_d2_imag[12] + w6x14_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 4 -------------------*/
    wire [31:0] w0x3_real;
    wire [31:0] w0x3_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d2_real[3], x_d2_imag[3], w0x3_real, w0x3_imag);
    assign x_d1_real[1] = x_d2_real[1] + w0x3_real;
    assign x_d1_imag[1] = x_d2_imag[1] + w0x3_imag;
    assign x_d1_real[3] = x_d2_real[1] + w0x3_real;
    assign x_d1_imag[3] = x_d2_imag[1] + w0x3_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 5 -------------------*/
    wire [31:0] w2x7_real;
    wire [31:0] w2x7_imag;
    always@(*) complex_mul(W_REAL_02, W_IMAG_02, x_d2_real[7], x_d2_imag[7], w2x7_real, w2x7_imag);
    assign x_d1_real[5] = x_d2_real[5] + w2x7_real;
    assign x_d1_imag[5] = x_d2_imag[5] + w2x7_imag;
    assign x_d1_real[7] = x_d2_real[5] + w2x7_real;
    assign x_d1_imag[7] = x_d2_imag[5] + w2x7_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 6 -------------------*/
    wire [31:0] w4x11_real;
    wire [31:0] w4x11_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d2_real[11], x_d2_imag[11], w4x11_real, w4x11_imag);
    assign x_d1_real[9] = x_d2_real[9] + w4x11_real;
    assign x_d1_imag[9] = x_d2_imag[9] + w4x11_imag;
    assign x_d1_real[11] = x_d2_real[9] + w4x11_real;
    assign x_d1_imag[11] = x_d2_imag[9] + w4x11_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 7 -------------------*/
    wire [31:0] w6x15_real;
    wire [31:0] w6x15_imag;
    always@(*) complex_mul(W_REAL_06, W_IMAG_06, x_d2_real[15], x_d2_imag[15], w6x15_real, w6x15_imag);
    assign x_d1_real[13] = x_d2_real[13] + w6x15_real;
    assign x_d1_imag[13] = x_d2_imag[13] + w6x15_imag;
    assign x_d1_real[15] = x_d2_real[13] + w6x15_real;
    assign x_d1_imag[15] = x_d2_imag[13] + w6x15_imag;
    /*---------------------- End ---------------------*/

/********************** End **********************/
/******************** depth 0 ********************/
wire [31:0] x_d0_real [15:0];
wire [31:0] x_d0_imag [15:0];

    /*-------------------- pair 0 -------------------*/
    wire [31:0] w0x1_real;
    wire [31:0] w0x1_imag;
    always@(*) complex_mul(W_REAL_00, W_IMAG_00, x_d1_real[1], x_d1_imag[1], w0x1_real, w0x1_imag);
    assign x_d0_real[0] = x_d1_real[0] + w0x1_real;
    assign x_d0_imag[0] = x_d1_imag[0] + w0x1_imag;
    assign x_d0_real[1] = x_d1_real[0] + w0x1_real;
    assign x_d0_imag[1] = x_d1_imag[0] + w0x1_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 1 -------------------*/
    wire [31:0] w1x3_real;
    wire [31:0] w1x3_imag;
    always@(*) complex_mul(W_REAL_01, W_IMAG_01, x_d1_real[3], x_d1_imag[3], w1x3_real, w1x3_imag);
    assign x_d0_real[2] = x_d1_real[2] + w1x3_real;
    assign x_d0_imag[2] = x_d1_imag[2] + w1x3_imag;
    assign x_d0_real[3] = x_d1_real[2] + w1x3_real;
    assign x_d0_imag[3] = x_d1_imag[2] + w1x3_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 2 -------------------*/
    wire [31:0] w2x5_real;
    wire [31:0] w2x5_imag;
    always@(*) complex_mul(W_REAL_02, W_IMAG_02, x_d1_real[5], x_d1_imag[5], w2x5_real, w2x5_imag);
    assign x_d0_real[4] = x_d1_real[4] + w2x5_real;
    assign x_d0_imag[4] = x_d1_imag[4] + w2x5_imag;
    assign x_d0_real[5] = x_d1_real[4] + w2x5_real;
    assign x_d0_imag[5] = x_d1_imag[4] + w2x5_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 3 -------------------*/
    wire [31:0] w3x7_real;
    wire [31:0] w3x7_imag;
    always@(*) complex_mul(W_REAL_03, W_IMAG_03, x_d1_real[7], x_d1_imag[7], w3x7_real, w3x7_imag);
    assign x_d0_real[6] = x_d1_real[6] + w3x7_real;
    assign x_d0_imag[6] = x_d1_imag[6] + w3x7_imag;
    assign x_d0_real[7] = x_d1_real[6] + w3x7_real;
    assign x_d0_imag[7] = x_d1_imag[6] + w3x7_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 4 -------------------*/
    wire [31:0] w4x9_real;
    wire [31:0] w4x9_imag;
    always@(*) complex_mul(W_REAL_04, W_IMAG_04, x_d1_real[9], x_d1_imag[9], w4x9_real, w4x9_imag);
    assign x_d0_real[8] = x_d1_real[8] + w4x9_real;
    assign x_d0_imag[8] = x_d1_imag[8] + w4x9_imag;
    assign x_d0_real[9] = x_d1_real[8] + w4x9_real;
    assign x_d0_imag[9] = x_d1_imag[8] + w4x9_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 5 -------------------*/
    wire [31:0] w5x11_real;
    wire [31:0] w5x11_imag;
    always@(*) complex_mul(W_REAL_05, W_IMAG_05, x_d1_real[11], x_d1_imag[11], w5x11_real, w5x11_imag);
    assign x_d0_real[10] = x_d1_real[10] + w5x11_real;
    assign x_d0_imag[10] = x_d1_imag[10] + w5x11_imag;
    assign x_d0_real[11] = x_d1_real[10] + w5x11_real;
    assign x_d0_imag[11] = x_d1_imag[10] + w5x11_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 6 -------------------*/
    wire [31:0] w6x13_real;
    wire [31:0] w6x13_imag;
    always@(*) complex_mul(W_REAL_06, W_IMAG_06, x_d1_real[13], x_d1_imag[13], w6x13_real, w6x13_imag);
    assign x_d0_real[12] = x_d1_real[12] + w6x13_real;
    assign x_d0_imag[12] = x_d1_imag[12] + w6x13_imag;
    assign x_d0_real[13] = x_d1_real[12] + w6x13_real;
    assign x_d0_imag[13] = x_d1_imag[12] + w6x13_imag;
    /*---------------------- End ---------------------*/

    /*-------------------- pair 7 -------------------*/
    wire [31:0] w7x15_real;
    wire [31:0] w7x15_imag;
    always@(*) complex_mul(W_REAL_07, W_IMAG_07, x_d1_real[15], x_d1_imag[15], w7x15_real, w7x15_imag);
    assign x_d0_real[14] = x_d1_real[14] + w7x15_real;
    assign x_d0_imag[14] = x_d1_imag[14] + w7x15_imag;
    assign x_d0_real[15] = x_d1_real[14] + w7x15_real;
    assign x_d0_imag[15] = x_d1_imag[14] + w7x15_imag;
    /*---------------------- End ---------------------*/

/********************** End **********************/

/*
order of FFT: https://ideone.com/i4gX6B
x[i] is complex
depth 3:
	x[ 0] = x[ 0] + w0 * x[ 8]
	x[ 8] = x[ 0] - w0 * x[ 8]
	x[ 4] = x[ 4] + w0 * x[12]
	x[12] = x[ 4] - w0 * x[12]
	x[ 2] = x[ 2] + w0 * x[10]
	x[10] = x[ 2] - w0 * x[10]
	x[ 6] = x[ 6] + w0 * x[14]
	x[14] = x[ 6] - w0 * x[14]
	x[ 1] = x[ 1] + w0 * x[ 9]
	x[ 9] = x[ 1] - w0 * x[ 9]
	x[ 5] = x[ 5] + w0 * x[13]
	x[13] = x[ 5] - w0 * x[13]
	x[ 3] = x[ 3] + w0 * x[11]
	x[11] = x[ 3] - w0 * x[11]
	x[ 7] = x[ 7] + w0 * x[15]
	x[15] = x[ 7] - w0 * x[15]
depth 2:
	x[ 0] = x[ 0] + w0 * x[ 4]
	x[ 4] = x[ 0] - w0 * x[ 4]
	x[ 8] = x[ 8] + w4 * x[12]
	x[12] = x[ 8] - w4 * x[12]
	x[ 2] = x[ 2] + w0 * x[ 6]
	x[ 6] = x[ 2] - w0 * x[ 6]
	x[10] = x[10] + w4 * x[14]
	x[14] = x[10] - w4 * x[14]
	x[ 1] = x[ 1] + w0 * x[ 5]
	x[ 5] = x[ 1] - w0 * x[ 5]
	x[ 9] = x[ 9] + w4 * x[13]
	x[13] = x[ 9] - w4 * x[13]
	x[ 3] = x[ 3] + w0 * x[ 7]
	x[ 7] = x[ 3] - w0 * x[ 7]
	x[11] = x[11] + w4 * x[15]
	x[15] = x[11] - w4 * x[15]
depth 1:
	x[ 0] = x[ 0] + w0 * x[ 2]
	x[ 2] = x[ 0] - w0 * x[ 2]
	x[ 4] = x[ 4] + w2 * x[ 6]
	x[ 6] = x[ 4] - w2 * x[ 6]
	x[ 8] = x[ 8] + w4 * x[10]
	x[10] = x[ 8] - w4 * x[10]
	x[12] = x[12] + w6 * x[14]
	x[14] = x[12] - w6 * x[14]
	x[ 1] = x[ 1] + w0 * x[ 3]
	x[ 3] = x[ 1] - w0 * x[ 3]
	x[ 5] = x[ 5] + w2 * x[ 7]
	x[ 7] = x[ 5] - w2 * x[ 7]
	x[ 9] = x[ 9] + w4 * x[11]
	x[11] = x[ 9] - w4 * x[11]
	x[13] = x[13] + w6 * x[15]
	x[15] = x[13] - w6 * x[15]
depth 0:
	x[ 0] = x[ 0] + w0 * x[ 1]
	x[ 1] = x[ 0] - w0 * x[ 1]
	x[ 2] = x[ 2] + w1 * x[ 3]
	x[ 3] = x[ 2] - w1 * x[ 3]
	x[ 4] = x[ 4] + w2 * x[ 5]
	x[ 5] = x[ 4] - w2 * x[ 5]
	x[ 6] = x[ 6] + w3 * x[ 7]
	x[ 7] = x[ 6] - w3 * x[ 7]
	x[ 8] = x[ 8] + w4 * x[ 9]
	x[ 9] = x[ 8] - w4 * x[ 9]
	x[10] = x[10] + w5 * x[11]
	x[11] = x[10] - w5 * x[11]
	x[12] = x[12] + w6 * x[13]
	x[13] = x[12] - w6 * x[13]
	x[14] = x[14] + w7 * x[15]
	x[15] = x[14] - w7 * x[15]
*/

endmodule