// MovementMusicSynth.pde
import processing.video.*;
import processing.sound.*;

// Camera
Capture cam;
PImage previousFrame;

// Synthesizers
SinOsc melody;    // Top zone - melody
TriOsc bass;      // Bottom zone - bass
SinOsc percussion; // Left zone - high percussion
SqrOsc drums;     // Right zone - rhythm

// Musical scale (Pentatonic scale in C)
float[] scale = {
  261.63, // C4
  293.66, // D4
  329.63, // E4
  392.00, // G4
  440.00, // A4
  523.25, // C5
};

// Motion detection
float topMotion = 0;     // Melody
float bottomMotion = 0;  // Bass
float leftMotion = 0;    // High percussion
float rightMotion = 0;   // Rhythm
float motionThreshold = 0.3;

// Sound parameters
float currentNote = 0;
float currentBass = 0;
float lastTriggerTime = 0;
float triggerInterval = 100; // Milliseconds between triggers

void setup() {
  size(640, 480);
  
  // Initialize camera
  String[] cameras = Capture.list();
  if (cameras.length > 0) {
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  
  // Initialize synthesizers
  melody = new SinOsc(this);
  bass = new TriOsc(this);
  percussion = new SinOsc(this);
  drums = new SqrOsc(this);
  
  // Start all oscillators with zero amplitude
  melody.play();
  bass.play();
  percussion.play();
  drums.play();
  
  melody.amp(0);
  bass.amp(0);
  percussion.amp(0);
  drums.amp(0);
}

void draw() {
  if (cam.available()) {
    cam.read();
    
    if (previousFrame != null) {
      updateMotionZones();
      updateSounds();
    }
    
    previousFrame = cam.copy();
  }
  
  // Display
  image(cam, 0, 0);
  drawZones();
  drawDebug();
}

void updateMotionZones() {
  cam.loadPixels();
  previousFrame.loadPixels();
  
  float totalTop = 0;
  float totalBottom = 0;
  float totalLeft = 0;
  float totalRight = 0;
  
  int halfWidth = cam.width / 2;
  int halfHeight = cam.height / 2;
  
  for (int y = 0; y < cam.height; y += 4) {
    for (int x = 0; x < cam.width; x += 4) {
      int loc = x + y * cam.width;
      color current = cam.pixels[loc];
      color previous = previousFrame.pixels[loc];
      float diff = abs(brightness(current) - brightness(previous)) / 255.0;
      
      // Divide screen into zones
      if (y < halfHeight) {
        totalTop += diff;
      } else {
        totalBottom += diff;
      }
      if (x < halfWidth) {
        totalLeft += diff;
      } else {
        totalRight += diff;
      }
    }
  }
  
  // Normalize motion values
  int pixelsPerZone = (cam.width * cam.height) / 32;
  topMotion = totalTop / pixelsPerZone;
  bottomMotion = totalBottom / pixelsPerZone;
  leftMotion = totalLeft / pixelsPerZone;
  rightMotion = totalRight / pixelsPerZone;
}

void updateSounds() {
  float currentTime = millis();
  
  // Melody (Top zone)
  if (topMotion > motionThreshold) {
    int noteIndex = int(map(mouseX, 0, width, 0, scale.length));
    noteIndex = constrain(noteIndex, 0, scale.length - 1);
    melody.freq(scale[noteIndex]);
    melody.amp(min(topMotion, 0.5));
  } else {
    melody.amp(0);
  }
  
  // Bass (Bottom zone)
  if (bottomMotion > motionThreshold * 0.5) {
    float bassNote = scale[0] / 2; // One octave down
    bass.freq(bassNote);
    bass.amp(min(bottomMotion * 0.8, 0.4));
  } else {
    bass.amp(0);
  }
  
  // High percussion (Left zone)
  if (leftMotion > motionThreshold && currentTime - lastTriggerTime > triggerInterval) {
    percussion.freq(scale[scale.length-1]); // Highest note
    percussion.amp(0.2);
    lastTriggerTime = currentTime;
  } else {
    percussion.amp(0);
  }
  
  // Rhythm (Right zone)
  if (rightMotion > motionThreshold) {
    drums.freq(scale[0] / 4); // Very low note for rhythm
    drums.amp(min(rightMotion * 0.6, 0.3));
  } else {
    drums.amp(0);
  }
}

void drawZones() {
  noFill();
  strokeWeight(2);
  
  // Melody zone (Top)
  stroke(255, 100, 100, topMotion > motionThreshold ? 200 : 127);
  rect(0, 0, width, height/2);
  
  // Bass zone (Bottom)
  stroke(100, 255, 100, bottomMotion > motionThreshold ? 200 : 127);
  rect(0, height/2, width, height/2);
  
  // Percussion zone (Left)
  stroke(100, 100, 255, leftMotion > motionThreshold ? 200 : 127);
  rect(0, 0, width/2, height);
  
  // Rhythm zone (Right)
  stroke(255, 255, 100, rightMotion > motionThreshold ? 200 : 127);
  rect(width/2, 0, width/2, height);
  
  // Labels
  fill(255);
  textSize(20);
  text("MELODY", width/2-40, 30);
  text("BASS", width/2-30, height-20);
  text("HIGH", 20, height/2);
  text("RHYTHM", width-80, height/2);
}

void drawDebug() {
  fill(0, 127);
  rect(0, 0, 180, 100);
  fill(255);
  textSize(16);
  text("Melody: " + nf(topMotion, 0, 2), 10, 20);
  text("Bass: " + nf(bottomMotion, 0, 2), 10, 40);
  text("High: " + nf(leftMotion, 0, 2), 10, 60);
  text("Rhythm: " + nf(rightMotion, 0, 2), 10, 80);
}

void keyPressed() {
  if (key == 't') {
    // Test all sounds
    testSounds();
  }
  // Adjust sensitivity
  if (key == 'u') motionThreshold += 0.05;
  if (key == 'd') motionThreshold -= 0.05;
  motionThreshold = constrain(motionThreshold, 0.1, 0.5);
}

void testSounds() {
  // Play a quick arpeggio
  for (int i = 0; i < scale.length; i++) {
    melody.freq(scale[i]);
    melody.amp(0.2);
    delay(200);
  }
  melody.amp(0);
}