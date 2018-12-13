// Polígonos e desenho

void DDALine(int xi, int yi, int xf, int yf) {  
  // Desenha na tela uma linha de Pi a Pf
  
  strokeWeight(2);
  
  int dx = xf - xi, dy = yf - yi, steps = abs(dx);
  
  if(abs(dx) < abs(dy)) 
    steps = abs(dy);  
    
  float incX = dx / (float) steps, incY = dy / (float) steps, x = xi, y = yi;
  
  for(int k = 0; k < steps; k++) {
    
    x += incX;
    y += incY;point((int)x, (int)y);
  }
  point((int)x, (int)y);
}

void fillPolygon(float[][] vertices, int[][] edges, color colour) {
  // Preenche um polígono dado com uma cor dada (lento)
  
  stroke(colour);
  strokeWeight(1);
  
  // tabela de análise
  float[][] tabela = new float[edges.length][4];
  for(int i = 0; i < edges.length; i++) {
    float [] min;
    float [] max;
    if(vertices[edges[i][0]][1] < vertices[edges[i][1]][1]) {
      min = vertices[edges[i][0]];
      max = vertices[edges[i][1]];
    } else {
      min = vertices[edges[i][1]];
      max = vertices[edges[i][0]];
    }
    tabela[i][0] = min[1]; // ymin
    tabela[i][1] = max[1]; // ymax
    tabela[i][2] = min[0]; // x de ymin
    tabela[i][3] = (max[1] - min[1] == 0 ? 0 : (max[0] - min[0]) / (float)(max[1] - min[1])); // 1/m
  }
  
  float Ymin = 0, Xmin = 0, Ymax = 0, Xmax = 0;
  // encontra os extremos da linha de varredura
  for(int i = 0; i < edges.length; i++) {
    if(tabela[i][0] < Ymin) {
      Ymin = (int) tabela[i][0];
    }
    if(tabela[i][1] > Ymax) {
      Ymax = (int) tabela[i][1];
    }
    if(vertices[i][0] < Xmin) {
      Xmin = vertices[i][0];
    }
    if(vertices[i][0] > Xmax) {
      Xmax = vertices[i][0];
    }
  }
  
  // pra cada linha de varredura
  // verifica os X que intersectam
  for(int i = (int)Ymin; i < Ymax; i++) {
    int [] intersec = {}; // x que intersecta
    int [][] yIntersec = new int[edges.length][2]; // max/min
    int yIntersecIndex = 0;
    
    // pra cada vértice
    for(int j = 0; j < edges.length; j++) {
      // se i > ymin e i < ymax (lado corta linha de varredura)
      // e ymin != ymax (se não é um lado horizontal)
      if(i >= tabela[j][0] && i <= tabela[j][1] && tabela[j][0] != tabela[j][1]) {
        int x = (int) (tabela[j][3] * (i - tabela[j][0]) + tabela[j][2]);

        // se é o vértice de conexão entre dois lados que cortam a linha de varredura, adiciona só um
        // se os dois pontos sao os maximos ou os minimos, adiciona os dois
        int indexIntersec = find(intersec, x);
        // se tem uma interseccao E o y dela eh o max e o i eh o min OU o y dela eh o min e o i eh o max, nao adiciona
        if(indexIntersec >= 0 && ((yIntersec[indexIntersec][0] == i && i == tabela[j][0]) || (yIntersec[indexIntersec][1] == i && i == tabela[j][1]))) {
          continue;
        }
        
        intersec = append(intersec, x);
        yIntersec[yIntersecIndex][0] = (int) tabela[j][1];
        yIntersec[yIntersecIndex++][1] = (int) tabela[j][0];
      }
    }
    
    // prepara para varrer essa linha
    intersec = sort(intersec);

    for(int j = 0; j < intersec.length; j += 2) {
      DDALine(intersec[j], i, intersec[j + 1] - 3, i); // deixa um espaço na linha sem desenhar pra borda do objeto ser exibida
    }
  }
}

void scanShape(float[][] vertices, color colour) {
  // Recebe vértices e preenche o polígono associado com vértices ligados sequencialmente (usa scanline e é lento)
  
  int[][] edges = new int[vertices.length][2];  
  
  for(int i = 0; i < vertices.length; i++) {
    edges[i][0] = i;
    edges[i][1] = (i + 1) % vertices.length;
  }
  
  fillPolygon(vertices, edges, colour);
}
