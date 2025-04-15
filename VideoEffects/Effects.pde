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

// Helper function to draw a polygon with variable sides
void drawPolygon(float size, float texX, float texY, float texWidth, float texHeight) {
  beginShape();
  texture(currentFrame);
  float angleStep = TWO_PI / polygonSides;
  for (int i = 0; i < polygonSides; i++) {
    float angle = i * angleStep;
    float x = cos(angle) * size;
    float y = sin(angle) * size;
    float tx = map(i, 0, polygonSides, texX, texX + texWidth);
    float ty = map(i, 0, polygonSides, texY, texY + texHeight);
    vertex(x, y, 0, tx, ty);
  }
  endShape(CLOSE);
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
  
  for (int x = -gridSize/2; x < gridSize/2; x++) {
    for (int z = -gridSize/2; z < gridSize/2; z++) {
      pushMatrix();
      
      float xPos = x * cellSize;
      float zPos = z * cellSize;
      float distance = dist(xPos, zPos, 0, 0);
      float y = sin(distance * 0.02 + theta) * waveHeight;
      
      translate(xPos, y, zPos);
      
      beginShape();
      texture(currentFrame);
      getEffectColor(distance);
      
      vertex(-cellSize/2, 0, -cellSize/2, 0, 0);
      vertex(cellSize/2, 0, -cellSize/2, currentFrame.width, 0);
      vertex(cellSize/2, 0, cellSize/2, currentFrame.width, currentFrame.height);
      vertex(-cellSize/2, 0, cellSize/2, 0, currentFrame.height);
      endShape(CLOSE);
      
      popMatrix();
    }
  }
  popMatrix();
}

//void drawParticleEffect() {
//  pushMatrix();
//  rotateX(PI/3);
  
//  int numParticles = 100;
//  float maxRadius = 300 * sizeMultiplier;
  
//  for (int i = 0; i < numParticles; i++) {
//    float angle = map(i, 0, numParticles, 0, TWO_PI);
//    float radius = maxRadius * noise(i * 0.1, frameCount * 0.01);
//    float x = cos(angle + theta) * radius;
//    float y = sin(angle + theta) * radius;
//    float z = sin(frameCount * 0.02 + i * 0.1) * 100;
    
//    pushMatrix();
//    translate(x, y, z);
    
//    float size = 50 * sizeMultiplier * noise(i * 0.2, frameCount * 0.02);
    
//    beginShape();
//    texture(currentFrame);
//    getEffectColor(i * (360/numParticles));
    
//    float tx = map(i, 0, numParticles, 0, currentFrame.width);
//    vertex(-size, -size, 0, tx, 0);
//    vertex(size, -size, 0, tx + currentFrame.width/numParticles, 0);
//    vertex(size, size, 0, tx + currentFrame.width/numParticles, currentFrame.height);
//    vertex(-size, size, 0, tx, currentFrame.height);
//    endShape(CLOSE);
    
//    popMatrix();
//  }
//  popMatrix();
//}

void drawSpiralTowerEffect() {
  pushMatrix();
  rotateX(PI/3);
  
  float towerHeight = 600 * sizeMultiplier;
  int spiralSteps = 30;
  float spiralRadius = 200 * sizeMultiplier;
  
  for (int i = 0; i < spiralSteps; i++) {
    float z = map(i, 0, spiralSteps-1, -towerHeight/2, towerHeight/2);
    float angle = i * TWO_PI/8 + theta;
    float radius = spiralRadius * (1 + sin(z * 0.01 + theta));
    
    pushMatrix();
    translate(cos(angle) * radius, sin(angle) * radius, z);
    rotateY(angle);
    
    float size = 50 * sizeMultiplier * (1 + sin(z * 0.02 + theta));
    
    beginShape();
    texture(currentFrame);
    getEffectColor(i * (360/spiralSteps));
    
    float tx = map(i, 0, spiralSteps, 0, currentFrame.width);
    vertex(-size, -size, 0, tx, 0);
    vertex(size, -size, 0, tx + currentFrame.width/spiralSteps, 0);
    vertex(size, size, 0, tx + currentFrame.width/spiralSteps, currentFrame.height);
    vertex(-size, size, 0, tx, currentFrame.height);
    endShape(CLOSE);
    
    popMatrix();
  }
  popMatrix();
}

void drawPolygonEffect() {
  pushMatrix();
  rotateX(PI/3);
  
  int rings = 10;
  float maxRadius = 300 * sizeMultiplier;
  
  for (int i = 0; i < rings; i++) {
    float radius = map(i, 0, rings-1, maxRadius * 0.2, maxRadius);
    float rotationOffset = theta * (i % 2 == 0 ? 1 : -1);
    
    pushMatrix();
    rotateZ(rotationOffset);
    
    getEffectColor(i * (360/rings));
    drawPolygon(radius, 
                map(i, 0, rings, 0, currentFrame.width),
                0,
                currentFrame.width/rings,
                currentFrame.height);
    
    popMatrix();
  }
  popMatrix();
} 
