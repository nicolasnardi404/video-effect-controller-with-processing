import processing.video.*;
import oscP5.*;  // Add OSC library
import netP5.*;  // Add netP5 library
import com.hamoid.*;  // Add VideoExport library
import java.io.*;
import java.util.concurrent.TimeUnit;

// OSC variables
OscP5 oscP5;
NetAddress myRemoteLocation;

// Video sources
Capture cam;
Movie videoFile;
PImage currentFrame;  // Will hold either camera or video frame
boolean useCamera = true;  // Toggle between camera and video
String videoPath = "video.mp4";  // Default video file name
boolean showBackground = true;  // Control background video visibility

// Video recording
boolean isRecording = false;
int frameRate = 30;
VideoExport videoExport;

// Camera and effects
int currentEffect = 0;
float rotationSpeed = 0.5;
float colorSpeed = 1.0;
float zoom = 0;
boolean ghostEffect = false;
float effectSpeed = 1.0; // New speed control variable

// Shape controls
int polygonSides = 4; // Default to rectangle/square

// Color control
int colorMode = 0; // 0: Rainbow, 1: Monochromatic, 2: Complementary, 3: Analogous, 4: Custom
float baseHue = 0; // Base hue for non-rainbow modes
float saturationBase = 80;
float brightnessBase = 100;

// 3D parameters
float theta = 0;
ArrayList<Particle3D> particles;

// Control parameters
float sizeMultiplier = 1.0;
float colorIntensity = 1.0;
float brightnessMod = 1.0;
float distortAmount = 0.0;
float rgbShiftAmount = 0.0;
float noiseAmount = 0.0;
PShader rgbShiftShader;
PShader noiseShader;

// Mouse control
float rotationX = 0;
float rotationY = 0;
float targetRotX = 0;
float targetRotY = 0;
boolean mouseControl = true;
PVector moveOffset = new PVector(0, 0, 0);

// Add at the top of the file with other global variables
String currentVideoFile = null; // Store the current video file path
Process ffmpegProcess = null;
OutputStream ffmpegInput = null;
PGraphics recordBuffer;

void setup() {
  size(800, 600, P3D);
  colorMode(HSB, 360, 100, 100);
  frameRate(frameRate);
  
  // Initialize OSC
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  
  // Initialize shaders
  rgbShiftShader = loadShader("rgbshift.glsl");
  noiseShader = loadShader("noise.glsl");
  
  // Initialize camera
  String[] cameras = Capture.list();
  if (cameras.length > 0) {
    cam = new Capture(this, 640, 480, cameras[0]);
    cam.start(); // Start camera initially
  }
  
  // Create output directory if it doesn't exist
  File outputDir = new File(sketchPath("output"));
  if (!outputDir.exists()) {
    println("Creating output directory...");
    outputDir.mkdir();
  }
  
  // Test if directory is writable
  if (!outputDir.canWrite()) {
    println("Warning: Output directory is not writable!");
  } else {
    println("Output directory is ready at: " + outputDir.getAbsolutePath());
  }
  
  // Initialize video export
  String timestamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  videoExport = new VideoExport(this, "output/video_" + timestamp + ".mp4");
  videoExport.setFrameRate(frameRate);
  
  // Initialize effects
  initializeEffects();
}

