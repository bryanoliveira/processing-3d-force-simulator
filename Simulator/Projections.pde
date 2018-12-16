// Projeções cavaleira, cabinet, isométrica e perspectiva com ponto de fuga em Z e com ponto de fuga em X e Z

float [][] adjustDevice(float [][] vertices, PVector limitMin, PVector limitMax) {
  // Ajusta posições dos objetos considerando o observador em X = 0, Y = 0
  
  float[][] tempVerties = new float[vertices.length][2];
  
  float H = limitMax.y - limitMin.y;
  float W = limitMax.x - limitMin.x;
  
  float m_ = min(width/W, height/H);
  float dxd2 = (width - (W * m_)) / 2;
  float dyd2 = (height - (H * m_)) / 2;
  
  for(int i=0; i < vertices.length; i++) {
    float y_ = limitMax.y - vertices[i][1];
    float x_ = vertices[i][0] - limitMin.x;
    
    float x__ = x_ * m_ + dxd2;
    float y__ = y_ * m_ + dyd2;
    
    tempVerties[i][0] = x__;
    tempVerties[i][1] = y__;
  }
  
  return tempVerties;
}

float[][] cavalier(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  
  int angle = 45;
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção cavaleira
    float[][] mCav = {
      {1, 0, 0, 0},
      {0, 1, 0, 0},
      {0, 0, 0, 0},
      {cos(angle * PI/180.0) * tempVertices[i][2], sin(angle * PI/180.0) * tempVertices[i][2], 0, 1},
    };
    tempVertices[i] = multMatrix(hPoint, mCav)[0];
  }
   
  // retorna a lista de pontos transformados
  return homogeneousToCartesian2D(tempVertices);
}

float[][] cabinet(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  int angle = 45;
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção cabinet
    float[][] mCav = {
      {1, 0, 0, 0},
      {0, 1, 0, 0},
      {0, 0, 0, 0},
      {cos(angle * PI/180.0) * tempVertices[i][2] / 2, sin(angle * PI/180) * tempVertices[i][2] / 2, 0, 1},
    };
    tempVertices[i] = multMatrix(hPoint, mCav)[0];
  }
  
  return homogeneousToCartesian2D(tempVertices);
}

float[][] isometric(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção isométrica
    float[][] iso = {
      {-cos(45 * PI/180), -sin(35.26 * PI/180)*sin(45 * PI/180), 0, 0},
      {0, cos(35.26 * PI/180), 0, 0},
      {-sin(45 * PI/180), sin(35.26 * PI/180)*cos(45 * PI/180), 0, 0},
      {0, 0, 0, 1},
    };
    
    tempVertices[i] = multMatrix(hPoint, iso)[0];

  }
  
  return homogeneousToCartesian2D(tempVertices);
}

float[][] perspectiveZ(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção perspectiva em z
    float[][] pers = {
      {1, 0, 0, 0},
      {0, 1, 0, 0},
      {0, 0, 0, 1.0/width},
      {0, 0, 0, 1},
    };
    
    tempVertices[i] = multMatrix(hPoint, pers)[0];
  }
  
  return homogeneousToCartesian2D(tempVertices);
}

float[][] perspectiveXZ(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção perspectiva em x e z
    float[][] pers = {
      {1, 0, 0, 1.0/width},
      {0, 1, 0, 0},
      {0, 0, 0, 1.0/width},
      {0, 0, 0, 1},
    };
    
    tempVertices[i] = multMatrix(hPoint, pers)[0];
  }
  
  return homogeneousToCartesian2D(tempVertices);
}
