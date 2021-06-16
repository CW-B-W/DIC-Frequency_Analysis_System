//ref: https://gist.github.com/lukicdarkoo/3f0d056e9244784f8b4a#file-fft-h-L1

#include <iostream>
#include <vector>
#include <complex>

using namespace std;

using Complex = complex<double>;

inline constexpr unsigned ceil_to_power2(unsigned x)
{
    if ((x & (x-1)) == 0)
        return x;
    while (x & (x-1)) {
        x &= x-1;
    }
    return x << 1;
}

vector<Complex> FFT_recursive(const vector<Complex> &x)
{
    if (x.size() == 1)
        return x;

    int N = x.size();
    int M = x.size() / 2;
    vector<Complex> x_even;
    vector<Complex> x_odd;
    for (int i = 0; i < M; ++i) {
            x_even.emplace_back(x[i*2]);
            x_odd.emplace_back(x[i*2+1]);
    }

    vector<Complex> y_even = FFT_recursive(x_even);
    vector<Complex> y_odd  = FFT_recursive(x_odd);
    vector<Complex> y(N);

    Complex w = Complex(1, 0);
    for (int k = 0; k < M; ++k) {
        y[k]   = y_even[k] + w * y_odd[k];
        y[k+M] = y_even[k] - w * y_odd[k];
        w = w * polar(1.0, -M_PI / M);
    }
    return y;
}

vector<Complex> FFT(vector<double> x)
{
    vector<Complex> cx;
    int i;
    for (i = 0; i < x.size(); ++i) {
        cx.emplace_back(x[i], 0);
    }
    /* zero-padding */
    int l = ceil_to_power2(x.size());
    for (; i < l; ++i) {
        cx.emplace_back(0, 0);
    }
    return FFT_recursive(cx);
}

int main(int argc, char** argv)
{
    string dir = argv[1];
    string path;
    FILE* fp = NULL;
    
    vector<double> x;
    path = dir + "/FIR_Y_double.dat";
    fp = fopen(path.c_str(), "r");
    assert(fp);
    for (int t = 0; t < 1024; t += 16) {
        x.clear();
        for (int i = 0; i < 16; ++i) {
            double x_in;
            fscanf(fp, "%lf", &x_in);
            x.emplace_back(x_in);
        }
        vector<Complex> y = FFT(x);
        for (int i = 0; i < 16; ++i) {
            cout << t + i << ' ' << y[i] << endl;
        }
    }
    fclose(fp);

    return 0;
}