#include <stdio.h>
#include <stdlib.h>
int * pattern;
int * pulses;
int * remainders;
int * counts;
int pattern_c, pulses_c, remainders_c, counts_c;
int size;
void bjorklund(int steps, int pulses);

int main() {
  int x = 20;
  int y = 3;
  pattern_c = pulses_c = remainders_c = counts_c = 0;
  size = x;
  pattern = malloc (sizeof(int) * x);
  pulses = malloc (sizeof(int) * x);
  remainders = malloc (sizeof(int) * x);
  counts = malloc (sizeof(int) * x);
  bjorklund(x,y);
  int i;
//  printf("size=%i\n", size);
  for (i = 0; i < size; i++) {
    printf("%i", pattern[i]);
  }
  printf("\n");
  
}

void bjorklund(int steps, int pulses) {
  int divisor = steps - pulses;
  printf("divisor=%i\n", divisor);
  printf("remainders[%i]=%i\n", remainders_c, pulses);
  remainders[remainders_c++] = pulses;
  int level = 0;
  while (1) {
    printf("counts[%i]=%i/remainders[%i](%i)=%i\n",counts_c, divisor,level,remainders[level], divisor/remainders[level]);
    counts[counts_c++] = divisor/remainders[level];
    printf("remainders[%i]=%i\n", remainders_c, divisor % remainders[level]);
    printf("divisor=%i level=%i remainders[level]=%i divisor_mod_remainders[level]=%i\n", divisor, level, remainders[level], divisor%remainders[level]);
    remainders[remainders_c++] = divisor % remainders[level];
    divisor = remainders[level];
    level++;
    if (remainders[level] <= 1) {
      break;
    }
  }
  counts[counts_c++] = divisor;
  build(level);
  int i = pattern[1];
  int tmp[size];
  //this is the dumb line
//  pattern = pattern[i] + pattern[0][i];
  int j;
  for (j = i; j < pattern_c; j++) {
    tmp[j-i] = pattern[j];
  } 
  for (j = 0; j <= i; j++) {
    tmp[j+i] = pattern[j+i];
  }
}

build(int level) {
  if (level == -1) {
    pattern[pattern_c] = 0;
  } else if (level == -2) {
    pattern[pattern_c] = 1;
  } else {
    int i;
    for (i = 0; i < counts[level]; i++) {
      build(level - 1);
    }
    if (remainders[level] != 0) {
      build(level - 2);
    }
  }
} 
/*
int euclid(int m, int k) {
  if (k==0) {
    return m;
    printf("%i", 0);
  } else {
    return euclid(k, m % k);

    printf("%i", 1);
  }
}*/
