void drawControls() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  
  // Draw controls background
  fill(0, 80);
  noStroke();
  rect(10, height - 140, 380, 130);
  
  // Draw text
  fill(360, 0, 100);
  textAlign(LEFT);
  textSize(12);
  
  // First column
  text("Effect [SPACE]: " + currentEffect, 20, height - 120);
  text("Size [S/D]: " + nf(sizeMultiplier, 1, 1), 20, height - 100);
  text("Color [C/V]: " + nf(colorIntensity, 1, 1), 20, height - 80);
  text("Speed [[ ]]: " + nf(effectSpeed, 1, 1), 20, height - 60);
  text("Ghost [G]: " + (ghostEffect ? "ON" : "OFF"), 20, height - 40);
  text("Mouse Control [M]: " + (mouseControl ? "ON" : "OFF"), 20, height - 20);
  
  // Second column
  text("RGB Shift [b/B]: " + nf(rgbShiftAmount, 1, 1), 200, height - 120);
  text("Noise [n/N]: " + nf(noiseAmount, 1, 1), 200, height - 100);
  text("Rotation [↑/↓]: " + nf(rotationSpeed, 1, 1), 200, height - 80);
  text("Color Speed [←/→]: " + nf(colorSpeed, 1, 1), 200, height - 60);
  text("Color Mode [1-5]: " + new String[]{"Rainbow", "Mono", "Comp", "Ana", "Custom"}[colorMode], 200, height - 40);
  text("Background [F]: " + (showBackground ? "ON" : "OFF"), 200, height - 20);
  
  // Recording indicator
  if (isRecording) {
    fill(#FF0000);
    ellipse(width - 20, height - 20, 10, 10);
    fill(360, 0, 100);
    text("Recording [R]", width - 100, height - 16);
  }
  
  hint(ENABLE_DEPTH_TEST);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom -= e * 50;
} 