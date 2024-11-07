#include <stdlib.h>
#include <omp.h>
#include "matmul.h"

void matmul(int*, const int*, const int*, unsigned int, unsigned int, unsigned int);

////////////////////////////////////////////////////////////////////////////////
//! C = A * B
//! @param C          result matrix
//! @param A          matrix A 
//! @param B          matrix B
//! @param hA         height of matrix A
//! @param wB         width of matrix B
////////////////////////////////////////////////////////////////////////////////

void matmul(int* C, const int* A, const int* B, unsigned int hA, 
    unsigned int wA, unsigned int wB)
{
   unsigned int i, j, k;
   int sum;

   // OpenMP pragma goes here
   omp_set_num_threads(THREADS_);
   #pragma omp parallel for private(i, j, k)
   for (i = 0; i < hA; ++i){
      for (j = 0; j < wB; ++j) {
         sum = 0;
         for (k = 0; k < wA; ++k) {
            sum += A[i * wA + k] * B[j * wB + k];
         }
         C[i * wB + j] = sum;
      }
   }
}

