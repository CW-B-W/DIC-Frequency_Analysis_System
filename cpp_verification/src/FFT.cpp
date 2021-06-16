//ref: https://gist.github.com/lukicdarkoo/3f0d056e9244784f8b4a#file-fft-h-L1

#include <iostream>
#include <vector>
#include <complex>
#include "FixedPointNumber.hpp"

using namespace std;

class Complex
{
public:
    Complex(FixedPointNumber<7, 24> real, FixedPointNumber<7, 24> imag)
    {
        this->real = real;
        this->imag = imag;
    }

    Complex operator*(const Complex &rhs)
    {
        // (a+bi) * (c+dj) = (ac-bd) + i(ad+bc)
        FixedPointNumber<7, 24> a = this->real;
        FixedPointNumber<7, 24> b = this->imag;
        FixedPointNumber<7, 24> c = rhs.real;
        FixedPointNumber<7, 24> d = rhs.imag;
        FixedPointNumber<7, 24> r = a*c - b*d;
        FixedPointNumber<7, 24> i = a*d + b*c;
        return Complex(r, i);
    }

    Complex operator+(const Complex &rhs)
    {
        // (a+bi) + (c+dj) = (a+c) + i(b+d)
        FixedPointNumber<7, 24> a = this->real;
        FixedPointNumber<7, 24> b = this->imag;
        FixedPointNumber<7, 24> c = rhs.real;
        FixedPointNumber<7, 24> d = rhs.imag;
        FixedPointNumber<7, 24> r = a+c;
        FixedPointNumber<7, 24> i = b+d;
        return Complex(r, i);
    }

    Complex operator-(const Complex &rhs)
    {
        FixedPointNumber<7, 24> a = this->real;
        FixedPointNumber<7, 24> b = this->imag;
        FixedPointNumber<7, 24> c = rhs.real;
        FixedPointNumber<7, 24> d = rhs.imag;
        FixedPointNumber<7, 24> r = a-c;
        FixedPointNumber<7, 24> i = b-d;
        return Complex(r, i);
    }

    FixedPointNumber<7, 24> real;
    FixedPointNumber<7, 24> imag;
};

Complex fp_polar(double dr, double dtheta)
{
    complex<double> dp = polar(dr, dtheta);
    return Complex(dp.real(), dp.imag());
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

    Complex w = Complex(1.0, 0.0);
    for (int k = 0; k < M; ++k) {
        y[k]   = y_even[k] + w * y_odd[k];
        y[k+M] = y_even[k] - w * y_odd[k];
        w = w * fp_polar(1.0, -M_PI / M);
    }
    return y;
}

vector<Complex> FFT(vector<FixedPointNumber<7, 24>> x)
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
    
    vector<FixedPointNumber<7, 24>> x;
    path = dir + "/FIR_Y_FixedPoint.dat";
    fp = fopen(path.c_str(), "r");
    assert(fp);
    for (int t = 0; t < 1024; t += 16) {
        x.clear();
        for (int i = 0; i < 16; ++i) {
            uint32_t x_in;
            fscanf(fp, "%x", &x_in);
            FixedPointNumber<7, 8> x_in_fp = x_in;
            x.emplace_back(x_in_fp);
        }
        vector<Complex> y = FFT(x);
        for (int i = 0; i < 16; ++i) {
            cout << t + i << ' ' << y[i] << endl;
        }
    }
    fclose(fp);

    return 0;
}