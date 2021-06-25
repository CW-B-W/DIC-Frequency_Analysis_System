module FFT(clk, rst, fir_valid, fir_d,
           fft_valid,
           fft_d0, fft_d1, fft_d2 , fft_d3 , fft_d4 , fft_d5 , fft_d6 , fft_d7,
           fft_d8, fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15);

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

reg        [31:0] x_in       [15:0];
wire       [31:0] x_out_real [15:0];
wire       [31:0] x_out_imag [15:0];

integer i;

always@(posedge clk, posedge rst) begin
    if (rst) begin
        rd_idx    <= 0;
        fft_valid <= 0;
    end
    else begin
        if (fir_valid) begin
            if (rd_idx == 15) begin
                fft_valid <= 1;
                fft_d0  <= {x_out_real[ 0][23:8], x_out_imag[ 0][23:8]};
                fft_d1  <= {x_out_real[ 1][23:8], x_out_imag[ 1][23:8]};
                fft_d2  <= {x_out_real[ 2][23:8], x_out_imag[ 2][23:8]};
                fft_d3  <= {x_out_real[ 3][23:8], x_out_imag[ 3][23:8]};
                fft_d4  <= {x_out_real[ 4][23:8], x_out_imag[ 4][23:8]};
                fft_d5  <= {x_out_real[ 5][23:8], x_out_imag[ 5][23:8]};
                fft_d6  <= {x_out_real[ 6][23:8], x_out_imag[ 6][23:8]};
                fft_d7  <= {x_out_real[ 7][23:8], x_out_imag[ 7][23:8]};
                fft_d8  <= {x_out_real[ 8][23:8], x_out_imag[ 8][23:8]};
                fft_d9  <= {x_out_real[ 9][23:8], x_out_imag[ 9][23:8]};
                fft_d10 <= {x_out_real[10][23:8], x_out_imag[10][23:8]};
                fft_d11 <= {x_out_real[11][23:8], x_out_imag[11][23:8]};
                fft_d12 <= {x_out_real[12][23:8], x_out_imag[12][23:8]};
                fft_d13 <= {x_out_real[13][23:8], x_out_imag[13][23:8]};
                fft_d14 <= {x_out_real[14][23:8], x_out_imag[14][23:8]};
                fft_d15 <= {x_out_real[15][23:8], x_out_imag[15][23:8]};
            end
            
            for (i = 0; i  <= 14; i = i + 1) begin
                x_in[i] <= x_in[i+1];
            end
            x_in[15]    <= {{8{fir_d[15]}}, fir_d, 8'b0};
            
            if (rd_idx == 15) begin
                rd_idx <= 0;
            end
            else begin
                rd_idx <= rd_idx + 1;
            end
        end
    end
end

FFT_Submodule #(.N(16)) fft_sub(
    {x_in[0], x_in[8], x_in[4], x_in[12], x_in[2], x_in[10], x_in[6], x_in[14], x_in[1], x_in[9], x_in[5], x_in[13], x_in[3], x_in[11], x_in[7], x_in[15]},
    {32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0},
    {x_out_real[0], x_out_real[1], x_out_real[2], x_out_real[3], x_out_real[4], x_out_real[5], x_out_real[6], x_out_real[7], x_out_real[8], x_out_real[9], x_out_real[10], x_out_real[11], x_out_real[12], x_out_real[13], x_out_real[14], x_out_real[15]},
    {x_out_imag[0], x_out_imag[1], x_out_imag[2], x_out_imag[3], x_out_imag[4], x_out_imag[5], x_out_imag[6], x_out_imag[7], x_out_imag[8], x_out_imag[9], x_out_imag[10], x_out_imag[11], x_out_imag[12], x_out_imag[13], x_out_imag[14], x_out_imag[15]}
);

endmodule



