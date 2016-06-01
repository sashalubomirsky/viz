// Turn on Billie

import ddf.minim.analysis.*;
import ddf.minim.*;
import controlP5.*;

Minim minim;
FFT fft;

// line in vs. file
// AudioInput  in;
AudioPlayer in;

// FFT parameters
int bufferSize = 512;
int fftBaseFrequency = 86;
int fftBandsPerOctave = 1;

// song-dependent variables
String filePath       = "/Users/raph/Music/iTunes/iTunes Music/Pierces, The/Thirteen tales of love and revenge/06 Turn on Billie.mp3";
int startPosition     = 0; // milliseconds
float expBase         = 1.75; // exponent base for "amplifying" band values // 1.75 works well for logAverages
int constraintCeiling = 100;
WindowFunction window = FFT.HAMMING;


// signal
float signalScale = 3;

// visualization-dependent variables
color   background = #DCD6B2;
color[] palette = new color[] { #4E7989, #A9011B, #80944E }; // colorlisa - picasso - the dream

int numLines = 15;
int minLines = 1;
int maxLines = 30;
int[] lineColorIndex;

int lineSpacing = 20;
float segmentLength = 40;

float minLineThickness = 1;
float maxLineThickness = 10;

float lineWidth; // determined by stage width


ControlFrame cf;

void settings() {
  // size(640, 640);
  fullScreen();
}

void setup() {
  surface.setSize(640, 640);

  // cf = new ControlFrame(this, 400, 800, "Controls");

  minim = new Minim(this);

  // if using line in
  // in = minim.getLineIn(Minim.STEREO, 512);

  // if using file
  in = minim.loadFile(filePath, bufferSize);
  in.play(startPosition);
    
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(fftBaseFrequency, fftBandsPerOctave);

  if(window != null) {
    fft.window(window);
  }
  
  lineColorIndex = new int[maxLines];

  for (int i = 0; i < maxLines; i++) {
    lineColorIndex[i] = (int)random(palette.length);
  }

  lineWidth = width * 1.5;
}

void draw() {
  background(background);

  float[] signals = getAdjustedFftSignals();

  noFill();

  int segments = (int)(lineWidth / segmentLength);

  // translate(0, (height / 2) - (lineSpacing * numLines / 2));

  translate(width / 2, height / 2);
  rotate((float)frameCount / 300);

  for (int l = 0; l < numLines; l++) {

    float lineY = l * lineSpacing - (numLines * lineSpacing ) / 2;
    stroke(palette[lineColorIndex[l]]);

    // strokeWeight(4);
    // float yoff = sin((float)frameCount / 20) * segmentLength / 2;
    // float yoff = sin(frameCount / 10.0 + l * 0.1) * segmentLength / 2;
    // float yoff = sin(frameCount / 10.0) * segmentLength / 2; yoff *= (1 + 0.2 * l);

    float yoff = map(signals[5], 0, 100, 0, segmentLength * 1.5);
    strokeWeight(map(signals[0], 0, 100, minLineThickness, maxLineThickness));

    beginShape();
    for (int i = 0; i <= segments; i++) {
      if (i % 2 == 0) {
        vertex(i * segmentLength - (lineWidth / 2), lineY + yoff);
      }
      else {
        vertex(i * segmentLength - (lineWidth / 2), lineY - yoff); 
      }
    }
    endShape();
  }
}

// Boost FFT signals in each band, constrain them to a ceiling.
// Return adjusted results in array.
float[] getAdjustedFftSignals() {
  float[] signals = new float[fft.avgSize()];

  fft.forward(in.mix);
  for(int i = 0; i < fft.avgSize(); i++) {
    // adjust and constrain signal value
    float adjustedAvg    = fft.getAvg(i) * pow(expBase, i) * signalScale;
    float constrainedAvg = constrain(adjustedAvg, 0, constraintCeiling);

    signals[i] = constrainedAvg;
  }

  println(signals);

  return signals;
}




class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);
    
    cp5.addNumberbox("numLines")
       .plugTo(parent, "numLines")
       .setRange(minLines, maxLines)
       .setValue(15)
       .setPosition(100, 10)
       .setSize(100, 20);
  }

  void draw() {
    background(190);
  }
}