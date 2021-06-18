module FIR(clk, rst, data_valid, data, fir_valid, fir_d);

`include "./dat/FIR_coefficient.dat"

input              clk, rst;
input              data_valid;
input       [15:0] data;
output reg         fir_valid;
output reg  [15:0] fir_d;

reg         [ 9:0] sig_idx;
reg         [15:0] sig      [31:0]; /* should always be positive */
wire        [27:0] v        [31:0];
wire        [27:0] y;

integer i;

task fp_mul;
    input      [19:0] vc; /* 1 bit, 3 bits, 16 bits    */
    input      [15:0] vx; /* 1 bit, 7 bits,  8 bits    */
    output reg [19:0] vy; /* 1 bit, 3 bits, 16 bits    */
    reg        [27:0] vt; /* intermediate value        */

    reg s = vc[19] ^ vx[15];

    begin
        if (vc[19])
            vc = ~vc + 1;
        if (vx[15])
            vx = ~vx + 1;

        vt = vc * vx;
        if (s == 0)
            vy = vt[27:8] + vt[7];
        else
            vy = ~(vt[27:8] + vt[7]) + 1;
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
    end
    else begin
        if (sig_idx >= 32) begin
            fir_valid <= 1;
            fir_d     <= y[23:8];
        end

        for (i = 0; i <= 30; i = i + 1) begin
            sig[i] <= sig[i+1];
        end
        sig[31]    <= data;

        sig_idx <= sig_idx + 1;
    end
end

// https://ideone.com/TK8V0C
assign y = (((((v[0]) + (v[1])) + ((v[2]) + (v[3]))) + (((v[4]) + (v[5])) + ((v[6]) + (v[7])))) + ((((v[8]) + (v[9])) + ((v[10]) + (v[11]))) + (((v[12]) + (v[13])) + ((v[14]) + (v[15]))))) + (((((v[16]) + (v[17])) + ((v[18]) + (v[19]))) + (((v[20]) + (v[21])) + ((v[22]) + (v[23])))) + ((((v[24]) + (v[25])) + ((v[26]) + (v[27]))) + (((v[28]) + (v[29])) + ((v[30]) + (v[31])))));

always@(*) fp_mul(FIR_C00, sig[0], v[0]);
always@(*) fp_mul(FIR_C01, sig[1], v[1]);
always@(*) fp_mul(FIR_C02, sig[2], v[2]);
always@(*) fp_mul(FIR_C03, sig[3], v[3]);
always@(*) fp_mul(FIR_C04, sig[4], v[4]);
always@(*) fp_mul(FIR_C05, sig[5], v[5]);
always@(*) fp_mul(FIR_C06, sig[6], v[6]);
always@(*) fp_mul(FIR_C07, sig[7], v[7]);
always@(*) fp_mul(FIR_C08, sig[8], v[8]);
always@(*) fp_mul(FIR_C09, sig[9], v[9]);
always@(*) fp_mul(FIR_C10, sig[10], v[10]);
always@(*) fp_mul(FIR_C11, sig[11], v[11]);
always@(*) fp_mul(FIR_C12, sig[12], v[12]);
always@(*) fp_mul(FIR_C13, sig[13], v[13]);
always@(*) fp_mul(FIR_C14, sig[14], v[14]);
always@(*) fp_mul(FIR_C15, sig[15], v[15]);
always@(*) fp_mul(FIR_C16, sig[16], v[16]);
always@(*) fp_mul(FIR_C17, sig[17], v[17]);
always@(*) fp_mul(FIR_C18, sig[18], v[18]);
always@(*) fp_mul(FIR_C19, sig[19], v[19]);
always@(*) fp_mul(FIR_C20, sig[20], v[20]);
always@(*) fp_mul(FIR_C21, sig[21], v[21]);
always@(*) fp_mul(FIR_C22, sig[22], v[22]);
always@(*) fp_mul(FIR_C23, sig[23], v[23]);
always@(*) fp_mul(FIR_C24, sig[24], v[24]);
always@(*) fp_mul(FIR_C25, sig[25], v[25]);
always@(*) fp_mul(FIR_C26, sig[26], v[26]);
always@(*) fp_mul(FIR_C27, sig[27], v[27]);
always@(*) fp_mul(FIR_C28, sig[28], v[28]);
always@(*) fp_mul(FIR_C29, sig[29], v[29]);
always@(*) fp_mul(FIR_C30, sig[30], v[30]);
always@(*) fp_mul(FIR_C31, sig[31], v[31]);

endmodule