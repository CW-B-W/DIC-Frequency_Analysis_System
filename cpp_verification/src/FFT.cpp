//ref: https://gist.github.com/lukicdarkoo/3f0d056e9244784f8b4a#file-fft-h-L1

#include <iostream>
#include <vector>
#include <complex>
#include <cstdint>
#include <cassert>
#include "FixedPointNumber.hpp"

using namespace std;

using FP_7_8   = FixedPointNumber<7, 8>;
using FP_7_16  = FixedPointNumber<7, 16>;
using FP_7_24  = FixedPointNumber<7, 24>;
using FP_15_16 = FixedPointNumber<15, 16>;

class Complex
{
public:
    Complex(FP_7_24 real, FP_7_24 imag)
    {
        this->real = real;
        this->imag = imag;
    }

    Complex operator*(const Complex &rhs)
    {
        // (a+bi) * (c+dj) = (ac-bd) + i(ad+bc)
        FP_7_24 a = this->real;
        FP_7_24 b = this->imag;
        FP_7_24 c = rhs.real;
        FP_7_24 d = rhs.imag;
        FP_7_24 r = a*c - b*d;
        FP_7_24 i = a*d + b*c;
        return Complex(r, i);
    }

    Complex operator+(const Complex &rhs)
    {
        // (a+bi) + (c+dj) = (a+c) + i(b+d)
        FP_7_24 a = this->real;
        FP_7_24 b = this->imag;
        FP_7_24 c = rhs.real;
        FP_7_24 d = rhs.imag;
        FP_7_24 r = a+c;
        FP_7_24 i = b+d;
        return Complex(r, i);
    }

    Complex operator-(const Complex &rhs)
    {
        FP_7_24 a = this->real;
        FP_7_24 b = this->imag;
        FP_7_24 c = rhs.real;
        FP_7_24 d = rhs.imag;
        FP_7_24 r = a-c;
        FP_7_24 i = b-d;
        return Complex(r, i);
    }

    FP_7_24 real;
    FP_7_24 imag;
};

Complex fp_polar(double dr, double dtheta)
{
    complex<double> dp = polar(dr, dtheta);
    return Complex(dp.real(), dp.imag());
}

Complex get_w(int idx)
{
    assert(idx < 8);
    constexpr static uint32_t real[8] = {
        0x00010000,
        0x0000EC83,
        0x0000B504,
        0x000061F7,
        0x00000000,
        0xFFFF9E09,
        0xFFFF4AFC,
        0xFFFF137D
    };

    constexpr static uint32_t imag[8] = {
        0x00000000,
        0xFFFF9E09,
        0xFFFF4AFC,
        0xFFFF137D,
        0xFFFF0000,
        0xFFFF137D,
        0xFFFF4AFC,
        0xFFFF9E09
    };

    FP_15_16 r = real[idx];
    FP_15_16 i = imag[idx];
    return Complex(r, i);
}

ostream& operator<<(ostream &out, Complex c)
{
    out << c.real.to_double() << " + " << c.imag.to_double() << "i";
    return out;
}

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
    vector<Complex> y;
    for (int i = 0; i < N; ++i)
        y.emplace_back(0, 0);

    // Complex w = Complex(1.0, 0.0);
    for (int k = 0; k < M; ++k) {
        Complex w = get_w(8 * k / M);
        y[k]   = y_even[k] + w * y_odd[k];
        y[k+M] = y_even[k] - w * y_odd[k];
        // w = w * fp_polar(1.0, -M_PI / M);
    }
    return y;
}

vector<Complex> FFT(vector<FP_7_24> x)
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
    
    vector<FP_7_24> x;
    path = dir + "/FIR_Y_FixedPoint.dat";
    fp = fopen(path.c_str(), "r");
    assert(fp);
    vector<FP_7_8> y_real;
    vector<FP_7_8> y_imag;
    for (int t = 0; t < 1024; t += 16) {
        x.clear();
        for (int i = 0; i < 16; ++i) {
            uint32_t x_in;
            fscanf(fp, "%x", &x_in);
            FP_7_8 x_in_fp = x_in;
            x.emplace_back(x_in_fp);
        }
        vector<Complex> y = FFT(x);
        for (int i = 0; i < 16; ++i) {
            FP_7_8 fp_r = y[i].real;
            FP_7_8 fp_i = y[i].imag;
            y_real.emplace_back(fp_r);
            y_imag.emplace_back(fp_i);
            cout << t + i << ' ' << y[i] << endl;
            cout << t + i << ' ' << y[i].real << endl;
            cout << t + i << ' ' << y[i].imag << endl;
            cout << t + i << ' ' << Complex(fp_r, fp_i) << endl;
            cout << t + i << ' ' << fp_r << endl;
            cout << t + i << ' ' << fp_i << endl;
            cout << endl;
        }
    }
    fclose(fp);


    int errcnt = 0;
    path = dir + "/FFT_real_FixedPoint.dat";
    fp = fopen(path.c_str(), "r");
    assert(fp);
    for (int i = 0; i < 1024; ++i) {
        uint32_t in;
        fscanf(fp, "%x", &in);
        FP_7_8 y_real_in_fp = in;
        if (abs((int)y_real_in_fp.get_value() - (int)y_real[i].get_value()) > 1) {
            errcnt += 1;
            cout << i << "-th real :" << endl;
            cout << "\t" << "Result = " << y_real[i] << endl;
            cout << "\t" << "Expect = " << y_real_in_fp << endl;
        }
    }
    fclose(fp);

    path = dir + "/FFT_imag_FixedPoint.dat";
    fp = fopen(path.c_str(), "r");
    assert(fp);
    for (int i = 0; i < 1024; ++i) {
        uint32_t in;
        fscanf(fp, "%x", &in);
        FP_7_8 y_imag_in_fp = in;
        if (abs((int16_t)y_imag_in_fp.get_value() - (int16_t)y_imag[i].get_value()) > 1) {
            errcnt += 1;
            cout << i << "-th imag :" << endl;
            cout << "\t" << "Result = " << y_imag[i] << endl;
            cout << "\t" << "Expect = " << y_imag_in_fp << endl;
        }
    }
    fclose(fp);

    if (errcnt) {
        cout << "There are " << errcnt << " errors" << endl;
    }
    else {
        cout << "All correct" << endl;
    }
    return 0;
}
