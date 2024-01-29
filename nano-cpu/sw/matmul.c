#include <stdint.h>

void matmul(int32_t *a, int32_t *b, int32_t *c, int K, int M, int N) {
  for (int i = 0; i < K; i++)
    for (int j = 0; j < N; j++) {
      c[i * N + j] = 0;
      for (int k = 0; k < M; k++)
        c[i * N + j] += a[i * M + k] * b[k * N + j];
    }
}

int main() {
  int32_t a[2][4] = {
    {3,  4, 1, 2},
    {-1, 1, 3, 1},
  };
  int32_t b[4][3] = {
    {-2, 5, 3},
    {1,  2, 4},
    {3,  1, 2},
    {4,  3, 1},
  };
  int32_t c[2][3] = {
    {0, 0, 0},
    {0, 0, 0},
  };

  matmul((int32_t *)a, (int32_t *)b, (int32_t *)c, /*K=*/2, /*M=*/4, /*N=*/3);

  return c[1][2];
}

// CHECK: a0 = 0x8
