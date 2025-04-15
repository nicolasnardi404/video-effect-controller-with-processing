void drawTunnelEffect() {
  pushMatrix();
  rotateX(PI/3);
  rotateZ(theta);
  
  int tunnelSegments = 20;
  float tunnelRadius = 200;
  float tunnelLength = 800;
  
  for (int i = 0; i < tunnelSegments; i++) {
    float z = map(i, 0, tunnelSegments-1, -tunnelLength/2, tunnelLength/2);
    float radius = tunnelRadius + sin(z * 0.01 + theta) * 50;
    
    beginShape(TRIANGLE_STRIP);
    texture(currentFrame);
    
    for (float angle = 0; angle <= TWO_PI; angle += PI/12) {
      float x1 = cos(angle) * radius;
      float y1 = sin(angle) * radius;
      float x2 = cos(angle) * (radius * 0.8);
      float y2 = sin(angle) * (radius * 0.8);
      
      float tx = map(angle, 0, TWO_PI, 0, currentFrame.width);
      float ty = map(z, -tunnelLength/2, tunnelLength/2, 0, currentFrame.height);
      
      getEffectColor(i * 20);
      vertex(x1, y1, z, tx, ty);
      vertex(x2, y2, z + tunnelLength/tunnelSegments, tx, ty + currentFrame.height/tunnelSegments);
    }
    endShape();
  }
  popMatrix();
}

void drawSphericalEffect() {
  pushMatrix();
  rotateY(theta);
  
  int detail = 30;
  float radius = 200;
  
  for (int i = 0; i < detail; i++) {
    float lat = map(i, 0, detail-1, -PI/2, PI/2);
    
    beginShape(TRIANGLE_STRIP);
    texture(currentFrame);
    
    for (int j = 0; j <= detail; j++) {
      float lon = map(j, 0, detail, -PI, PI);
      
      for (int k = 0; k <= 1; k++) {
        float currLat = lat + k * PI/detail;
        float x = radius * cos(currLat) * cos(lon);
        float y = radius * sin(currLat);
        float z = radius * cos(currLat) * sin(lon);
        
        float tx = map(j, 0, detail, 0, currentFrame.width);
        float ty = map(i + k, 0, detail, 0, currentFrame.height);
        
        getEffectColor(i * 12);
        vertex(x, y, z, tx, ty);
      }
    }
    endShape();
  }
  popMatrix();
}

void drawVortexEffect() {
  pushMatrix();
  float vortexRadius = 200 * sizeMultiplier;
  float vortexHeight = 400 * sizeMultiplier;
  
  for (int i = 0; i < 20; i++) {
    float z = map(i, 0, 19, -vortexHeight/2, vortexHeight/2);
    float twist = theta * 2 + z * 0.01 * distortAmount;
    
    beginShape(TRIANGLE_STRIP);
    texture(currentFrame);
    
    for (float angle = 0; angle <= TWO_PI; angle += PI/12) {
      float r = vortexRadius + sin(z * 0.02 + theta) * 50;
      float x = cos(angle + twist) * r;
      float y = sin(angle + twist) * r;
      
      float tx = map(angle, 0, TWO_PI, 0, currentFrame.width);
      float ty = map(z, -vortexHeight/2, vortexHeight/2, 0, currentFrame.height);
      
      getEffectColor(i * 20);
      vertex(x, y, z, tx, ty);
      vertex(x, y, z + vortexHeight/20, tx, ty + currentFrame.height/20);
    }
    endShape();
  }
  popMatrix();
}

// Helper function to draw a 3D polygon (prism) with variable sides and dynamic depth
void drawPolygon(float size, float texX, float texY, float texWidth, float texHeight) {
  float depth = size * 0.5; // Make depth proportional to size but slightly smaller
  float angleStep = TWO_PI / polygonSides;
  
  // Draw front face with slight rotation for better 3D effect
  pushMatrix();
  rotateX(sin(theta * 0.5) * 0.2);
  rotateY(cos(theta * 0.3) * 0.2);
  
  // Front face
  beginShape();
  texture(currentFrame);
  for (int i = 0; i < polygonSides; i++) {
    float angle = i * angleStep;
    float x = cos(angle) * size;
    float y = sin(angle) * size;
    float tx = map(i, 0, polygonSides, texX, texX + texWidth);
    float ty = map(i, 0, polygonSides, texY, texY + texHeight);
    vertex(x, y, depth/2, tx, ty);
  }
  endShape(CLOSE);
  
  // Back face
  beginShape();
  texture(currentFrame);
  for (int i = 0; i < polygonSides; i++) {
    float angle = i * angleStep;
    float x = cos(angle) * size;
    float y = sin(angle) * size;
    float tx = map(i, 0, polygonSides, texX + texWidth, texX);
    float ty = map(i, 0, polygonSides, texY, texY + texHeight);
    vertex(x, y, -depth/2, tx, ty);
  }
  endShape(CLOSE);
  
  // Draw side faces with dynamic texture mapping
  for (int i = 0; i < polygonSides; i++) {
    float angle1 = i * angleStep;
    float angle2 = ((i + 1) % polygonSides) * angleStep;
    float x1 = cos(angle1) * size;
    float y1 = sin(angle1) * size;
    float x2 = cos(angle2) * size;
    float y2 = sin(angle2) * size;
    
    // Side face (using TRIANGLE_STRIP for better 3D rendering)
    beginShape(TRIANGLE_STRIP);
    texture(currentFrame);
    
    // First vertex pair
    vertex(x1, y1, depth/2, texX + (texWidth * i/polygonSides), texY);
    vertex(x1, y1, -depth/2, texX + (texWidth * i/polygonSides), texY + texHeight);
    
    // Second vertex pair
    vertex(x2, y2, depth/2, texX + (texWidth * (i+1)/polygonSides), texY);
    vertex(x2, y2, -depth/2, texX + (texWidth * (i+1)/polygonSides), texY + texHeight);
    
    endShape();
  }
  
  popMatrix();
}

