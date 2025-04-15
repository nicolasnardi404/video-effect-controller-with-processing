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

// Add after other global variables
int backgroundStage = 0; // 0: Normal, 1: B&W, 2: Edge Detection, 3: Saturation Explosion, 4: Psychedelic

// Text variables
String displayText = "";
float textSize = 24;
int textColorMode = 0; // 0: White, 1: Black, 2: Rainbow, 3: Custom
PFont font;

// Add these variables with other global variables at the top
boolean isTyping = false;
StringBuilder typingBuffer = new StringBuilder();
float textGlitchAmount = 0.0;
float textRGBOffset = 0.0;

void setup() {
  size(800, 600, P3D);
  colorMode(HSB, 360, 100, 100);
  frameRate(frameRate);
  
  // Initialize font
  font = createFont("Arial", 32);
  textFont(font);
  textAlign(CENTER, CENTER);
  
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
    // Create a buffer for background processing
    PGraphics processedFrame = createGraphics(currentFrame.width, currentFrame.height, P2D);
    processedFrame.beginDraw();
    processedFrame.image(currentFrame, 0, 0);
    
    switch(backgroundStage) {
      case 0: // Normal with subtle enhancement
        processedFrame.filter(POSTERIZE, 255); // Very subtle posterization
        processedFrame.filter(BLUR, 0.5f);
        break;
        
      case 1: // Two-color smooth transition effect
        processedFrame.filter(GRAY);
        processedFrame.filter(POSTERIZE, 4); // Keep strong contrast
        processedFrame.loadPixels();
        // Calculate smooth color transitions
        float hue1 = (frameCount * 0.2) % 360; // First color hue
        float hue2 = (hue1 + 180) % 360; // Second color (complementary)
        for (int i = 0; i < processedFrame.pixels.length; i++) {
          float b = brightness(processedFrame.pixels[i]);
          // Map brightness to interpolate between the two colors
          if (b < 50) {
            processedFrame.pixels[i] = color(hue1, 70, 60); // Darker areas get first color
          } else {
            processedFrame.pixels[i] = color(hue2, 70, 80); // Lighter areas get second color
          }
        }
        processedFrame.updatePixels();
        break;
        
      case 2: // Ghostly Horror effect
        processedFrame.filter(GRAY);
        processedFrame.loadPixels();
        float timeScale = frameCount * 0.02;
        
        for (int y = 0; y < processedFrame.height; y++) {
          for (int x = 0; x < processedFrame.width; x++) {
            int i = x + y * processedFrame.width;
            
            // Create wavey distortion
            float distortX = x + sin(y * 0.05 + timeScale) * 2;
            float distortY = y + cos(x * 0.05 + timeScale) * 2;
            
            // Add noise distortion
            float noiseValue = noise(x * 0.02, y * 0.02, timeScale) * 20;
            distortX += noiseValue;
            distortY += noiseValue;
            
            // Keep coordinates within bounds
            distortX = constrain(distortX, 0, processedFrame.width - 1);
            distortY = constrain(distortY, 0, processedFrame.height - 1);
            
            // Sample the distorted position
            int srcPos = int(distortX) + int(distortY) * processedFrame.width;
            srcPos = constrain(srcPos, 0, processedFrame.pixels.length - 1);
            
            // Get brightness and apply contrast
            float b = brightness(processedFrame.pixels[srcPos]);
            b = map(b, 30, 70, 0, 100); // Increase contrast
            b = constrain(b, 0, 100);
            
            // Add ghostly fade effect
            float fadeAmount = noise(x * 0.01, y * 0.01, timeScale * 0.5) * 30;
            b = constrain(b - fadeAmount, 0, 100);
            
            // Create final color with slight variation
            processedFrame.pixels[i] = color(0, 0, b);
          }
        }
        processedFrame.updatePixels();
        
        // Add vignette effect
        processedFrame.loadPixels();
        float centerX = processedFrame.width / 2;
        float centerY = processedFrame.height / 2;
        float maxDist = dist(0, 0, centerX, centerY);
        
        for (int y = 0; y < processedFrame.height; y++) {
          for (int x = 0; x < processedFrame.width; x++) {
            int i = x + y * processedFrame.width;
            float d = dist(x, y, centerX, centerY);
            float vignetteAmount = map(d, 0, maxDist, 0, 1);
            vignetteAmount = pow(vignetteAmount, 2); // Make vignette more pronounced
            
            float b = brightness(processedFrame.pixels[i]);
            b = b * (1 - vignetteAmount * 0.7); // Darken edges
            processedFrame.pixels[i] = color(0, 0, b);
          }
        }
        processedFrame.updatePixels();
        break;
        
      case 3: // Dynamic Color Explosion
        processedFrame.colorMode(HSB, 360, 100, 100);
        processedFrame.loadPixels();
        float pulseRate = sin(millis() * 0.002f) * 0.5 + 1.5;
        for (int y = 0; y < processedFrame.height; y++) {
          for (int x = 0; x < processedFrame.width; x++) {
            int i = x + y * processedFrame.width;
            color c = processedFrame.pixels[i];
            float h = (hue(c) + frameCount) % 360;
            float s = min(saturation(c) * pulseRate, 100);
            float b = brightness(c);
            float distanceFromCenter = dist(x, y, processedFrame.width/2, processedFrame.height/2);
            float hueMod = map(distanceFromCenter, 0, 300, 0, 180) * sin(frameCount * 0.02);
            processedFrame.pixels[i] = color((h + hueMod) % 360, s, b);
          }
        }
        processedFrame.updatePixels();
        break;
        
      case 4: // Psychedelic Mirror
        processedFrame.colorMode(HSB, 360, 100, 100);
        processedFrame.loadPixels();
        float mirrorTimeScale = millis() * 0.001f;
        int halfWidth = processedFrame.width / 2;
        
        for (int y = 0; y < processedFrame.height; y++) {
          for (int x = 0; x < halfWidth; x++) {
            int pos1 = x + y * processedFrame.width;
            int pos2 = (processedFrame.width - 1 - x) + y * processedFrame.width;
            color c = processedFrame.pixels[pos1];
            
            float noiseVal = noise(x * 0.02f, y * 0.02f, mirrorTimeScale);
            float h = (hue(c) + noiseVal * 180) % 360;
            float s = min(saturation(c) * 1.5f, 100);
            float b = brightness(c);
            
            color mirroredColor = color(h, s, b);
            processedFrame.pixels[pos1] = mirroredColor;
            processedFrame.pixels[pos2] = mirroredColor;
          }
        }
        
        // Add flowing lines
        for (int y = 0; y < processedFrame.height; y++) {
          float wave = sin(y * 0.05 + mirrorTimeScale * 2) * 20;
          for (int x = 0; x < processedFrame.width; x++) {
            if (abs((x + wave) % 20) < 2) {
              int pos = x + y * processedFrame.width;
              float h = (frameCount * 2) % 360;
              processedFrame.pixels[pos] = color(h, 100, 100);
            }
          }
        }
        processedFrame.updatePixels();
        break;
    }
    processedFrame.endDraw();
    
    // Apply shaders if needed
    if (rgbShiftAmount > 0 || noiseAmount > 0) {
      PGraphics shaderBuffer = createGraphics(processedFrame.width, processedFrame.height, P2D);
      shaderBuffer.beginDraw();
      shaderBuffer.background(0);
      
      // Apply RGB shift
      if (rgbShiftAmount > 0) {
        shaderBuffer.shader(rgbShiftShader);
        rgbShiftShader.set("textureSampler", processedFrame);
        rgbShiftShader.set("amount", rgbShiftAmount);
        rgbShiftShader.set("time", millis() * 0.001);
        shaderBuffer.image(processedFrame, 0, 0);
        shaderBuffer.resetShader();
      }
      
      // Apply noise
      if (noiseAmount > 0) {
        shaderBuffer.shader(noiseShader);
        noiseShader.set("textureSampler", processedFrame);
        noiseShader.set("amount", noiseAmount);
        noiseShader.set("time", millis() * 0.001);
        shaderBuffer.image(processedFrame, 0, 0);
        shaderBuffer.resetShader();
      }
      
      shaderBuffer.endDraw();
      currentFrame = shaderBuffer.get();
    } else {
      currentFrame = processedFrame.get();
    }
    
    if (showBackground) {
      // Draw the background video with effects
      pushMatrix();
      hint(DISABLE_DEPTH_TEST);
      camera();
      
      // Draw colored overlay based on current color mode
      noStroke();
      float overlayHue = (frameCount * 0.5) % 360;
      switch(colorMode) {
        case 0: // Rainbow
          fill(overlayHue, 80, 30, 150);
          break;
        case 1: // Monochromatic
          fill(baseHue, 70, 30, 150);
          break;
        case 2: // Complementary
          fill((baseHue + 180) % 360, 70, 30, 150);
          break;
        case 3: // Analogous
          fill((baseHue + 30) % 360, 70, 30, 150);
          break;
        case 4: // Custom
          fill(baseHue, 70, 30, 150);
          break;
      }
      rect(0, 0, width, height);
      
      // Draw full-screen video in background with dynamic tint
      imageMode(CORNER);
      float tintHue = (baseHue + frameCount * colorSpeed) % 360;
      tint(tintHue, 60, 80, 100); // Colored tint with medium opacity
      image(currentFrame, 0, 0, width, height);
      noTint();
      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    } else {
      // Create dynamic colored background when video is hidden
      pushMatrix();
      hint(DISABLE_DEPTH_TEST);
      camera();
      
      float time = millis() * 0.0005; // Slower time scale
      
      switch(backgroundStage) {
        case 0: // Floating bubbles
          // Soft gradient base
          noStroke();
          for (int y = 0; y < height; y += height/40) {
            float inter = map(y, 0, height, 0, 1);
            float hue = (baseHue + inter * 30) % 360;
            fill(hue, 30, 98); // Very light pastel base
            rect(0, y, width, height/40 + 1);
          }
          
          // Floating bubbles with trails
          for (int i = 0; i < 12; i++) {
            float noiseX = noise(time + i * 100, 0) * width;
            float noiseY = noise(0, time + i * 100) * height;
            float size = 30 + noise(time * 2 + i * 300) * 50;
            float hue = (baseHue + i * 30) % 360;
            
            // Draw trail
            for (int j = 4; j > 0; j--) {
              float trailX = noiseX + cos(time * (0.5 + i * 0.1) + j) * 20;
              float trailY = noiseY + sin(time * (0.7 + i * 0.1) + j) * 20;
              float alpha = map(j, 4, 0, 20, 60);
              fill(hue, 40, 95, alpha);
              circle(trailX, trailY, size * j/4);
            }
          }
          break;
          
        case 1: // Aurora waves
          background(0);
          noStroke();
          
          // Create flowing aurora waves
          for (int i = 0; i < 8; i++) {
            float waveOffset = i * height/8;
            for (int x = 0; x < width; x += 2) {
              float wave = sin(x * 0.01 + time + i) * 100;
              float hue = (baseHue + wave * 0.5) % 360;
              float alpha = 100 - abs(wave) * 0.5;
              fill(hue, 50, 95, alpha);
              float y = waveOffset + wave;
              circle(x, y, 150);
            }
          }
          break;
          
        case 2: // Geometric patterns
          background(0);
          noStroke();
          
          // Draw rotating triangles
          for (int i = 0; i < 12; i++) {
            float angle = TWO_PI * i / 12 + time;
            float radius = 150 + sin(time * 2 + i) * 50;
            float x = width/2 + cos(angle) * radius;
            float y = height/2 + sin(angle) * radius;
            float size = 100 + sin(time + i) * 30;
            
            fill((baseHue + i * 30) % 360, 40, 95, 70);
            pushMatrix();
            translate(x, y);
            rotate(angle + time);
            triangle(-size/2, size/2, size/2, size/2, 0, -size/2);
            popMatrix();
          }
          break;
          
        case 3: // Color rain
          // Dark background with bright drops
          background(0);
          noStroke();
          
          // Create rain drops
          for (int i = 0; i < 100; i++) {
            float x = (noise(i, time * 0.5) * width * 1.5) - width * 0.25;
            float y = ((time * 1000 + i * 100) % height);
            float speed = 1 + noise(i) * 2;
            float len = 10 + speed * 10;
            float hue = (baseHue + noise(i) * 60) % 360;
            
            // Draw drop with gradient
            for (int j = 0; j < len; j++) {
              float alpha = map(j, 0, len, 100, 0);
              fill(hue, 60, 95, alpha);
              float dropY = y - j * speed;
              circle(x, dropY, 2);
            }
          }
          break;
          
        case 4: // Nebula clouds
          background(0);
          noStroke();
          
          // Create nebula effect
          for (int i = 0; i < 20; i++) {
            float cloudX = width/2 + noise(time + i * 100) * width - width/2;
            float cloudY = height/2 + noise(time * 0.5 + i * 200) * height - height/2;
            float size = 100 + noise(i, time) * 200;
            float hue = (baseHue + noise(i, time) * 60) % 360;
            
            // Create glowing cloud layers
            for (int j = 5; j > 0; j--) {
              float alpha = map(j, 5, 0, 10, 40);
              float layerSize = size * j/3;
              fill(hue, 30, 98, alpha);
              circle(cloudX, cloudY, layerSize);
              
              // Add some sparkles
              if (j == 1 && random(1) > 0.7) {
                fill(hue, 10, 100, 80);
                float sparkleX = cloudX + random(-size/2, size/2);
                float sparkleY = cloudY + random(-size/2, size/2);
                circle(sparkleX, sparkleY, random(1, 3));
              }
            }
          }
          break;
      }
      
      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
  
  updateMouseControl();
  updateCamera();
  drawCurrentEffect();
  
  // Draw text overlay last
  drawText();
  
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
  if (key == ENTER || key == RETURN) {
    if (isTyping) {
      // Add a newline character when typing
      typingBuffer.append('\n');
    } else {
      // Toggle typing mode
      isTyping = !isTyping;
      if (!isTyping && typingBuffer.length() > 0) {
        displayText = typingBuffer.toString();
        typingBuffer.setLength(0);
      }
    }
    return;
  }
  
  if (isTyping) {
    if (key == BACKSPACE) {
      if (typingBuffer.length() > 0) {
        typingBuffer.setLength(typingBuffer.length() - 1);
      }
    } else if (key == TAB) {
      typingBuffer.append("    "); // 4 spaces for tab
    } else if (key >= ' ' && key <= '~') {  // Printable characters
      typingBuffer.append(key);
    }
    return;
  }

  // Existing key handlers
  switch(key) {
    case ' ':
      currentEffect = (currentEffect + 1) % 9;
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
      backgroundStage = (backgroundStage + 1) % 5;
      println("Background stage: " + backgroundStage);
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
    case 't':
    case 'T':
      textGlitchAmount = (textGlitchAmount + 0.2) % 1.0;
      println("Text glitch amount: " + nf(textGlitchAmount, 0, 1));
      break;
    case 'y':
    case 'Y':
      textRGBOffset = (textRGBOffset + 0.2) % 1.0;
      println("Text RGB offset: " + nf(textRGBOffset, 0, 1));
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
    case "/background_stage":
      backgroundStage = msg.get(0).intValue();
      println("Background stage changed to: " + backgroundStage);
      break;
    case "/text":
      displayText = msg.get(0).stringValue();
      break;
    case "/text_size":
      textSize = msg.get(0).floatValue();
      break;
    case "/text_color":
      textColorMode = msg.get(0).intValue();
      break;
    case "/text_glitch":
      textGlitchAmount = msg.get(0).floatValue();
      break;
    case "/text_rgb":
      textRGBOffset = msg.get(0).floatValue();
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

// Replace the drawText function with this enhanced version
void drawText() {
  String textToShow = isTyping ? typingBuffer.toString() + (frameCount % 30 < 15 ? "_" : "") : displayText;
  
  if (textToShow.length() > 0) {
    pushStyle();
    pushMatrix();
    
    camera();
    hint(DISABLE_DEPTH_TEST);
    
    textAlign(CENTER, CENTER);
    textSize(textSize);
    
    float rainbowHue = (frameCount * 2) % 360;
    
    // Split text into lines
    String[] lines = textToShow.split("\n");
    float lineHeight = textSize * 1.2; // Add some spacing between lines
    float totalHeight = lineHeight * lines.length;
    float startY = height/2 - totalHeight/2; // Center all lines vertically
    
    for (int i = 0; i < lines.length; i++) {
      // Apply movement effect per line
      float moveX = width/2 + sin(frameCount * 0.05 + i * 0.2) * (5 + textGlitchAmount * 10);
      float moveY = startY + i * lineHeight + cos(frameCount * 0.03 + i * 0.2) * (3 + textGlitchAmount * 8);
      
      // Glitch effect
      if (textGlitchAmount > 0 && frameCount % 10 < 3) {
        moveX += random(-20, 20) * textGlitchAmount;
        moveY += random(-10, 10) * textGlitchAmount;
      }
      
      // Draw shadow/outline
      float shadowOffset = textSize * 0.05;
      fill(0, 0, 0, 80);
      text(lines[i], moveX - shadowOffset, moveY - shadowOffset);
      text(lines[i], moveX + shadowOffset, moveY - shadowOffset);
      text(lines[i], moveX - shadowOffset, moveY + shadowOffset);
      text(lines[i], moveX + shadowOffset, moveY + shadowOffset);
      
      // RGB Split effect
      if (textRGBOffset > 0) {
        float rgbOffset = 2 + textRGBOffset * 8;
        
        // Red channel
        fill(0, 100, 100, 200);
        text(lines[i], moveX - rgbOffset, moveY);
        
        // Blue channel
        fill(240, 100, 100, 200);
        text(lines[i], moveX + rgbOffset, moveY);
        
        // Green channel
        fill(120, 100, 100, 200);
        text(lines[i], moveX, moveY);
      } else {
        // Normal text color
        switch(textColorMode) {
          case 0: // White
            fill(0, 0, 100);
            break;
          case 1: // Black
            fill(0, 0, 0);
            break;
          case 2: // Rainbow
            fill(rainbowHue + i * 30, 80, 100); // Slightly different hue per line
            break;
          case 3: // Custom
            fill(baseHue, saturationBase, brightnessBase);
            break;
        }
        text(lines[i], moveX, moveY);
      }
    }
    
    // Glitch blocks (random rectangles) when glitch effect is active
    if (textGlitchAmount > 0 && frameCount % 15 < 2) {
      for (int i = 0; i < 5; i++) {
        float x = random(width * 0.3, width * 0.7);
        float y = random(height * 0.3, height * 0.7);
        float w = random(20, 100) * textGlitchAmount;
        float h = random(2, 10) * textGlitchAmount;
        fill(random(360), 80, 100, 150);
        noStroke();
        rect(x, y, w, h);
      }
    }
    
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
    popStyle();
  }
}
