// A sampler synth that uses an arbitrary subset of instrument samples to reproduce the instrument.
//
// TODO:
//  - automatic detection of loop points instead of separate attack and sustain files
//  - if sample doesn't start at zero, start from the first zero crossing?
//  - multiple velocities per note
//  - add humanization parameters like vibrato, filter variation, etc
//
// Feature that would be nice, but not necessary for Furies:
//  - support polyphony:
//    polyphony currently only works for notes that have distinct samples.
//    otherwise the buffer gets reset to play the new note at a different rate.
//    NearestNeighborMap is pretty specialized to avoid loading unnecessary
//    samples right now for the monophonic use case. it would be nice to retain
//    that optimization. see how complicated it will be to copy all the samples
//    for polyphony. Note, however, that when copying samples we have to make
//    some assumptions about which discrete notes are selected when we make the
//    copies.
//  - round robin with multiple samples
//  - non-integer source samples
//  - other file name formats, like hertz and note names
public class SamplerInstrument extends Chubgraph {
  // All loaded samples will be chucked to adsr.
  Envelope adsr => Gain g => outlet;

  0 => adsr.value;
  250::ms => dur attackTime;
  1000::ms => dur decayTime;
  0.7 => float sustain;
  false => int isMonophonic;

  fun static Builder builder() { return new Builder; }

  // Spork this to articulate a note using a midi note number. If the instrument
  // is in monophonic mode, each note sporked will release any playing note.
  fun void play(int midi) {
    <<< "You should be using one of the subclasses of SamplerInstrument,",
        "constructed using SamplerInstrument.builder()." >>>;
  }
}

class OneshotSamplerInstrument extends SamplerInstrument {
  NearestNeighborMap bufs;
  float tonic, pitch;
  SndBuf @ buf;

  fun void play(int midi) {
    if (isMonophonic && buf != null) {
      // there's a note currently playing, so end it
      0 => buf.rate;
      // TODO use envelope instead?
    }

    bufs.nearest(midi) => int nearest;
    bufs.get(nearest) @=> buf;
    Std.mtof(nearest) => tonic;
    Std.mtof(midi) => pitch;
    pitch/tonic => buf.rate;

    <<< "rate", buf.rate(), "midi", midi, "nearest" >>>;
    1.0 => adsr.target;
    0 => buf.pos;
    attackTime => adsr.duration;
    buf.length() => now;
    sustain => adsr.target;
    decayTime => adsr.duration;
  }
}

class SustainingSamplerInstrument extends SamplerInstrument {
  NearestNeighborMap attackBufs, sustainBufs;
  float attackTonic, attackPitch, sustainTonic, sustainPitch;
  SndBuf @ attackBuf;
  SndBuf @ sustainBuf;

  fun void play(int midi) {
    if (isMonophonic && attackBuf != null && attackBuf.pos() != 0) {
      // there's a note currently playing, so end it. if a note was not playing,
      // attackBuf would be at position 0 (I think).
      0 => sustainBuf.rate;
      // TODO use envelope instead?
    }
    if (attackBuf != null) { 0 => attackBuf.rate; }
    if (sustainBuf != null) { 0 => sustainBuf.rate; }

    attackBufs.nearest(midi) => int nearestAttack;
    attackBufs.get(nearestAttack) @=> attackBuf;
    Std.mtof(nearestAttack) => attackTonic;
    Std.mtof(midi) => attackPitch;
    attackPitch/attackTonic => attackBuf.rate;

    sustainBufs.nearest(midi) => int nearestSustain;
    sustainBufs.get(nearestAttack) @=> sustainBuf;
    Std.mtof(nearestSustain) => sustainTonic;
    Std.mtof(midi) => sustainPitch;

    <<< "rate", attackBuf.rate(), "midi", midi, "nearest", nearestAttack >>>;
    1.0 => adsr.target;
    0 => attackBuf.pos;
    attackTime => adsr.duration;

    0 => sustainBuf.pos;
    sustainPitch/sustainTonic => sustainBuf.rate;
    attackBuf.length() => now;

    sustain => adsr.target;
    decayTime => adsr.duration;
  }
}

