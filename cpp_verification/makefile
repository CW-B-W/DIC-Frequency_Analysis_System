.PHONY: help
help:
	@printf 'usage: make <option>\n'
	@printf '\n'
	@printf 'options:\n'
	@printf '\tfir\t\tRun FIR\n'
	@printf '\tfft\t\tRun FFT\n'
	@printf '\tfft_std\t\tRun C++ std::complex version of FFT\n'

CC           = g++
CXXFLAGS     = -Wall -O3 --std=c++17
FIR_DEPS     = src/FIR.cpp include/FixedPointNumber.hpp
FIR_SRCS     = src/FIR.cpp
FFT_DEPS     = src/FFT.cpp include/FixedPointNumber.hpp
FFT_SRCS     = src/FFT.cpp
FFT_STD_DEPS = src/FFT_std_complex.cpp include/FixedPointNumber.hpp
FFT_STD_SRCS = src/FFT_std_complex.cpp
INCLUDES     = -I./include 

.PHONY: fir
fir: bin/FIR.out
	bin/FIR.out data/

bin/FIR.out: $(FIR_DEPS)
	$(CC) -o $@ $(FIR_SRCS) $(INCLUDES) $(CXXFLAGS)


.PHONY: fft
fft: bin/FFT.out
	bin/FFT.out data/

bin/FFT.out: $(FFT_DEPS)
	$(CC) -o $@ $(FFT_SRCS) $(INCLUDES) $(CXXFLAGS)


.PHONY: fft_std
fft_std: bin/FFT_STD.out
	bin/FFT_STD.out data/

bin/FFT_STD.out: $(FFT_STD_DEPS)
	$(CC) -o $@ $(FFT_STD_SRCS) $(INCLUDES) $(CXXFLAGS)


.PHONY: clean
clean:
	rm -f bin/*.out
