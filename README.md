# DIC-Frequency_Analysis_System
[Problem description pdf](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/docs/2021_hw5.pdf)  

System block overview
![image](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/docs/SystemBlockOverview.png)

## Verilog Design
### Modules
* [FAS.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/FAS.v) is the top module
* [FIR.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/FIR.v) is the FIR module, which apply low-pass filter on the input signals
  * Transposed FIR
* [FFT.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/FFT.v) is the FFT module, which do Fourier Transform on the output of FIR.v
  * Multicycle
* [Analysis.v](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/Analysis.v) is the Analysis module, which output the frequency with greatest amplitude
  * Multicycle

### Features
* Use `generate if/for` to recursively generate FFT sub-blocks
* Use `Transposed FIR` to reduce critical path length
  * Naive `FIR` can be found at [d3ae221](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/d3ae2210c94795e800908cf27696681770e40f13/FIR.v)
* Use `Multicycle design` to reduce clock-width
  * `Singlecycle design` can be found at [Singlecycle](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/tree/Singlecycle)

## [C++ verification](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/tree/master/cpp_verification)
Use [CW-B-W/FixedPointNumberLibrary](https://github.com/CW-B-W/FixedPointNumberLibrary) to verify my thoughts in C++ using Fixed-Point Number  
### Files
* [FIR.cpp](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/cpp_verification/src/FIR.cpp) is to verify the implementation method of FIR
* [FFT_std_complex.cpp](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/cpp_verification/src/FFT_std_complex.cpp) is the implementation of FFT using `std::complex`, this is to verify the general implementation of FFT algorithm.
* [FFT.cpp](https://github.com/CW-B-W/DIC-Frequency_Analysis_System/blob/master/cpp_verification/src/FFT.cpp) is to verify FFT implementation method using Fixed-Point Number
### Makefile
Use the following to compile & run the abovementioned files
```
make fir
make fft_std
make fft
```