void drawCubeEffect() {
  pushMatrix();
  float size = 200 * sizeMultiplier;
  
  for (int i = 0; i < 6; i++) {
    pushMatrix();
    
    switch(i) {
      case 0: translate(0, 0, size); break;
      case 1: translate(0, 0, -size); rotateY(PI); break;
      case 2: translate(size, 0, 0); rotateY(HALF_PI); break;
      case 3: translate(-size, 0, 0); rotateY(-HALF_PI); break;
      case 4: translate(0, size, 0); rotateX(-HALF_PI); break;
      case 5: translate(0, -size, 0); rotateX(HALF_PI); break;
    }
    
    beginShape();
    texture(currentFrame);
    getEffectColor(i * 60);
    
    vertex(-size, -size, 0, 0, 0);
    vertex(size, -size, 0, currentFrame.width, 0);
    vertex(size, size, 0, currentFrame.width, currentFrame.height);
    vertex(-size, size, 0, 0, currentFrame.height);
    endShape(CLOSE);
    
    popMatrix();
  }
  popMatrix();
}

void drawKaleidoscopeEffect() {
  pushMatrix();
  rotateX(PI/3);
  
  int segments = 8;
  float radius = 300 * sizeMultiplier;
  
  for (int i = 0; i < segments; i++) {
    pushMatrix();
    rotateY(TWO_PI * i / segments + theta);
    
    beginShape();
    texture(currentFrame);
    getEffectColor(i * (360/segments));
    
    vertex(-radius, -radius, 0, 0, 0);
    vertex(radius, -radius, 0, currentFrame.width, 0);
    vertex(radius, radius, 0, currentFrame.width, currentFrame.height);
    vertex(-radius, radius, 0, 0, currentFrame.height);
    endShape();
    
    popMatrix();
  }
  popMatrix();
}

void drawWaveGridEffect() {
  pushMatrix();
  rotateX(PI/3);
  
  int gridSize = 20;
  float cellSize = 40 * sizeMultiplier;
  float waveHeight = 100 * sizeMultiplier;
  float cellDepth = 30 * sizeMultiplier; // Depth for 3D cells
  
  for (int x = -gridSize/2; x < gridSize/2; x++) {
    for (int z = -gridSize/2; z < gridSize/2; z++) {
      pushMatrix();
      
      float xPos = x * cellSize;
      float zPos = z * cellSize;
      float distance = dist(xPos, zPos, 0, 0);
      float y = sin(distance * 0.02 + theta) * waveHeight;
      
      translate(xPos, y, zPos);
      rotateX(sin(distance * 0.01 + theta) * 0.2); // Add some wave rotation
      rotateZ(cos(distance * 0.01 + theta) * 0.2); // Add some twist
      
      // Top face
      beginShape();
      texture(currentFrame);
      getEffectColor(distance);
      vertex(-cellSize/2, cellDepth/2, -cellSize/2, 0, 0);
      vertex(cellSize/2, cellDepth/2, -cellSize/2, currentFrame.width, 0);
      vertex(cellSize/2, cellDepth/2, cellSize/2, currentFrame.width, currentFrame.height);
      vertex(-cellSize/2, cellDepth/2, cellSize/2, 0, currentFrame.height);
      endShape(CLOSE);
      
      // Bottom face
      beginShape();
      texture(currentFrame);
      getEffectColor((distance + 180) % 360);
      vertex(-cellSize/2, -cellDepth/2, -cellSize/2, currentFrame.width, 0);
      vertex(cellSize/2, -cellDepth/2, -cellSize/2, 0, 0);
      vertex(cellSize/2, -cellDepth/2, cellSize/2, 0, currentFrame.height);
      vertex(-cellSize/2, -cellDepth/2, cellSize/2, currentFrame.width, currentFrame.height);
      endShape(CLOSE);
      
      // Side faces
      beginShape(TRIANGLE_STRIP);
      texture(currentFrame);
      getEffectColor((distance + 90) % 360);
      
      // Front edge
      vertex(-cellSize/2, cellDepth/2, -cellSize/2, 0, 0);
      vertex(-cellSize/2, -cellDepth/2, -cellSize/2, 0, currentFrame.height/4);
      vertex(cellSize/2, cellDepth/2, -cellSize/2, currentFrame.width, 0);
      vertex(cellSize/2, -cellDepth/2, -cellSize/2, currentFrame.width, currentFrame.height/4);
      
      // Right edge
      vertex(cellSize/2, cellDepth/2, cellSize/2, currentFrame.width, currentFrame.height/2);
      vertex(cellSize/2, -cellDepth/2, cellSize/2, currentFrame.width, currentFrame.height*3/4);
      
      // Back edge
      vertex(-cellSize/2, cellDepth/2, cellSize/2, 0, currentFrame.height/2);
      vertex(-cellSize/2, -cellDepth/2, cellSize/2, 0, currentFrame.height*3/4);
      
      // Left edge (back to start)
      vertex(-cellSize/2, cellDepth/2, -cellSize/2, 0, currentFrame.height);
      vertex(-cellSize/2, -cellDepth/2, -cellSize/2, 0, currentFrame.height);
      endShape();
      
      popMatrix();
    }
  }
  popMatrix();
}

