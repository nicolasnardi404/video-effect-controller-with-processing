// Global variables for video input and processing
import processing.video.*;
Capture cam;
Movie video;
boolean useVideo = false;
PImage currentFrame;

// Effect control variables
int currentEffect = 0;
boolean showBackground = true;
boolean ghostEffect = false;
boolean mouseControl = true;
boolean isRecording = false;
int colorMode = 0;

// Effect parameters
float rotationSpeed = 0.0;
float colorSpeed = 0.5;
float zoom = 1.0;
float effectSpeed = 1.0;
float sizeMultiplier = 1.0;
float brightness = 1.0;
float saturation = 1.0;
float colorIntensity = 1.0;
float distortAmount = 0.0;
float rgbShiftAmount = 0.0;
float noiseAmount = 0.0;
float baseHue = 0.0;
int polygonSides = 4;

void oscEvent(OscMessage msg) {
  String addr = msg.addrPattern();
  
  switch(addr) {
    case "/effect":
      currentEffect = msg.get(0).intValue();
      break;
      
    case "/source":
      useVideo = msg.get(0).intValue() == 1;
      if (useVideo && video != null) {
        video.loop();
      } else if (cam != null) {
        cam.start();
      }
      break;
      
    case "/background":
      showBackground = msg.get(0).intValue() == 1;
      break;
      
    case "/ghost":
      ghostEffect = msg.get(0).intValue() == 1;
      break;
      
    case "/mouse_control":
      mouseControl = msg.get(0).intValue() == 1;
      break;
      
    case "/recording":
      isRecording = msg.get(0).intValue() == 1;
      break;
      
    case "/colormode":
      colorMode = msg.get(0).intValue();
      break;
      
    case "/rotation":
      rotationSpeed = msg.get(0).floatValue();
      break;
      
    case "/color_speed":
      colorSpeed = msg.get(0).floatValue();
      break;
      
    case "/zoom":
      zoom = msg.get(0).floatValue();
      break;
      
    case "/effect_speed":
      effectSpeed = msg.get(0).floatValue();
      break;
      
    case "/size":
      sizeMultiplier = msg.get(0).floatValue();
      break;
      
    case "/brightness":
      brightness = msg.get(0).floatValue();
      break;
      
    case "/saturation":
      saturation = msg.get(0).floatValue();
      break;
      
    case "/color_intensity":
      colorIntensity = msg.get(0).floatValue();
      break;
      
    case "/distort":
      distortAmount = msg.get(0).floatValue();
      break;
      
    case "/rgbshift":
      rgbShiftAmount = msg.get(0).floatValue();
      break;
      
    case "/noise":
      noiseAmount = msg.get(0).floatValue();
      break;
      
    case "/base_hue":
      baseHue = msg.get(0).floatValue();
      break;
      
    case "/polygon_sides":
      polygonSides = constrain(msg.get(0).intValue(), 3, 12);
      break;
  }
}

void draw() {
  float effectX, effectY;
  
  if (mouseControl) {
    effectX = constrain(mouseX, 0, width);
    effectY = constrain(mouseY, 0, height);
  } else {
    effectX = width/2;
    effectY = height/2;
  }
  
  if (useVideo && video != null && video.available()) {
    video.read();
    currentFrame = video;
  } else if (cam != null && cam.available()) {
    cam.read();
    currentFrame = cam;
  }
  
  if (currentFrame != null) {
    // Apply effects based on control values
    pushMatrix();
    translate(width/2, height/2);
    scale(zoom);
    rotate(frameCount * rotationSpeed * 0.01);
    
    // Clear background if not using ghost effect
    if (!ghostEffect) {
      background(0);
    }
    
    // Apply color effects
    tint(
      255 * brightness,
      255 * saturation,
      255 * colorIntensity
    );
    
    // Draw the frame with current effect
    image(currentFrame, -width/2, -height/2, width, height);
    
    // Apply additional effects based on control values
    if (distortAmount > 0) {
      filter(BLUR, distortAmount);
    }
    
    if (rgbShiftAmount > 0) {
      // RGB shift effect implementation
      PImage rgbShifted = currentFrame.copy();
      // ... implement RGB shift based on rgbShiftAmount ...
    }
    
    if (noiseAmount > 0) {
      // Noise effect implementation
      loadPixels();
      for (int i = 0; i < pixels.length; i++) {
        float noise = random(-noiseAmount, noiseAmount);
        pixels[i] = color(
          red(pixels[i]) + noise,
          green(pixels[i]) + noise,
          blue(pixels[i]) + noise
        );
      }
      updatePixels();
    }
    
    popMatrix();
  }
  
  // Record if needed
  if (isRecording) {
    saveFrame("frames/frame-######.png");
  }
} 