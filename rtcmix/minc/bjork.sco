rtsetparams(44100, 2)
load("WAVETABLE")

main() {
  //waveform = maketable("wave", 1000, "saw")
  waveform = maketable("wave", 1000, 1.0, 0.4, 0.2, 0.1, 0.05, 0.025)
  srand(0)
  start = 0
  pitch = 55
  env = maketable("line", 1000, 0,0, 1,1, 2,1, 3,0)
  for (i = 0; i < 20; i+=1) {
    WAVETABLE(start, 1, 10000*env, pitch*env, 0.5, waveform)
    WAVETABLE(start, 1, 10000*env, (pitch/4)*env, 0.5, waveform)
    start+=.2
    pitch+=(ran()*80-40)
    //pitch*=1.1
  }
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

