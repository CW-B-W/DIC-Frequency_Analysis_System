# DIC-Frequency_Analysis_System
[Problem description pdf](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/docs/2021_hw5.pdf)  

System block overview
![image](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/docs/SystemBlockOverview.png)

## Verilog Design
### Modules
* [FAS.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/FAS.v) is the top module
* [FIR.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/FIR.v) is the FIR module, which apply low-pass filter on the input signals
* [FFT.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/FFT.v) is the FFT module, which do Fourier Transform on the output of FIR.v
* [Analysis.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/Analysis.v) is the Analysis module, which output the frequency with greatest amplitude

### Features
* Use generate if/for to recursively generate FFT sub-blocks

## [C++ verification](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/tree/master/cpp_verification)
Use [CW-B-W/FixedPointNumberLibrary](https://github.com/CW-B-W/FixedPointNumberLibrary) to verify my thoughts using C++  
### Files
* [FIR.cpp](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/cpp_verification/src/FIR.cpp) is to verify the implementation of FIR
* [FFT_std_complex.cpp](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/cpp_verification/src/FFT_std_complex.cpp) is the implementation of FFT using `std::complex`, this is to verify the general implementation of FFT algorithm.
* [FFT.cpp](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/cpp_verification/src/FFT.cpp) is to verify FFT implementation using Fixed-Point Number
### Makefile
Use the following to compile & run the abovementioned files
```
make fir
make fft_std
make fft
```
