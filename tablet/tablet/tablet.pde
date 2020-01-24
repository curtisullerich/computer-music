import beads.*;
import codeanticode.tablet.*;

class Instrument {
  AudioContext ac;
  Tablet tablet;
  WavePlayer modulator;
  Glide modulatorFrequency;
  WavePlayer carrier;
  Gain synthGain;
  Glide pressure;
  Reverb reverb;
  Envelope envelope;

  Instrument(PApplet parent, AudioContext ac, Tablet tablet) {
    this.ac = ac;
    this.tablet = tablet;
    this.modulatorFrequency = new Glide(this.ac, 20, 30);
    this.modulator = new WavePlayer(this.ac, this.modulatorFrequency, Buffer.SINE);
    Function frequencyModulation = new Function(this.modulator)
    {
      public float calculate() {
        return map(x[0], 0, 1, 10, 100+mouseY);
      }
    };
    this.pressure = new Glide(ac, 0, 50);
    this.envelope = new Envelope(ac, 0.);
    Function mult = new Function(envelope, pressure)
    {
      public float calculate() {
        return x[0]*x[1];
      }
    };
    this.carrier = new WavePlayer(this.ac, frequencyModulation, Buffer.SINE);
    this.synthGain = new Gain(this.ac, 1, mult);
    this.synthGain.addInput(carrier);
    this.reverb = new Reverb(ac, 1);
    this.reverb.addInput(synthGain);
    this.ac.out.addInput(reverb);
    this.ac.out.addInput(synthGain);
    this.ac.start();
  }
  void draw() {
    strokeWeight(30 * tablet.getPressure());
    float r = map(tablet.getAltitude(), 0, PI/2, 255, 0);
    stroke(r, r, r);
    line(pmouseX, pmouseY, mouseX, mouseY);
    this.modulatorFrequency.setValue(mouseX);
    this.pressure.setValue(tablet.getPressure());
    // tablet.getAzimuth(); // rotation around z, 0-2PI, though negative values also seem to appear
    // isCenterDown isLeftDown isRightDown for buttons

    //println(tablet.getSidePressure());
  }
  void mousePressed() {
    envelope.addSegment(0.95, 50);
    envelope.addSegment(0.7, 50);
  }
  void mouseReleased() {
    envelope.addSegment(0., 100);
  }
}

AudioContext ac;
Tablet tablet;
Instrument instrument;

void setup() {
  size(640, 480);
  ac = new AudioContext();
  tablet = new Tablet(this); 
  instrument = new Instrument(this, ac, tablet);
  ac.start();

  background(0);
  stroke(255);
}

void draw() {
  instrument.draw();
}

void mousePressed() {
  instrument.mousePressed();
}

void mouseReleased() {
  instrument.mouseReleased();
}
