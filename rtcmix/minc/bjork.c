#include <stdio.h>
#include <stdlib.h>

void bjork(int x, int y, int * remainders, int * count);
void build_string(int level, int * remainders, int * count);
/*
  An implementation of Bjorklund's algorithm, used to generate
  Euclidean rhythms by spacing a series of 1s in a bit string
  as evenly as possible.
*/
void main(int argc, char * argv[]) {
  if (argc != 3) {
    printf("Usage: ./bjork bits pulses\nBits is the length of the bit string and pulses is the number of accents. Both are ints.\n");
    return;
  }
  int x = atoi(argv[1]);
  int y = atoi(argv[2]);
  if (x < y) {
    int z = x;
    x = y;
    y = z;
  }
  int * remainders = malloc(sizeof(int)*x);
  int * count = malloc(sizeof(int)*x);   
  bjork(x,y, remainders, count);
}

void bjork(int x, int y, int * remainders, int * count) {
  int divisor = x - y;
  remainders[0] = y;
  int level = 0;

  do {
    count[level] = divisor/ remainders[level];
    remainders[level+1] = divisor % remainders[level];
    divisor = remainders[level];
    level++;
  
  } while (remainders[level] > 1);
 
  count[level] = divisor;
  build_string(level, remainders, count);
  printf("\n");
}

void build_string(int level, int * remainders, int * count) {
  if (level == -1) {
    printf("0"); 
  } else if (level == -2) {
    printf("1");
  } else {
    int i;
    for (i = 0; i < count[level]; i++) {
      build_string(level-1, remainders, count);
    } 
    if (remainders[level] != 0) {
      build_string (level-2, remainders, count);
    }
  }
}
