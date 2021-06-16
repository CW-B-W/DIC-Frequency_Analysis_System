#include <iostream>
#include <cstdio>
#include <cstdint>
#include <vector>
#include "../include/FixedPointNumber.hpp"

using namespace std;

vector<FixedPointNumber> convolution(const vector<FixedPointNumber> &x, const vector<FixedPointNumber> &h)
{
    vector<FixedPointNumber> y;
    for (int i = 0; i < 32; ++i) {
        FixedPointNumber yi = FixedPointNumber();
        for (int k = 0; k < 32; ++k) {
            yi = yi + h[k] * x[(32 + i - k) % 32];
        }
        y.emplace_back(yi);
    }
    return y;
}

int main()
{
    vector<FixedPointNumber> x;
    FILE* xfp = fopen("../data/Pattern1.dat", "r");
    assert(xfp);
    for (int i = 0; i < 32; ++i) {
        uint32_t val;
        fscanf(xfp, "%x", &val);
        x.emplace_back(val);
    }
    fclose(xfp);

    vector<FixedPointNumber> h;
    FILE* hfp = fopen("../data/FIR_coefficient.dat", "r");
    assert(hfp);
    for (int i = 0; i < 32; ++i) {
        double val;
        fscanf(hfp, "%lf", &val);
        h.emplace_back(val);
    }
    fclose(hfp);

    vector<FixedPointNumber> y = convolution(x, h);

    for (int i = 0; i < 32; ++i) {
        cout << x[i] << ' ' << x[i].to_double() << endl;
    }
    cout << endl;

    for (int i = 0; i < 32; ++i) {
        cout << h[i] << ' ' << h[i].to_double() << endl;
    }
    cout << endl;

    for (int i = 0; i < 32; ++i) {
        cout << y[i] << ' ' << y[i].to_double() << endl;
    }
    cout << endl;
    
    return 0;
}