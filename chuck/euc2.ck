class MySynth {
	Moog moog => ADSR e => dac;
	0.5 => moog.filterQ;
	0.0 => moog.filterSweepRate;
	0.0 => moog.lfoSpeed;
	0.2 => moog.lfoDepth;
	0.6 => moog.volume;

	int rhythm[];
	
	0 => int k;
	
	int note;
	float velocity;
	dur pulse;

	fun void startPlaying() {
		while (true) {
			if (rhythm[k % rhythm.size()] == 1) {
				play(); //using this function is trivial in this case
					 //but necessary for adding melody later
				e.keyOn();
			}

			//advance time
			pulse => now;
			e.keyOff();
			k++;
		}
	}

	fun void play() {
		Std.mtof(note) => moog.freq;
		velocity => moog.noteOn;
	}
}

MySynth mySynths[3];
48 => mySynths[0].note;
55 => mySynths[1].note;
53 => mySynths[2].note;
.8 => mySynths[0].velocity;
.6 => mySynths[1].velocity;
.4 => mySynths[2].velocity;
mySynths[0].e.set(10::ms, 8::ms, .5, 100::ms);
mySynths[1].e.set(10::ms, 8::ms, .5,  80::ms);
mySynths[2].e.set(10::ms, 8::ms, .5,  80::ms);

//generate an accent sequence
bjorklund(8,3) @=> mySynths[0].rhythm;
<<< "bjorklund:" + arrcat(mySynths[0].rhythm) >>>;
bjorklund(7,5) @=> mySynths[1].rhythm;
<<< "bjorklund:" + arrcat(mySynths[1].rhythm) >>>;
bjorklund(9,4) @=> mySynths[2].rhythm;
<<< "bjorklund:" + arrcat(mySynths[2].rhythm) >>>;

spork ~ mySynths[0].startPlaying();
spork ~ mySynths[1].startPlaying();
spork ~ mySynths[2].startPlaying();

while (true) {
	1::week => now;
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
