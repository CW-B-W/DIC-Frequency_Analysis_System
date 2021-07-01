module FIR(clk, rst, data_valid, data, fir_valid, fir_d);

input              clk, rst;
input              data_valid;
input       [15:0] data;
output reg         fir_valid;
output reg  [15:0] fir_d;

reg         [10:0] sig_idx;
reg  signed [23:0] fir_reg  [31:0];

wire signed [19:0] FIR_C [31:0];

wire signed [31:0] data_ext = {{16{data[15]}}, data};

integer i;

assign FIR_C[00] = 20'hFFF9E;
assign FIR_C[01] = 20'hFFF86;
assign FIR_C[02] = 20'hFFFA7;
assign FIR_C[03] = 20'h0003B;
assign FIR_C[04] = 20'h0014B;
assign FIR_C[05] = 20'h0024A;
assign FIR_C[06] = 20'h00222;
assign FIR_C[07] = 20'hFFFE4;
assign FIR_C[08] = 20'hFFBC5;
assign FIR_C[09] = 20'hFF7CA;
assign FIR_C[10] = 20'hFF74E;
assign FIR_C[11] = 20'hFFD74;
assign FIR_C[12] = 20'h00B1A;
assign FIR_C[13] = 20'h01DAC;
assign FIR_C[14] = 20'h02F9E;
assign FIR_C[15] = 20'h03AA9;
assign FIR_C[16] = 20'h03AA9;
assign FIR_C[17] = 20'h02F9E;
assign FIR_C[18] = 20'h01DAC;
assign FIR_C[19] = 20'h00B1A;
assign FIR_C[20] = 20'hFFD74;
assign FIR_C[21] = 20'hFF74E;
assign FIR_C[22] = 20'hFF7CA;
assign FIR_C[23] = 20'hFFBC5;
assign FIR_C[24] = 20'hFFFE4;
assign FIR_C[25] = 20'h00222;
assign FIR_C[26] = 20'h0024A;
assign FIR_C[27] = 20'h0014B;
assign FIR_C[28] = 20'h0003B;
assign FIR_C[29] = 20'hFFFA7;
assign FIR_C[30] = 20'hFFF86;
assign FIR_C[31] = 20'hFFF9E;

always@(posedge clk, posedge rst) begin
    if (rst) begin
        fir_valid <= 0;
        fir_d     <= 0;
        sig_idx   <= 0;
        for (i = 0; i < 32; i = i + 1) begin
            fir_reg[i] <= 0;
        end
    end
    else begin
        if (sig_idx >= 32) begin
            fir_valid <= 1;
            fir_d     <= {fir_reg[31][23:8] + fir_reg[31][23]}; // !!! WHY??? if without `+ fir_reg[23]`, precision error happens
        end
        else if (sig_idx >= 1024+32) begin
            fir_valid <= 0;
            fir_d     <= 0;
        end

        if (sig_idx < 1024)
            fir_reg[0] <= ((data_ext * FIR_C[31]) >>> 8);
        else
            fir_reg[0] <= 0;
        for (i = 1; i <= 31; i = i + 1) begin
            fir_reg[i] <= fir_reg[i-1] + ((data_ext * FIR_C[31-i]) >>> 8);
        end

        sig_idx <= sig_idx + 1;
    end
end

endmodule