//this comment tricks gedit into highlighting this file like c
Moog moog => ADSR e => dac;
e.set(10::ms, 8::ms, .5, 200::ms);
0.5 => moog.filterQ;
0.0 => moog.filterSweepRate;
0.0 => moog.lfoSpeed;
0.2 => moog.lfoDepth;
0.6 => moog.volume;

Moog moog2 => ADSR e2 => dac;
e2.set(10::ms, 8::ms, .5, 80::ms);
0.5 => moog2.filterQ;
0.0 => moog2.filterSweepRate;
0.0 => moog2.lfoSpeed;
0.2 => moog2.lfoDepth;
0.6 => moog2.volume;

//generate an accent sequence
bjorklund(8,3) @=> int rhythm[];
<<< "bjorklund:" + arrcat(rhythm) >>>;
bjorklund(7,5) @=> int rhythm2[];
<<< "bjorklund:" + arrcat(rhythm2) >>>;

0 => int k;

while(true) {

  //only play when the array element is high,
  //to produce the rhythm
  if (rhythm[k % rhythm.size()] == 1) {
    play2(48, .8, moog); //using this function is trivial in this case
                         //but necessary for adding melody later
    e.keyOn();
  }
  if (rhythm2[ k % rhythm2.size()] == 1) {
    play2(55, .6, moog2);
    e2.keyOn();
  }

  //advance time
  200::ms => now;
  e.keyOff(); //is it bad practice to hit keyOff if there wasn't always
  e2.keyOff();//a matching keyOn?
  k++;
}

fun void play( float note, float velocity, StifKarp inst) {
  // start the note
  Std.mtof( note ) => inst.freq;
  velocity => inst.pluck;
}

fun void play2(float note, float velocity, Moog m) {
  Std.mtof(55) => m.freq;
  velocity => m.noteOn;
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
