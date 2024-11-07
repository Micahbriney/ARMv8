CXX = g++
CC = gcc
CXXFLAGS_OPENMP = -ggdb -Wall -O2 -g -fopenmp -DNUM_THREADS=96
CXXFLAGS = -g -Wall
OMPSRCS = mm-omp-driver.cpp mm-omp.cpp
OMPOBJS = mm-omp-driver.o mm-omp.o
SIMDSRCS = mm-simd-driver.cpp 
ASSEMSRCS = mm-simd.s
SIMDOBJS = mm-simd-driver.o mm-simd.o
BIN1 = mm-omp
BIN2 = mm-simd

all: mm-omp mm-simd

mm-omp:
	$(CXX) $(CXXFLAGS_OPENMP) -c $(OMPSRCS)
	$(CXX) $(CXXFLAGS_OPENMP) -o $(BIN1) $(OMPOBJS)

mm-simd:
	$(CXX) $(CXXFLAGS) -c $(SIMDSRCS)
	$(CC) -g -c $(ASSEMSRCS)
	$(CXX) $(CXXFLAGS) -o $(BIN2) $(SIMDOBJS)

clean:
	rm -f *.o $(BIN1) $(BIN2)