// Note: If the Builder class definition isn't below the SamplerInstrument etc
// definitions, ChucK dies with "incompatible types for assignment".
class Builder {
  me.sourceDir() => string samplesDir;
  true => int isMonophonic;
  false => int isOneshot;
  "" => string oneshotSamplesRegex => string attackSamplesRegex => string sustainSamplesRegex;

  fun Builder polyphonic() { false => isMonophonic; return this; }
  fun Builder monophonic() { true => isMonophonic; return this; }
  fun Builder oneshotPattern(string re) { re => oneshotSamplesRegex; return this; }
  fun Builder attackPattern(string re) { re => attackSamplesRegex; return this; }
  fun Builder sustainPattern(string re) { re => sustainSamplesRegex; return this; }
  fun Builder dir(string d) { d => samplesDir; return this; }

  fun SamplerInstrument build() {
    if (attackSamplesRegex.length()==0 != sustainSamplesRegex.length()==0) {
      <<< "attackPattern and sustainPattern must both be supplied if either is supplied", "" >>>;
      me.exit();
    }
    if (oneshotSamplesRegex.length()==0) {
      if (attackSamplesRegex.length()==0) {
        <<< "must supply either oneshotPattern, or attackPattern+sustainPattern", "" >>>;
        me.exit();
      }
    } else {
      if (!attackSamplesRegex.length()==0) {
        <<< "you can't supply both oneshotPattern and attackPattern+sustainPattern", "" >>>;
        me.exit();
      }
      true => isOneshot;
    }
    SamplerInstrument @ i;
    if (isOneshot) {
      OneshotSamplerInstrument o;
      _loadFiles(oneshotSamplesRegex, o.bufs, o.adsr);
      for (0 => int j; j < o.bufs.srcbufs.size(); j++) {
        false => o.bufs.srcbufs[j].loop;
      }
      o @=> i;
    } else {
      SustainingSamplerInstrument s;
      _loadFiles(attackSamplesRegex, s.attackBufs, s.adsr);
      for (0 => int j; j < s.attackBufs.srcbufs.size(); j++) {
        false => s.attackBufs.srcbufs[j].loop;
      }
      _loadFiles(sustainSamplesRegex, s.sustainBufs, s.adsr);
      for (0 => int j; j < s.sustainBufs.srcbufs.size(); j++) {
        false => s.sustainBufs.srcbufs[j].loop;
      }
      if (s.attackBufs.size() != s.sustainBufs.size()) {
        <<< "there were", s.attackBufs.size(), "attack files but", s.sustainBufs.size(), "sustain files" >>>;
      }
      s @=> i;
    }
    isMonophonic => i.isMonophonic;
    return i;
  }

  fun void _loadFiles(string regex, NearestNeighborMap @ bufs, UGen @ bufConsumer) {
    FileIO cwd;
    if (!cwd.open(samplesDir)) {
      <<< "couldn't open directory", samplesDir >>>;
      me.exit();
    }
    cwd.dirList() @=> string files[];
    if (files.size() == 0) {
      <<< samplesDir, "contained no files" >>>;
    }
    for (0 => int i; i < files.size(); i++) {
      string matches[0];
      if (!RegEx.match(regex, files[i], matches)) {
        continue;
      }
      matches[1] => string noteStr;
      noteStr.toInt() => int note;
      if (note == 0) { continue; } // TODO why not die here?
      // <<< "match ", note, phase >>>;
      SndBuf buf;
      buf => bufConsumer;
      1 => buf.gain;
      0 => buf.rate; // pause them
      samplesDir + files[i] => buf.read;
      bufs.put(note, buf);
    }
    bufs.initialize();
    if (bufs.size() == 0) {
      <<< "pattern", regex, "matched no files" >>>;
      me.exit();
    }
  }

