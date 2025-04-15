import processing.video.*;
import oscP5.*;
import netP5.*;

// Video sources
Capture cam;
Movie videoFile;
PImage currentFrame;
boolean useCamera = true;

// OSC communication
OscP5 oscP5;
NetAddress remoteLocation;

// Effect parameters
int currentEffect = 0;
float rotationSpeed = 0.5;
float zoom = 0;
float brightness = 1.0;
float saturation = 1.0;
float rgbShiftAmount = 0.0;

// Control parameters
float rotationX = 0;
float rotationY = 0;
PVector moveOffset = new PVector(0, 0, 0);

void setup() {
  size(800, 600, P3D);
  colorMode(HSB, 360, 100, 100);
  frameRate(30);
  
  // Initialize camera
  String[] cameras = Capture.list();
  if (cameras.length > 0) {
    cam = new Capture(this, 640, 480, cameras[0]);
    cam.start();
  }
  
  // Initialize OSC communication
  oscP5 = new OscP5(this, 12000);
  remoteLocation = new NetAddress("127.0.0.1", 12001);
}

void draw() {
  background(0);
  
  // Update current frame from either camera or video
  if (useCamera) {
    if (cam != null && cam.available()) {
      cam.read();
      currentFrame = cam;
    }
  } else {
    if (videoFile != null && videoFile.available()) {
      videoFile.read();
      currentFrame = videoFile;
    }
  }
  
  // Process the current frame if available
  if (currentFrame != null) {
    pushMatrix();
    translate(width/2 + moveOffset.x, height/2 + moveOffset.y, zoom + moveOffset.z);
    rotateX(rotationX);
    rotateY(rotationY);
    
    // Apply effects based on current parameters
    switch(currentEffect) {
      case 0: drawSimpleEffect(); break;
      case 1: drawMirrorEffect(); break;
      case 2: drawKaleidoscopeEffect(); break;
    }
    
    popMatrix();
  }
  
  // Draw info
  fill(360, 0, 100);
  textAlign(LEFT);
  textSize(12);
  text("Effect: " + currentEffect, 10, 20);
  text("Rotation: " + nf(rotationSpeed, 1, 2), 10, 40);
  text("Brightness: " + nf(brightness, 1, 2), 10, 60);
}

void drawSimpleEffect() {
  imageMode(CENTER);
  tint(360, saturation * 100, brightness * 100);
  image(currentFrame, 0, 0);
}

void drawMirrorEffect() {
  pushMatrix();
  scale(-1, 1);
  tint(360, saturation * 100, brightness * 100);
  image(currentFrame, 0, 0);
  popMatrix();
}

void drawKaleidoscopeEffect() {
  float angle = TWO_PI / 6;
  for (int i = 0; i < 6; i++) {
    pushMatrix();
    rotate(angle * i);
    tint(360, saturation * 100, brightness * 100);
    image(currentFrame, 0, 0, width/3, height/3);
    popMatrix();
  }
}

// OSC message handling
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/effect")) {
    currentEffect = msg.get(0).intValue();
  }
  else if (msg.checkAddrPattern("/rotation")) {
    rotationSpeed = msg.get(0).floatValue();
  }
  else if (msg.checkAddrPattern("/zoom")) {
    zoom = msg.get(0).floatValue();
  }
  else if (msg.checkAddrPattern("/brightness")) {
    brightness = msg.get(0).floatValue();
  }
  else if (msg.checkAddrPattern("/saturation")) {
    saturation = msg.get(0).floatValue();
  }
  else if (msg.checkAddrPattern("/rgbshift")) {
    rgbShiftAmount = msg.get(0).floatValue();
  }
} 