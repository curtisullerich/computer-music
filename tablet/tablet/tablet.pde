import beads.*;
import codeanticode.tablet.*;

AudioContext ac;
Tablet tablet;
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;
Gain synthGain;
Glide amplitude;

void setup() {
  size(640, 480);
  ac = new AudioContext();
  modulatorFrequency = new Glide(ac, 20, 30);
  modulator = new WavePlayer(ac, modulatorFrequency, Buffer.SINE);
  Function frequencyModulation = new Function(modulator)
  {
    public float calculate() {
      return map(x[0], 0, 1, 10, 100+mouseY);
    }
  };
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE);
  amplitude = new Glide(ac, 0, 50);
  synthGain = new Gain(ac, 1, amplitude);
  synthGain.addInput(carrier);
  ac.out.addInput(synthGain);
  ac.start();
  tablet = new Tablet(this); 

  background(0);
  stroke(255);
}

void draw() {
  strokeWeight(30 * tablet.getPressure());
  line(pmouseX, pmouseY, mouseX, mouseY);
  modulatorFrequency.setValue(mouseX);
}

void mousePressed() {
  amplitude.setValue(.9);
}

void mouseReleased() {
  amplitude.setValue(0);
}
