import beads.*;
import codeanticode.tablet.*;

AudioContext ac;
Tablet tablet;
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;
Gain synthGain;
Glide pressure;
Reverb reverb;
Envelope envelope;

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
  pressure = new Glide(ac, 0, 50);
  envelope = new Envelope(ac, 0.);
  Function mult = new Function(envelope, pressure)
  {
    public float calculate() {
      return x[0]*x[1];
    }
  };
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SINE);
  synthGain = new Gain(ac, 1, mult);
  synthGain.addInput(carrier);
  reverb = new Reverb(ac, 1);
  reverb.addInput(synthGain);
  ac.out.addInput(reverb);
  ac.out.addInput(synthGain);
  tablet = new Tablet(this); 
  ac.start();

  background(0);
  stroke(255);
}

void draw() {
  strokeWeight(30 * tablet.getPressure());
  float r = map(tablet.getAltitude(), 0, PI/2, 255, 0);
  stroke(r, r, r);
  line(pmouseX, pmouseY, mouseX, mouseY);
  modulatorFrequency.setValue(mouseX);
  pressure.setValue(tablet.getPressure());
}

void mousePressed() {
  envelope.addSegment(0.95, 50);
  envelope.addSegment(0.7, 50);
}

void mouseReleased() {
  envelope.addSegment(0., 100);
}
