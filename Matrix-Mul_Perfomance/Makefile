CXX = g++
CC = gcc
CXXFLAGS = -ggdb -Wall -O2 
CFLAGS = -ggdb -Wall 
CXXSRCS = matmul-driver.cpp 
ASRCS1 = matmul.s intmul.s intadd.s 
MMOBJS = matmul-driver.o matmul.o intmul.o intadd.o 
ASRCS2 = matmul-mul.s
MMMULOBJS = matmul-driver.o matmul-mul.o
BIN1 = mm
BIN2 = mmmul

all: mm mmmul

mm:
	$(CXX) $(CXXFLAGS) -c $(CXXSRCS)
	$(CC) $(CFLAGS) -c $(ASRCS1)
	$(CC) $(CFLAGS) -o $(BIN1) $(MMOBJS)

mmmul:
	$(CXX) $(CXXFLAGS) -c $(CXXSRCS)
	$(CC) $(CFLAGS) -c $(ASRCS2)
	$(CC) $(CFLAGS) -o $(BIN2) $(MMMULOBJS)
clean:
	rm -f *.o $(BIN1) $(BIN2)