  // this is the old version that assumes separate attack and sustain bufs match with the same magic pattern
  fun void _loadFiles(NearestNeighborMap @ attackBufs,
                      NearestNeighborMap @ sustainBufs,
                      UGen @ bufConsumer) {
    "^([0-9]+)-(attack|sustain).wav$" => string samplesRegex;
    FileIO cwd;
    if (!cwd.open(samplesDir)) {
      <<< "couldn't open directory", samplesDir >>>;
      me.exit();
    }
    cwd.dirList() @=> string files[];
    for (0 => int i; i < files.size(); i++) {
      string matches[0];
      if (!RegEx.match(samplesRegex, files[i], matches)) {
        continue;
      }
      matches[1] => string noteStr;
      noteStr.toInt() => int note;
      matches[2] => string phase;
      if (note == 0) { continue; }
      // <<< "match ", note, phase >>>;
      if (phase != "attack" && phase != "sustain") {
        <<< "unexpected file type", phase >>>;
        me.exit();
      }
      SndBuf buf;
      // buf => adsr; TODO need to be able to set up thee connections on the instance
      buf => bufConsumer;
      1 => buf.gain;
      0 => buf.rate; // pause them
      samplesDir + files[i] => buf.read;
      if (phase == "attack") {
        false => buf.loop;
        attackBufs.put(note, buf);
      } else if (phase == "sustain") {
        true => buf.loop;
        sustainBufs.put(note, buf);
      }
    }
    attackBufs.initialize();
    // for (50 => int i; i < 70; i++) {
    //   // <<< "ayyyyy", attackBufs.nearest(i) >>>;
    // }
    sustainBufs.initialize();
    if (attackBufs.size() != sustainBufs.size()) {
      <<< "there were", attackBufs.size(), "attack files but", sustainBufs.size(), "sustain files" >>>;
    }
  }
}

// Wraps an associative array of int->SndBufs to provide access to the closest
// available map key in constant time.
//
// This class assumes that all keys will be strictly >0 and <1000.
class NearestNeighborMap {
  // an associative array of midi->SndBuf for all put() Sndbufs
  SndBuf @ srcbufs[0];

  // before initializ(), an array of all keys seen so far, in order seen; after
  // initialize(), an array of size max+1-min with all keys sorted, but with
  // gaps (zeroes) for any missing elements
  int keys[0];

  // after initialization, nearestNeighbor[i-min] contains the nearest available
  // neighbor of i, for min<=i<=max.
  int nearestNeighbor[];

  1000 => int min; // minimum key/midi note seen in put()
  0 => int max; // maximum key/midi note seen in put()
  false => int ready; // true if initialize() has been called

  // Returns the SndBuf for the given midi note. Pick an available note by using
  // nearest() to get the closest available note to the one you want.
  fun SndBuf get(int midi) {
    if (!ready) { _tooSoon(); }
    // <<< "get srcbufs", srcbufs.size(), "midi", midi, "str", Std.itoa(midi) >>>;
    // for (0 => int i; i < keys.size(); i++) {
    //   if (keys[i] == midi) {
    //     <<< "matching key for", keys[i], midi >>>;
    //     <<< srcbufs[Std.itoa(keys[i])] >>>;
    //     <<< srcbufs[Std.itoa(midi)] >>>;
    //   }
    //   <<< "lll buf", keys[i], srcbufs[Std.itoa(keys[i])] >>>;
    // }
    return srcbufs[Std.itoa(midi)];
    // if (midi < min) { return srcbufs[min-min]; }
    // if (midi > max) { return srcbufs[max-min]; }
    // return srcbufs[midi-min];
  }

