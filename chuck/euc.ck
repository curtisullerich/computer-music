class MySynth {
  Moog moog => ADSR adsr => dac;
  0.5 => moog.filterQ;
  0.0 => moog.filterSweepRate;
  0.0 => moog.lfoSpeed;
  0.2 => moog.lfoDepth;
  0.6 => moog.volume;

  int rhythm[];
  int note;
  float velocity;
  dur pulse;

  adsr.keyOff(); //so it doesn't play at the beginning

  fun static MySynth instance(int _note, float _velocity, dur _pulse, int _rhythm[]) {
    MySynth m;
    _note => m.note;
    _velocity => m.velocity;
    _pulse => m.pulse;
    _rhythm @=> m.rhythm;
    return m;
  }

  fun void startPlaying() {
    0 => int k;
    while (true) {
      if (rhythm[k % rhythm.size()] == 1) {
        play(); //using this function is trivial in this case
           //but necessary for adding melody later
        adsr.keyOn();
      }

      //advance time
      pulse => now;
      adsr.keyOff();
      k++;
    }
  }

  fun void play() {
    Std.mtof(note) => moog.freq;
    velocity => moog.noteOn;
  }
}


fun static void main() {
  MySynth moog[3];

  MySynth.instance(41, .8, 200::ms, bjorklund(8,3)) @=> moog[0];
  MySynth.instance(45, .8, 200::ms, bjorklund(7,4)) @=> moog[1];
  MySynth.instance(48, .8, 200::ms, bjorklund(6,5)) @=> moog[2];

  moog[0].adsr.set(10::ms, 8::ms, .5, 100::ms);
  moog[1].adsr.set(10::ms, 8::ms, .5,  80::ms);
  moog[2].adsr.set(10::ms, 8::ms, .5,  80::ms);

  <<< "bjorklund:" + arrcat(moog[0].rhythm) >>>;
  <<< "bjorklund:" + arrcat(moog[1].rhythm) >>>;
  <<< "bjorklund:" + arrcat(moog[2].rhythm) >>>;

  spork ~ moog[0].startPlaying();
  spork ~ moog[1].startPlaying();
  spork ~ moog[2].startPlaying();

  while (true) {
    1::week => now;
  }
}

//generate an accent pattern
fun int[] bjorklund(int steps, int pulses) {
  //<<< "step:" + steps  + " pulses:" + pulses >>>;
  int pattern[0];
  int counts[0];
  int remainders[0];
  int divisor;
  steps - pulses => divisor;
  remainders << pulses;
  
  //<<< "remainders:" + arrcat(remainders) >>>;
  
  int level;
  0 => level;
  while (true) {
    //<<< "remainders[" + level + "]=" + remainders[level] >>>;
    counts << (divisor / remainders[level]);
    //<<< "counts:" + arrcat(counts) >>>;
    remainders << (divisor % remainders[level]);
    remainders[level] => divisor;
    level++;
    if (remainders[level] <= 1) {
      break;
    }
  }
  counts << divisor;
  
  build(level, pattern, counts, remainders);
  pattern[0] => int i;
  
  int newpat[0];
  for (i => int j; j < pattern.size(); j++) {
    newpat << pattern[j];
    //<<< "loop 1" >>>;
  } 
  
  for (0 => int j; j < i; j++) {
    newpat << pattern[j];
    //<<< "loop 2" >>>;
  }

  int reverse[0];
  for (newpat.size()-1 => int j; j > 0; j--) {
    reverse << newpat[j];
    //<<< "loop 3" >>>;
  }
  
  return newpat;
}

//to help with printing arrays
fun string arrcat(int arr[]) {
  
  "[ " => string ret;

  
  for (0 => int i; i < arr.size(); i++) {
    ret + arr[i] => ret;
    ret + ", " => ret;
  }
  
  ret + "]" => ret;

  return ret;
}

//helper function
fun void build(int level, int pattern[], int counts[], int remainders[]) {
  //<<< "build(level:" + level + ", pattern:" + arrcat(pattern) + ", counts:" + arrcat(counts) + ", remainders:" + arrcat(remainders) + ")" >>>;
  if (level == -1) {
    pattern << 0;
  } else if (level == -2) {
    pattern << 1;
  } else {
    for (0 => int i; i < counts[level]; i++) {
      build(level - 1, pattern, counts, remainders);
    }
    if (remainders[level] != 0) {
      build(level - 2, pattern, counts, remainders);
    }
  }
  return;
}

main();