void draw() {
  // Handle ghost effect
  if (ghostEffect) {
    // Semi-transparent black overlay for ghost trail
    fill(0, 20);
    noStroke();
    rect(0, 0, width, height);
  } else {
    background(0);
  }
  
  // Update current frame from either camera or video
  updateFrame();
  
  // Process the current frame if available
  if (currentFrame != null) {
    // Apply shaders if needed
    if (rgbShiftAmount > 0 || noiseAmount > 0) {
      PGraphics shaderBuffer = createGraphics(currentFrame.width, currentFrame.height, P2D);
      shaderBuffer.beginDraw();
      shaderBuffer.background(0);
      
      // Apply RGB shift
      if (rgbShiftAmount > 0) {
        shaderBuffer.shader(rgbShiftShader);
        rgbShiftShader.set("textureSampler", currentFrame);
        rgbShiftShader.set("amount", rgbShiftAmount);
        rgbShiftShader.set("time", millis() * 0.001);
        shaderBuffer.image(currentFrame, 0, 0);
        shaderBuffer.resetShader();
      }
      
      // Apply noise
      if (noiseAmount > 0) {
        shaderBuffer.shader(noiseShader);
        noiseShader.set("textureSampler", currentFrame);
        noiseShader.set("amount", noiseAmount);
        noiseShader.set("time", millis() * 0.001);
        shaderBuffer.image(currentFrame, 0, 0);
        shaderBuffer.resetShader();
      }
      
      shaderBuffer.endDraw();
      currentFrame = shaderBuffer.get();
    }
    
    // Draw the background video
    if (showBackground) {
      pushMatrix();
      hint(DISABLE_DEPTH_TEST);
      camera();
      
      // Draw semi-transparent black overlay
      noStroke();
      fill(0, 150);
      rect(0, 0, width, height);
      
      // Draw full-screen video in background
      imageMode(CORNER);
      tint(360, 40, 100); // White tint with lower opacity
      image(currentFrame, 0, 0, width, height);
      noTint();
      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
  
  updateMouseControl();
  updateCamera();
  drawCurrentEffect();
  
  // Handle recording
  if (isRecording) {
    loadPixels(); // Make sure pixels are updated
    videoExport.saveFrame();
  }
  
  // Draw controls last
  drawControls();
}

void updateFrame() {
  if (useCamera) {
    if (cam != null && cam.available()) {
      cam.read();
      currentFrame = cam;
    }
  } else {
    if (videoFile != null && videoFile.available()) {
      videoFile.read();
      currentFrame = videoFile;
      
      // Debug info
      if (frameCount % 60 == 0) { // Print every 60 frames
        println("Video time: " + nf(videoFile.time(), 0, 1) + "s, " +
                "Duration: " + nf(videoFile.duration(), 0, 1) + "s, " +
                "Frame available: " + videoFile.available());
      }
    }
  }
}

// Function to load a video file
void loadVideo(String filename) {
  println("Attempting to load video: " + filename);
  try {
    if (videoFile != null) {
      videoFile.stop();
    }
    videoFile = new Movie(this, filename);
    videoFile.loop(); // Changed from play() to loop()
    videoFile.volume(0); // Mute the video
    useCamera = false;
    
    // Wait a bit for the video to load
    delay(100);
    if (videoFile.width > 0) {
      println("Video loaded successfully: " + videoFile.width + "x" + videoFile.height);
    } else {
      println("Warning: Video dimensions not available yet");
    }
  } catch (Exception e) {
    println("Error loading video: " + e.getMessage());
    e.printStackTrace(); // Add stack trace for debugging
    switchToCamera();
  }
}

// Function to switch to camera
void switchToCamera() {
  if (videoFile != null) {
    videoFile.stop();
  }
  useCamera = true;
  if (cam != null) {
    cam.start();
  }
}

void updateMouseControl() {
  if (mouseControl && mousePressed) {
    if (mouseButton == LEFT) {
      targetRotY += (mouseX - pmouseX) * 0.01;
      targetRotX += (mouseY - pmouseY) * 0.1;
    } else if (mouseButton == RIGHT) {
      moveOffset.x += (mouseX - pmouseX);
      moveOffset.y += (mouseY - pmouseY);
    }
  }
  
  // Smooth rotation
  rotationX += (targetRotX - rotationX) * 0.1;
  rotationY += (targetRotY - rotationY) * 0.1;
}

void updateCamera() {
  translate(width/2 + moveOffset.x, height/2 + moveOffset.y, zoom + moveOffset.z);
  rotateX(rotationX);
  rotateY(rotationY);
  theta += 0.02 * rotationSpeed * effectSpeed;
}

// Initialize all effects and parameters
void initializeEffects() {
  // Initialize particle system
  initializeParticles();
  
  // Reset control parameters
  sizeMultiplier = 1.0;
  colorIntensity = 1.0;
  brightnessMod = 1.0;
  distortAmount = 0.0;
  
  // Reset view parameters
  rotationX = 0;
  rotationY = 0;
  targetRotX = 0;
  targetRotY = 0;
  moveOffset = new PVector(0, 0, 0);
  
  // Reset effect parameters
  theta = 0;
  zoom = 0;
  rotationSpeed = 0.5;
  colorSpeed = 1.0;
  ghostEffect = false;
  currentEffect = 0;
}

void drawCurrentEffect() {
  if (currentFrame != null) {
    switch(currentEffect) {
      case 0: drawTunnelEffect(); break;
      case 1: drawSphericalEffect(); break;
      case 2: drawParticleEffect(); break;
      case 3: drawVortexEffect(); break;
      case 4: drawCubeEffect(); break;
      case 5: drawKaleidoscopeEffect(); break;
      case 6: drawWaveGridEffect(); break;
      case 7: drawSpiralTowerEffect(); break;
      case 8: drawPolygonEffect(); break;
    }
  }
}

void keyPressed() {
  switch(key) {
    case ' ':
      currentEffect = (currentEffect + 1) % 9;
      break;
    case 'g':
    case 'G':
      ghostEffect = !ghostEffect;
      break;
    case 'z':
    case 'Z':
      zoom += 50;
      break;
    case 'x':
    case 'X':
      zoom -= 50;
      break;
    case 's':
    case 'S':
      sizeMultiplier = constrain(sizeMultiplier + 0.1, 0.1, 3);
      break;
    case 'd':
    case 'D':
      sizeMultiplier = constrain(sizeMultiplier - 0.1, 0.1, 3);
      break;
    case 'p':
    case 'P':
      polygonSides = constrain(polygonSides + 1, 3, 12);
      println("Polygon sides: " + polygonSides);
      break;
    case 'o':
    case 'O':
      polygonSides = constrain(polygonSides - 1, 3, 12);
      println("Polygon sides: " + polygonSides);
      break;
    case 'c':
    case 'C':
      colorIntensity = constrain(colorIntensity + 0.1, 0.1, 2);
      break;
    case 'v':
    case 'V':
      colorIntensity = constrain(colorIntensity - 0.1, 0.1, 2);
      break;
    case 'b':
      rgbShiftAmount = constrain(rgbShiftAmount + 0.1, 0, 1);
      println("RGB Shift: " + nf(rgbShiftAmount, 1, 1));
      break;
    case 'B':
      rgbShiftAmount = constrain(rgbShiftAmount - 0.1, 0, 1);
      println("RGB Shift: " + nf(rgbShiftAmount, 1, 1));
      break;
    case 'n':
      noiseAmount = constrain(noiseAmount + 0.1, 0, 1);
      println("Noise: " + nf(noiseAmount, 1, 1));
      break;
    case 'N':
      noiseAmount = constrain(noiseAmount - 0.1, 0, 1);
      println("Noise: " + nf(noiseAmount, 1, 1));
      break;
    case 'm':
      mouseControl = !mouseControl;
      break;
    case '[':
      effectSpeed = constrain(effectSpeed - 0.1, 0.1, 3.0);
      println("Effect speed: " + nf(effectSpeed, 1, 1));
      break;
    case ']':
      effectSpeed = constrain(effectSpeed + 0.1, 0.1, 3.0);
      println("Effect speed: " + nf(effectSpeed, 1, 1));
      break;
    case 'r':
    case 'R':
      isRecording = !isRecording;
      if (isRecording) {
        startRecording();
      } else {
        stopRecording();
      }
      break;
    // New color mode controls
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
      colorMode = (key - '1');
      println("Color mode: " + new String[]{"Rainbow", "Monochromatic", "Complementary", "Analogous", "Custom"}[colorMode]);
      break;
    case 'h':
    case 'H':
      baseHue = (baseHue + 30) % 360;
      println("Base hue: " + baseHue);
      break;
    case 'j':
    case 'J':
      baseHue = (baseHue - 30 + 360) % 360;
      println("Base hue: " + baseHue);
      break;
    case 'l':
    case 'L':
      selectInput("Select a video file:", "videoSelected");
      break;
    case 'w':
    case 'W':
      switchToCamera();
      break;
    case 'f':
    case 'F':
      showBackground = !showBackground;
      println("Background " + (showBackground ? "shown" : "hidden"));
      break;
  }
  
  if (keyCode == UP) {
    rotationSpeed = min(rotationSpeed + 0.1, 3);
  }
  else if (keyCode == DOWN) {
    rotationSpeed = max(rotationSpeed - 0.1, 0);
  }
  else if (keyCode == RIGHT) {
    colorSpeed = min(colorSpeed + 0.1, 3);
  }
  else if (keyCode == LEFT) {
    colorSpeed = max(colorSpeed - 0.1, 0);
  }
}

void getEffectColor(float offset) {
  switch(colorMode) {
    case 0: // Rainbow
      tint((frameCount * colorSpeed + offset) % 360, 80 * colorIntensity, 100 * brightnessMod);
      break;
    case 1: // Monochromatic
      tint(baseHue, 
           (saturationBase - 20 + offset * 0.5) * colorIntensity, 
           (brightnessBase - offset * 0.3) * brightnessMod);
      break;
    case 2: // Complementary
      tint((baseHue + (offset > 30 ? 180 : 0)) % 360,
           saturationBase * colorIntensity,
           brightnessBase * brightnessMod);
      break;
    case 3: // Analogous
      tint((baseHue + (offset * 0.2) - 30) % 360,
           saturationBase * colorIntensity,
           brightnessBase * brightnessMod);
      break;
    case 4: // Custom Single Color
      tint(baseHue,
           saturationBase * colorIntensity,
           brightnessBase * brightnessMod);
      break;
  }
}

// Add this function to handle video file selection
void videoSelected(File selection) {
  if (selection == null) {
    println("Window was closed or user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    loadVideo(selection.getAbsolutePath());
  }
}

// Add this to handle video events
void movieEvent(Movie m) {
  if (m.available()) {
    m.read();
    currentFrame = m;
  }
}

// OSC event handler
void oscEvent(OscMessage msg) {
  String addr = msg.addrPattern();
  
  switch(addr) {
    case "/effect":
      currentEffect = msg.get(0).intValue();
      break;
    case "/colormode":
      colorMode = msg.get(0).intValue();
      break;
    case "/base_hue":
      baseHue = msg.get(0).floatValue();
      break;
    case "/rotation":
      rotationSpeed = msg.get(0).floatValue();
      break;
    case "/effect_speed":
      effectSpeed = msg.get(0).floatValue();
      break;
    case "/zoom":
      zoom = msg.get(0).floatValue();
      break;
    case "/size":
      sizeMultiplier = msg.get(0).floatValue();
      break;
    case "/brightness":
      brightnessMod = msg.get(0).floatValue();
      break;
    case "/saturation":
      saturationBase = msg.get(0).floatValue() * 100;
      break;
    case "/rgbshift":
      rgbShiftAmount = msg.get(0).floatValue();
      break;
    case "/noise":
      noiseAmount = msg.get(0).floatValue();
      break;
    case "/polygon_sides":
      polygonSides = constrain(msg.get(0).intValue(), 3, 12);
      break;
    case "/ghost":
      ghostEffect = msg.get(0).intValue() == 1;
      break;
    case "/mouse_control":
      mouseControl = msg.get(0).intValue() == 1;
      break;
    case "/background":
      showBackground = msg.get(0).intValue() == 1;
      break;
    case "/recording":
      boolean newRecordingState = msg.get(0).intValue() == 1;
      if (newRecordingState != isRecording) {  // Only act if state actually changed
        isRecording = newRecordingState;
        if (isRecording) {
          startRecording();
        } else {
          stopRecording();
        }
        println("Recording state changed via OSC to: " + isRecording);
      }
      break;
    case "/source":
      useCamera = msg.get(0).intValue() == 0;
      if (useCamera && cam != null) {
        cam.start();
      } else if (videoFile != null) {
        videoFile.loop();
      }
      break;
    case "/video_path":
      loadVideo(msg.get(0).stringValue());
      break;
  }
}

void startRecording() {
  String timestamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  videoExport = new VideoExport(this, "output/video_" + timestamp + ".mp4");
  videoExport.setFrameRate(frameRate);
  videoExport.startMovie();
  println("Started recording: output/video_" + timestamp + ".mp4");
}

void stopRecording() {
  if (videoExport != null) {
    videoExport.endMovie();
    println("Finished recording");
  }
}

void drawPolygonEffect() {
  if (currentFrame == null) return;
  
  float radius = 250 * sizeMultiplier;  // Radius of the circle
  int numRings = 3;  // Number of concentric rings
  int polygonsPerRing = 8;  // Number of polygons in each ring
  float polygonSize = 60 * sizeMultiplier;  // Base size of each polygon
  
  pushMatrix();
  
  // Global rotation for the entire formation
  rotateY(theta * 0.2 * effectSpeed);
  rotateX(sin(theta * 0.3) * 0.2);
  
  // Create multiple rings of polygons
  for (int ring = 0; ring < numRings; ring++) {
    float ringRadius = radius * (1.0 - ring * 0.25);  // Each ring is slightly smaller
    float ringHeight = sin(theta + ring * TWO_PI/numRings) * 50;  // Vertical wave motion
    float ringRotation = theta * (1 + ring * 0.2) * effectSpeed;  // Each ring rotates differently
    
    pushMatrix();
    translate(0, ringHeight, 0);
    rotateY(ringRotation);
    
    // Create polygons in this ring
    for (int i = 0; i < polygonsPerRing; i++) {
      pushMatrix();
      
      // Position around the circle
      float angle = TWO_PI * i / polygonsPerRing;
      float x = cos(angle) * ringRadius;
      float z = sin(angle) * ringRadius;
      
      // Individual polygon animation
      float floatY = sin(theta * 2 + i * 0.5) * 30;
      float individualRotation = theta * effectSpeed + i * TWO_PI / polygonsPerRing;
      
      translate(x, floatY, z);
      
      // Make polygons face outward
      rotateY(angle);
      rotateX(sin(theta + i) * 0.3);
      rotateZ(individualRotation * 0.5);
      
      // Draw the polygon
      beginShape();
      texture(currentFrame);
      noStroke();
      
      // Calculate vertices
      for (int j = 0; j < polygonSides; j++) {
        float a = TWO_PI * j / polygonSides;
        float vx = cos(a) * polygonSize;
        float vy = sin(a) * polygonSize;
        
        // Dynamic texture mapping
        float tx = map(cos(a), -1, 1, 0, currentFrame.width);
        float ty = map(sin(a), -1, 1, 0, currentFrame.height);
        
        // Color effect based on position and time
        getEffectColor(j * 30 + ring * 60 + i * 20);
        
        vertex(vx, vy, 0, tx, ty);
      }
      endShape(CLOSE);
      
      popMatrix();
    }
    popMatrix();
  }
  
  // Add floating center polygon
  pushMatrix();
  rotateZ(theta * effectSpeed);
  rotateX(sin(theta * 0.7) * 0.5);
  rotateY(cos(theta * 0.5) * 0.5);
  scale(1.5);  // Make center polygon larger
  
  beginShape();
  texture(currentFrame);
  noStroke();
  
  for (int i = 0; i < polygonSides; i++) {
    float angle = TWO_PI * i / polygonSides;
    float x = cos(angle) * polygonSize;
    float y = sin(angle) * polygonSize;
    
    float tx = map(cos(angle), -1, 1, 0, currentFrame.width);
    float ty = map(sin(angle), -1, 1, 0, currentFrame.height);
    
    getEffectColor(i * 45 + frameCount * 0.5);
    
    vertex(x, y, 0, tx, ty);
  }
  endShape(CLOSE);
  
  popMatrix();
  popMatrix();
} 
