.PHONY: help
help:
	@printf 'usage: make <option>\n'
	@printf '\n'
	@printf 'options:\n'
	@printf '\tfir\t\tRun FIR\n'

CC           = g++
CXXFLAGS     = -Wall -O3 --std=c++17
SUBMOD_PATH  = ./FixedPointNumberLibrary
FIR_DEPS     = src/FIR.cpp $(SUBMOD_PATH)/include/FixedPointNumber.hpp
FIR_SRCS     = src/FIR.cpp
INCLUDES     = -I./include -I$(SUBMOD_PATH)/include

.PHONY: fir
fir: bin/FIR.out
	bin/FIR.out data/

bin/FIR.out: $(FIR_DEPS)
	$(CC) -o $@ $(FIR_SRCS) $(INCLUDES) $(CXXFLAGS)

.PHONY: clean
clean:
	rm -f bin/*.out
