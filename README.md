# DIC-Frequency_Analysis_System
```
git clone --recursive https://github.com/CW-B-W/DIC-Frequency_Analysis_System.git --depth 1
```

## Precision problems
To avoid precision problem, bit-length of fraction part should be set to the highest value among operands
For example in FIR Filter
```
y[i] = x[i-k] * h[k]
```
y and x are both (sign_len, int_len, frac_len) = (1, 7, 8)  
but h is (1, 3, 16)  

Thus for example use a C++ for loop to calculate `y[i]`
```C++
for (int k = 0; k < K; ++k) {
  y[i] = y[i] + x[i-k] * h[k]
}
```
`y[i]` should be (1, 7, 16), or the intermediate value loses precisions  
and `x[i-k] * h[k]` should also be (1, 7, 16)