  // Returns the midi note number of the nearest available note.
  fun int nearest(int midi) {
    if (!ready) { _tooSoon(); }
    if (midi < min) { return nearestNeighbor[min-min]; }
    if (midi > max) { return nearestNeighbor[max-min]; }
    return nearestNeighbor[midi-min];
  }

  // Adds the SndBuf for note `midi` to the underlying map.
  fun void put(int midi, SndBuf buf) {
    if (ready) {
      <<< "don't modify the map after initializing it" >>>;
      me.exit();
    }
    Std.itoa(midi) => string midistr;
    // <<< "putting", midi, buf, midistr >>>;
    buf @=> srcbufs[midistr];
    // <<< "after put, size is", srcbufs.size(), "and element is", srcbufs[midistr]>>>;
    // so it's present here but not in the get.
    keys << midi;
    Math.min(min, midi)$int => min;
    Math.max(max, midi)$int => max;
    // <<< "midi min max", midi, min, max, keys.size() >>>;
    // for (0 => int i; i < keys.size(); i++) {
    //   <<< "jkl buf", keys[i], srcbufs[Std.itoa(keys[i])] >>>;
    // }
  }

  // Returns the number of notes stored.
  fun int size() {
    if (!ready) { _tooSoon(); }
    return keys.size();
  }

  // After calling put() for all desired notes, call initialize() before calling
  // get(), size(), or nearest().
  fun void initialize() {
    if (ready) { return; }
    // for (0 => int i; i < keys.size(); i++) {
    //   <<< "asdf buf", keys[i], srcbufs[Std.itoa(keys[i])] >>>;
    // }
    if (min > max) {
      // this means no files were loaded, but maybe that's intentional?
      true => ready;
      return;
    }
    int sortedKeys[max+1-min];
    // SndBuf @ bufs[max+1-min];
    int neighbors[max+1-min];
    // basically radix sort, but leaves gaps (zeroes) for any values not present
    for (0 => int i; i < keys.size(); i++) {
      keys[i] => int key;
      key => sortedKeys[key-min];
    }
    // for (0 => int i; i < keys.size(); i++) {
    //   <<< "keys", keys[i] >>>;
    // }
    // for (0 => int i; i < sortedKeys.size(); i++) {
    //   <<< "sortedkeys", sortedKeys[i] >>>;
    // }
    -1 => int low;
    if (sortedKeys.size() == 1) {
      sortedKeys[0] => neighbors[0];
    } else {
      for (0 => int i; i < sortedKeys.size(); i++) {
        sortedKeys[i] => int key;
        if (!key) { continue; }
        if (low == -1) {
          key => low;
          continue;
        }
        key => int high;
        (high+low)/2 => int mid;
        // <<< "low mid high", low, mid, high >>>;
        for (low => int j; j <= mid; j++) {
          // srcbufs[low] => bufs[j];
          low => neighbors[j-min];
        }
        for (mid+1 => int j; j <= high; j++) {
          // srcbufs[high] => bufs[j];
          high => neighbors[j-min];
        }
        high => low;
      }
    }
    // bufs @=> srcbufs; // now srcbufs has every slot from min to max filled with the closest available SndBuf, as an indexed (not associative) array.
    neighbors @=> nearestNeighbor;
    true => ready;
    // <<< "nearestNeighbors", nearestNeighbor.size() >>>;
    // for (0 => int i; i < nearestNeighbor.size(); i++) {
    //   <<< "nearestNeighbor", i+min, nearestNeighbor[i] >>>;
    // }
  }

  fun void _tooSoon() {
    <<< "map not initialized", "" >>>;
    me.exit();
  }
}

// Everything below here is test code.

// SamplerInstrument.builder()
//                  // TODO I could support limited syntax here for picking which parts match what, like MIDI=>([0-9]+)
//                  .attackPattern("^([0-9]+)-attack.wav$")
//                  .sustainPattern("^([0-9]+)-sustain.wav$")
//                  .monophonic()
//                  .build() @=> SamplerInstrument inst;
SamplerInstrument.builder()
                 .oneshotPattern("^([1-9][1-9]).wav$")
                 .monophonic()
                 .build() @=> SamplerInstrument inst;
