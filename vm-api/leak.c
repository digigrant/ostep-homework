#include <stdlib.h>
#include <string.h>
#include <stdio.h>

int main() {
  int* data = (int*) malloc(100 * sizeof(int));
  memset(data, 0, 100);
  printf("Before free: %d\n", data[5]);
  int* funny = &(data[5]);
  free(funny);
  printf("After free: %d\n", data[5]);
  return 0;
}