void drawSpiralTowerEffect() {
  pushMatrix();
  rotateX(PI/3);
  
  float towerHeight = 600 * sizeMultiplier;
  int spiralSteps = 30;
  float spiralRadius = 200 * sizeMultiplier;
  int facesPerStep = 8; // Number of faces around each step
  
  for (int i = 0; i < spiralSteps; i++) {
    float z = map(i, 0, spiralSteps-1, -towerHeight/2, towerHeight/2);
    float baseAngle = i * TWO_PI/8 + theta;
    float radius = spiralRadius * (1 + sin(z * 0.01 + theta));
    
    // Create multiple faces around each spiral step
    for (int face = 0; face < facesPerStep; face++) {
      pushMatrix();
      float faceAngle = baseAngle + (TWO_PI * face / facesPerStep);
      float x = cos(faceAngle) * radius;
      float y = sin(faceAngle) * radius;
      
      translate(x, y, z);
      rotateY(faceAngle + PI/2); // Rotate face to point outward
      rotateX(sin(theta + i * 0.2) * 0.3); // Add some wobble
      rotateZ(cos(theta + face * 0.5) * 0.2); // Add some twist
      
      float size = 50 * sizeMultiplier * (1 + sin(z * 0.02 + theta));
      
      // Draw front face
      beginShape();
      texture(currentFrame);
      getEffectColor(i * (360/spiralSteps) + face * (360/facesPerStep));
      float tx = map(i + face, 0, spiralSteps + facesPerStep, 0, currentFrame.width);
      vertex(-size, -size, size/2, tx, 0);
      vertex(size, -size, size/2, tx + currentFrame.width/spiralSteps, 0);
      vertex(size, size, size/2, tx + currentFrame.width/spiralSteps, currentFrame.height);
      vertex(-size, size, size/2, tx, currentFrame.height);
      endShape(CLOSE);
      
      // Draw back face
      beginShape();
      texture(currentFrame);
      getEffectColor((i * (360/spiralSteps) + face * (360/facesPerStep) + 180) % 360);
      vertex(-size, -size, -size/2, tx + currentFrame.width/spiralSteps, 0);
      vertex(size, -size, -size/2, tx, 0);
      vertex(size, size, -size/2, tx, currentFrame.height);
      vertex(-size, size, -size/2, tx + currentFrame.width/spiralSteps, currentFrame.height);
      endShape(CLOSE);
      
      // Connect front and back faces with side faces
      beginShape(TRIANGLE_STRIP);
      texture(currentFrame);
      getEffectColor((i * (360/spiralSteps) + face * (360/facesPerStep) + 90) % 360);
      // Top edge
      vertex(-size, -size, size/2, tx, 0);
      vertex(-size, -size, -size/2, tx, currentFrame.height/4);
      vertex(size, -size, size/2, tx + currentFrame.width/spiralSteps, 0);
      vertex(size, -size, -size/2, tx + currentFrame.width/spiralSteps, currentFrame.height/4);
      // Right edge
      vertex(size, size, size/2, tx + currentFrame.width/spiralSteps, currentFrame.height/2);
      vertex(size, size, -size/2, tx + currentFrame.width/spiralSteps, currentFrame.height*3/4);
      // Bottom edge
      vertex(-size, size, size/2, tx, currentFrame.height/2);
      vertex(-size, size, -size/2, tx, currentFrame.height*3/4);
      // Left edge (back to start)
      vertex(-size, -size, size/2, tx, currentFrame.height);
      vertex(-size, -size, -size/2, tx, currentFrame.height);
      endShape();
      
      popMatrix();
    }
  }
  popMatrix();
} 