inst => dac;
// SinOsc sin => dac;
// 440 => sin.freq;
// inst => FFT fft =^ Centroid cent => blackhole;
// 1024 => fft.size;
// Windowing.hann(fft.size()/2) => fft.window;
second / samp => float srate;
inst => FFT fft =^ AutoCorr cor => blackhole;
// true => cor.normalize;
// SinOsc sin => FFT fft2 =^ cor;
// 100 => sin.freq;
1024 => fft.size;
Windowing.hamming( fft.size() ) => fft.window;
<<< srate, "samples/second" >>>;

// Plot Plot;
// float array[512];
// for(0 => int c; c < 512; c++) {
//     Math.cos(2*Math.PI*(c/511.)) => array[c];
// }
// "cosine" => Plot.title;
// Plot.plot(array);
// 1.1::second => now;


/*
spork ~go();
for (58 => int i; i < 82; i++) {
  spork ~ inst.play(i);
  // Std.mtof(i) => sin.freq;
  // now + 400::ms => time wait;
  // while (now < wait);
  // 1000::ms => now;
  1000::ms => now;
}
*/


// Machine.add("./samples/plot/Plot.ck");
// TODO why does this always report 0 for the first few notes before kicking in?
// true => Plot.export;
fun void go() {
  UAnaBlob fftblob;
  UAnaBlob blob;
  while (true) {
    // srate/fft.size() * divv++ => g.freq;
    fft.upchuck() @=> fftblob;
    cor.upchuck() @=> blob;
    // <<< "sizes", fftblob.fvals().size(), blob.fvals().size() >>>;
    0 => float max; int where;
    // for (int i; i < fftblob.fvals().size(); i++) {
    //   if (fftblob.fvals()[i] > max) {
    //     fftblob.fvals()[i] => max;
    //     i => where;
    //   }
    // }
    // "fft" => Plot.title;
    // Plot.plot(fftblob.fvals());
    // "autocorr" => Plot.title;
    // Plot.plot(blob.fvals());
    // Plot.record(inst, 200::ms);

    // set freq
    // ((where$float) / fft.size()) * srate => float hz;
    // <<< hz, "hz", Std.ftom(hz), "note" >>>;
    // fft.spectrum(s);
    // cent.fval(0) * srate / 2 => float hz;
    // <<< hz, Std.ftom(hz) >>>;
    // <<< fft.cval(0)$polar, fft.cval(1)$polar, fft.cval(2)$polar, fft.cval(3)$polar >>>;
    // <<< fft.transform().size() >>>;
    string s;

    // only check bins betwen 20hz and 16khz
    // .05s and .0000625s
    // srate/20 and srate/16000 samples
    // (srate/Std.mtof(90))$int => int maxI;
    0 => int maxI;
    0 => float sum;
    string larges;
    // for (maxI => int j; j < blob.fvals().size(); j++) {
    //   if (blob.fval(j) > blob.fval(maxI)) {
    //     j => maxI;
    //   }
    //   if (blob.fval(j) > blob.fval(0)/2) {
    //     larges + j + " " => larges;
    //   }
    //   s + blob.fval(j) + " " => s;
    //   sum+blob.fval(j) => sum;
    // }
    // <<< "max bin", maxI, "=", blob.fval(maxI), ". magnitude =", (srate/maxI)$int, "hz = note", Std.ftom(srate/maxI), ". sum=", sum >>>;
    // <<< s >>>;
    // <<< "top indices", larges >>>;
    // <<< fft.fval(0), fft.fval(1), fft.fval(2), fft.fval(3) >>>;
    // <<< s[0]$polar, s[1]$polar, s[2]$polar, s[3]$polar >>>;
    200::ms => now;
    // (fft.size()/2)::samp => now;
  }
}