//----------------------------------------------------------------
module FFT_Submodule #(parameter N = 16) (in_real, in_imag, out_real, out_imag);
//----------------------------------------------------------------
`define BUS(i)   (BITS*(i)+BITS-1):(BITS*(i)) // the bus of i-th variable

localparam MAX_N = 16;
localparam M     = N / 2;
localparam BITS  = 32;

input       [N*BITS-1:0] in_real;
input       [N*BITS-1:0] in_imag;
output wire [N*BITS-1:0] out_real;
output wire [N*BITS-1:0] out_imag;
wire        [N*BITS-1:0] outsub_real;
wire        [N*BITS-1:0] outsub_imag;
wire              [31:0] W_outsub_real [M-1:0];
wire              [31:0] W_outsub_imag [M-1:0];

wire [31:0] W_REAL [7:0];
wire [31:0] W_IMAG [7:0];
assign W_REAL[0] = 32'h00010000;
assign W_REAL[1] = 32'h0000EC83;
assign W_REAL[2] = 32'h0000B504;
assign W_REAL[3] = 32'h000061F7;
assign W_REAL[4] = 32'h00000000;
assign W_REAL[5] = 32'hFFFF9E09;
assign W_REAL[6] = 32'hFFFF4AFC;
assign W_REAL[7] = 32'hFFFF137D;
assign W_IMAG[0] = 32'h00000000;
assign W_IMAG[1] = 32'hFFFF9E09;
assign W_IMAG[2] = 32'hFFFF4AFC;
assign W_IMAG[3] = 32'hFFFF137D;
assign W_IMAG[4] = 32'hFFFF0000;
assign W_IMAG[5] = 32'hFFFF137D;
assign W_IMAG[6] = 32'hFFFF4AFC;
assign W_IMAG[7] = 32'hFFFF9E09;

generate
    if (N > 1) begin
        FFT_Submodule #(.N(N/2)) fft_sub1(in_real[N*BITS/2-1:0],      in_imag[N*BITS/2-1:0],      outsub_real[N*BITS/2-1:0],      outsub_imag[N*BITS/2-1:0]);
        FFT_Submodule #(.N(N/2)) fft_sub2(in_real[N*BITS-1:N*BITS/2], in_imag[N*BITS-1:N*BITS/2], outsub_real[N*BITS-1:N*BITS/2], outsub_imag[N*BITS-1:N*BITS/2]);
    end
endgenerate

genvar i;
generate 
    for (i = 0; i < M; i = i + 1) begin: FFT_SUB
        localparam w_idx = MAX_N*i/N;
        complex_mul cm(
            W_REAL[w_idx], W_IMAG[w_idx], 
            outsub_real[`BUS(i+M)], outsub_imag[`BUS(i+M)], 
            W_outsub_real[i], W_outsub_imag[i]);

        // W_outsub is (outsub[i+M] * W[MAX_N*i/N])

        complex_add ca1(
            outsub_real[`BUS(i)], outsub_imag[`BUS(i)], 
            W_outsub_real[i], W_outsub_imag[i], 
            out_real[`BUS(i)], out_imag[`BUS(i)]);
        complex_add ca2(
            outsub_real[`BUS(i)], outsub_imag[`BUS(i)], 
            ~W_outsub_real[i]+1, ~W_outsub_imag[i]+1, 
            out_real[`BUS(i+M)], out_imag[`BUS(i+M)]);
        // out[i]   = outsub[i] + outsub[i+M] * W[MAX_N*i/N];
        // out[i+M] = outsub[i] - outsub[i+M] * W[MAX_N*i/N];
    end
endgenerate

`undef BUS
endmodule

//----------------------------------------------------------------
module fp_mul(_vc, _vx, vy);
//----------------------------------------------------------------
    input      [31:0] _vc; /* 1 bit, 15 bits, 16 bits */
    input      [31:0] _vx; /* 1 bit, 15 bits, 16 bits */
    reg        [31:0] vc;  /* 1 bit, 15 bits, 16 bits */
    reg        [31:0] vx;  /* 1 bit, 15 bits, 16 bits */
    output reg [31:0] vy;  /* 1 bit, 15 bits, 16 bits */
    reg        [47:0] vt;  /* intermediate value      */

    wire s = vc[31] ^ vx[31];

    always@(*)begin
        if (_vc[31])
            vc = ~_vc + 1;
        else
            vc = _vc;
        if (_vx[31])
            vx = ~_vx + 1;
        else
            vx = _vx;

        vt = vc * vx;
        if (s == 0)
            vy = vt[47:16] + vt[15];
        else
            vy = ~(vt[47:16] + vt[15]) + 1;
    end
endmodule

//----------------------------------------------------------------
module complex_mul(a, b, c, d, e, f);
//----------------------------------------------------------------
    // a + bi
    input  [31:0] a;
    input  [31:0] b;
    // c + di
    input  [31:0] c;
    input  [31:0] d;
    // e + fi
    output [31:0] e; // ac - bd
    output [31:0] f; // ad + bc
    wire   [31:0] ac;
    wire   [31:0] bd;
    wire   [31:0] ad;
    wire   [31:0] bc;
    
    fp_mul ac_mul(a, c, ac);
    fp_mul bd_mul(b, d, bd);
    assign e = ac - bd;

    fp_mul ad_mul(a, d, ad);
    fp_mul bc_mul(b, c, bc);
    assign f = ad + bc;
endmodule

//----------------------------------------------------------------
module complex_add(a, b, c, d, e, f);
//----------------------------------------------------------------
    // a + bi
    input  [31:0] a;
    input  [31:0] b;
    // c + di
    input  [31:0] c;
    input  [31:0] d;
    // e + fi
    output [31:0] e = a + c;
    output [31:0] f = b + d;
endmodule