#include <iostream>
#include <iomanip>
#include <cstdint>
#include <cmath>
#include <stdexcept>
#include <cassert>

using namespace std;

#define  SIGN_BIT_LEN ( 1)
#define   INT_BIT_LEN ( 3)
#define  FRAC_BIT_LEN (16)
#define TOTAL_BIT_LEN ((SIGN_BIT_LEN)+(INT_BIT_LEN)+(FRAC_BIT_LEN))

#if TOTAL_BIT_LEN > 32
    #error "Error on defining bit lengths"
#endif

struct FixedPointNumber {
    union {
        uint32_t value;
        struct {
            uint32_t fraction : FRAC_BIT_LEN;
            uint32_t integer  : INT_BIT_LEN;
            uint32_t sign     : SIGN_BIT_LEN;
            uint32_t __empty  : (32-TOTAL_BIT_LEN);
        };
    };
};

ostream& operator<<(ostream &out, const FixedPointNumber &n) {
    out << "0x";
    uint32_t u32 = 0;
    u32 |= n.sign    << (INT_BIT_LEN + FRAC_BIT_LEN);
    u32 |= n.integer << (FRAC_BIT_LEN);
    u32 |= n.fraction;
    out << setw((TOTAL_BIT_LEN+3)/4) << setfill('0') << hex << u32;
    return out;
}

double convert_to_double(FixedPointNumber n)
{
    double d = 0;
    if (SIGN_BIT_LEN == 1) {
        if (n.sign) {
            d = (~n.value+1) & ((1<<TOTAL_BIT_LEN)-1);
            d = -d;
        }
        else {
            d = n.value;
        }
        d /= (1 << FRAC_BIT_LEN);
    }
    else {
        throw invalid_argument("SIGN_BIT_LEN must be 1");
    }

    return d;
}

FixedPointNumber convert_to_fixedpoint(double d)
{
    FixedPointNumber n;
    if (SIGN_BIT_LEN == 1) {
        double n_max =  (1 << INT_BIT_LEN);
        double n_min = -(1 << INT_BIT_LEN);
        if (d >= n_max || d <= n_min) {
            throw invalid_argument("d exceeds max limit");
        }

        bool sign = d < 0;
        if (sign)
            d = -d;
        d *= (1 << FRAC_BIT_LEN);
        n.value = d;
        if (sign)
            n.value = (~n.value+1) & ((1<<TOTAL_BIT_LEN)-1);

    }
    else {
        throw invalid_argument("SIGN_BIT_LEN must be 1");
    }
    return n;
}

int main() {
    uint32_t test_value[] = {
        0xFFF9E,
        0xFFF86,
        0xFFFA7,
        0x0003B,
        0x0014B,
        0x0024A,
        0x00222,
        0xFFFE4,
        0xFFBC5,
        0xFF7CA
    };
    for (int i = 0; i < sizeof(test_value) / sizeof(uint32_t); ++i) {
        FixedPointNumber fp;
        fp.value = test_value[i];
        double d = convert_to_double(fp);
        cout << d << endl;
        FixedPointNumber cfp = convert_to_fixedpoint(d);
        assert(fp.value == cfp.value);
        cout << cfp << endl;
    }
    return 0;
}