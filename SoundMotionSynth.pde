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

// Loop recording system
ArrayList<SoundFrame> loopFrames;
boolean isRecording;
boolean isPlaying;
int recordingStartTime;
int loopDuration;
int playbackPosition;

// Current frequencies
float currentMelodyFreq;
float currentBassFreq;
float currentPercFreq;
float currentDrumsFreq;

// Current amplitudes
float currentMelodyAmp = 0;
float currentBassAmp = 0;
float currentPercAmp = 0;
float currentDrumsAmp = 0;

// Class to store sound state for each frame
class SoundFrame {
  float melodyFreq, melodyAmp;
  float bassFreq, bassAmp;
  float percFreq, percAmp;
  float drumsFreq, drumsAmp;
  int timestamp;
  
  SoundFrame(float mf, float ma, float bf, float ba, 
             float pf, float pa, float df, float da, int ts) {
    melodyFreq = mf; melodyAmp = ma;
    bassFreq = bf; bassAmp = ba;
    percFreq = pf; percAmp = pa;
    drumsFreq = df; drumsAmp = da;
    timestamp = ts;
  }
}

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
  
  loopFrames = new ArrayList<SoundFrame>();
  isRecording = false;
  isPlaying = false;
  recordingStartTime = 0;
  loopDuration = 4000; // 4 second loop by default
  playbackPosition = 0;
  
  currentMelodyFreq = scale[0];
  currentBassFreq = scale[0] / 2;
  currentPercFreq = scale[scale.length-1];
  currentDrumsFreq = scale[0] / 4;
  
  // Initialize current amplitudes
  currentMelodyAmp = 0;
  currentBassAmp = 0;
  currentPercAmp = 0;
  currentDrumsAmp = 0;
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
  int currentTime = millis();
  
  // Record current sound state if recording
  if (isRecording) {
    int timestamp = currentTime - recordingStartTime;
    SoundFrame frame = new SoundFrame(
      currentMelodyFreq, currentMelodyAmp,
      currentBassFreq, currentBassAmp,
      currentPercFreq, currentPercAmp,
      currentDrumsFreq, currentDrumsAmp,
      timestamp
    );
    loopFrames.add(frame);
  }
  
  // Play back recorded loop if playing
  if (isPlaying && loopFrames.size() > 0) {
    playbackPosition = (currentTime - recordingStartTime) % loopDuration;
    
    // Find and apply the closest recorded frame
    SoundFrame closestFrame = null;
    int minDiff = Integer.MAX_VALUE;
    
    for (SoundFrame frame : loopFrames) {
      int diff = Math.abs(frame.timestamp - playbackPosition);
      if (diff < minDiff) {
        minDiff = diff;
        closestFrame = frame;
      }
    }
    
    if (closestFrame != null) {
      // Mix recorded sound with live sound
      melody.freq(closestFrame.melodyFreq);
      bass.freq(closestFrame.bassFreq);
      percussion.freq(closestFrame.percFreq);
      drums.freq(closestFrame.drumsFreq);
      
      melody.amp(closestFrame.melodyAmp * 0.7);
      bass.amp(closestFrame.bassAmp * 0.7);
      percussion.amp(closestFrame.percAmp * 0.7);
      drums.amp(closestFrame.drumsAmp * 0.7);
    }
  }
  
  // Live sound processing
  float currentTimeForTrigger = millis();
  
  if (topMotion > motionThreshold) {
    int noteIndex = int(map(mouseX, 0, width, 0, scale.length));
    noteIndex = constrain(noteIndex, 0, scale.length - 1);
    currentMelodyFreq = scale[noteIndex];
    currentMelodyAmp = min(topMotion, 0.5);
    melody.freq(currentMelodyFreq);
    melody.amp(currentMelodyAmp);
  } else if (!isPlaying) {
    currentMelodyAmp = 0;
    melody.amp(0);
  }
  
  // Bass (Bottom zone)
  if (bottomMotion > motionThreshold * 0.5) {
    currentBassFreq = scale[0] / 2;
    currentBassAmp = min(bottomMotion * 0.8, 0.4);
    bass.freq(currentBassFreq);
    bass.amp(currentBassAmp);
  } else if (!isPlaying) {
    currentBassAmp = 0;
    bass.amp(0);
  }
  
  // High percussion (Left zone)
  if (leftMotion > motionThreshold && currentTimeForTrigger - lastTriggerTime > triggerInterval) {
    currentPercFreq = scale[scale.length-1];
    currentPercAmp = 0.2;
    percussion.freq(currentPercFreq);
    percussion.amp(currentPercAmp);
    lastTriggerTime = currentTimeForTrigger;
  } else if (!isPlaying) {
    currentPercAmp = 0;
    percussion.amp(0);
  }
  
  // Rhythm (Right zone)
  if (rightMotion > motionThreshold) {
    currentDrumsFreq = scale[0] / 4;
    currentDrumsAmp = min(rightMotion * 0.6, 0.3);
    drums.freq(currentDrumsFreq);
    drums.amp(currentDrumsAmp);
  } else if (!isPlaying) {
    currentDrumsAmp = 0;
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
  rect(0, 0, 180, 140); // Made taller for loop info
  fill(255);
  textSize(16);
  text("Melody: " + nf(topMotion, 0, 2), 10, 20);
  text("Bass: " + nf(bottomMotion, 0, 2), 10, 40);
  text("High: " + nf(leftMotion, 0, 2), 10, 60);
  text("Rhythm: " + nf(rightMotion, 0, 2), 10, 80);
  
  // Add loop status
  fill(isRecording ? color(255, 0, 0) : 255);
  text("Loop: " + (isRecording ? "REC" : (isPlaying ? "PLAYING" : "STOPPED")), 10, 100);
  text("Duration: " + nf(loopDuration/1000.0, 0, 1) + "s", 10, 120);
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
  
  switch(key) {
    case 'r':
      if (!isRecording && !isPlaying) {
        // Start recording
        isRecording = true;
        loopFrames.clear();
        recordingStartTime = millis();
      } else if (isRecording) {
        // Stop recording and start playback
        isRecording = false;
        isPlaying = true;
        loopDuration = millis() - recordingStartTime;
        recordingStartTime = millis(); // Reset for playback
      }
      break;
      
    case 'p':
      // Toggle loop playback
      if (!isRecording) {
        isPlaying = !isPlaying;
        if (isPlaying) {
          recordingStartTime = millis();
        }
      }
      break;
      
    case 'c':
      // Clear loop
      isRecording = false;
      isPlaying = false;
      loopFrames.clear();
      break;
      
    case '[':
      // Decrease loop duration
      loopDuration = max(1000, loopDuration - 1000);
      break;
      
    case ']':
      // Increase loop duration
      loopDuration = min(8000, loopDuration + 1000);
      break;
  }
}

void testSounds() {
  // Play a quick arpeggio
  for (int i = 0; i < scale.length; i++) {
    currentMelodyFreq = scale[i];
    currentMelodyAmp = 0.2;
    melody.freq(currentMelodyFreq);
    melody.amp(currentMelodyAmp);
    delay(200);
  }
  currentMelodyAmp = 0;
  melody.amp(0);
}