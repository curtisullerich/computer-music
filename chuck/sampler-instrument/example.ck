// SamplerInstrument.builder()
//                  // TODO I could support limited syntax here for picking which parts match what, like MIDI=>([0-9]+)
//                  .attackPattern("^([0-9]+)-attack.wav$")
//                  .sustainPattern("^([0-9]+)-sustain.wav$")
//                  .monophonic()
//                  .build() @=> SamplerInstrument inst;

SamplerInstrument.builder()
                 .dir(me.sourceDir() + "samples/trumpet/")
                 .oneshotPattern("^([1-9][1-9]).wav$")
                 .monophonic()
                 .build() @=> SamplerInstrument inst;
inst => dac;

for (58 => int i; i < 82; i++) {
  spork ~ inst.play(i);
  300::ms => now;
}
