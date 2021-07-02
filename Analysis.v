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


// mul_select: prepare for multiplying
reg [ 3:0] mul_sel_idx;
reg [31:0] mul_sel_val;
reg        mul_sel_valid;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        mul_sel_idx   <= 0;
        mul_sel_val   <= 0;
        mul_sel_valid <= 0;
    end
    else begin
        if (fft_valid || mul_sel_idx != 0) begin
            case (mul_sel_idx)
                4'h0: mul_sel_val <= fft_d0;
                4'h1: mul_sel_val <= fft_d1;
                4'h2: mul_sel_val <= fft_d2;
                4'h3: mul_sel_val <= fft_d3;
                4'h4: mul_sel_val <= fft_d4;
                4'h5: mul_sel_val <= fft_d5;
                4'h6: mul_sel_val <= fft_d6;
                4'h7: mul_sel_val <= fft_d7;
                4'h8: mul_sel_val <= fft_d8;
                4'h9: mul_sel_val <= fft_d9;
                4'hA: mul_sel_val <= fft_d10;
                4'hB: mul_sel_val <= fft_d11;
                4'hC: mul_sel_val <= fft_d12;
                4'hD: mul_sel_val <= fft_d13;
                4'hE: mul_sel_val <= fft_d14;
                4'hF: mul_sel_val <= fft_d15;
            endcase

            if (mul_sel_idx == 15) begin
                mul_sel_idx   <= 0;
                mul_sel_valid <= 0;
            end
            else begin
                mul_sel_idx   <= mul_sel_idx + 1;
                mul_sel_valid <= 1;
            end
        end
    end
end

// compute amplitude
reg [31:0] mul_res;
reg        mul_valid;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        mul_res   <= 0;
        mul_valid <= 0;
    end
    else begin
        if (mul_sel_valid) begin
            mul_res <= ($signed(mul_sel_val[31:16]) * $signed(mul_sel_val[31:16])) + ($signed(mul_sel_val[15:0]) * $signed(mul_sel_val[15:0]));
            mul_valid <= 1;
        end
        else begin
            mul_valid <= 0;
        end
    end
end

// compare max
reg [31:0] max_val;
reg [ 3:0] max_idx;
reg [ 3:0] cnt_idx;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        max_val <= 0;
        max_idx <= 0;
        cnt_idx <= 0;
    end
    else begin
        if (mul_valid) begin
            if (mul_res > max_val) begin
                max_val <= mul_res;
                max_idx <= cnt_idx;
            end
            cnt_idx <= cnt_idx + 1;
        end
        else begin
            cnt_idx <= 0;
        end
    end
end

reg    done_cnt;
assign done = (done_cnt < 31) ? (cnt_idx == 15) : 0;
assign freq = max_idx;

always@(posedge clk, posedge rst) begin
    if (rst)
        done_cnt <= 0;
    else
        if (done)
            done_cnt <= done_cnt + 1;
end

endmodule
