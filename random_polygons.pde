/**
 * Author: Bryan Lincoln
 * Created at: September 30th, 2018
 */

int maxSize = 300;
int maxVertices = 12;

void setup() {
  size(640, 360);
  background(255);
}

void draw() {  
  // escolhe aleatoriamente uma cor RGB para o objeto a ser desenhado e de seu contorno
  color preenchimento = color((int)random(255), (int)random(255), (int)random(255));
  color contorno = color((int)random(255), (int)random(255), (int)random(255));
 
  int qtd_vertices = (int) random(3, 8);
  int [][] pontos = new int[qtd_vertices][2];
  for(int i = 0; i < qtd_vertices; i++) {
    pontos[i][0] = (int) random(width);
    pontos[i][1] = (int) random(height);
  }
  
  int [][] linhas = new int[qtd_vertices][2];
  for(int i = 0; i < qtd_vertices; i++) {
    linhas[i][0] = i;
    linhas[i][1] = (i + 1) % qtd_vertices;
  }
  
  desenhaPoligono(pontos, linhas, contorno, ((int)random(2)) == 0, preenchimento);
}

void linhaDDA (int xi, int yi, int xf, int yf) {
  int dx = xf - xi, dy = yf - yi, steps = abs(dx);
  
  if(abs(dx) < abs(dy)) 
    steps = abs(dy);  
    
  float incX = dx / (float) steps, incY = dy / (float) steps, x = xi, y = yi;
  
  point(x, y);
  for(int k = 0; k < steps; k++) {
    x += incX;
    y += incY;
    point((int)x, (int)y);
  }
}

void desenhaPoligono(int[][] P, int[][] L, color cor_linha, boolean preenche, color cor_preenchimento) {
  stroke(cor_linha);
  
  // desenha as linhas do polígono
  for(int i = 0; i < L.length; i++) {
    int p1 = L[i][0], 
        p2 = L[i][1],
        xi = P[p1][0], 
        yi = P[p1][1], 
        xf = P[p2][0],
        yf = P[p2][1];
        
    linhaDDA(xi, yi, xf, yf);
  }
  
  stroke(cor_preenchimento);
  // preenche o polígono
  if(preenche) {
    // tabela de análise
    float[][] tabela = new float[L.length][4];
    for(int i = 0; i < L.length; i++) {
      int [] min;
      int [] max;
      if(P[L[i][0]][1] < P[L[i][1]][1]) {
        min = P[L[i][0]];
        max = P[L[i][1]];
      } else {
        min = P[L[i][1]];
        max = P[L[i][0]];
      }
      tabela[i][0] = min[1]; // ymin
      tabela[i][1] = max[1]; // ymax
      tabela[i][2] = min[0]; // x de ymin
      tabela[i][3] = (max[1] - min[1] == 0 ? 0 : (max[0] - min[0]) / (float)(max[1] - min[1])); // 1/m
    }
    
    int Ymin = 0, Xmin = 0, Ymax = 0, Xmax = 0;
    // encontra os extremos da linha de varredura
    for(int i = 0; i < L.length; i++) {
      if(tabela[i][0] < Ymin) {
        Ymin = (int) tabela[i][0];
      }
      if(tabela[i][1] > Ymax) {
        Ymax = (int) tabela[i][1];
      }
      if(P[i][0] < Xmin) {
        Xmin = P[i][0];
      }
      if(P[i][0] > Xmax) {
        Xmax = P[i][0];
      }
    }
    
    // TODO verificar caso em que linhas se tocam no meio da figura
    
    // pra cada linha de varredura
    for(int i = Ymin; i < Ymax; i++) {
      // verifica os X que intersectam
      int [] intersec = {};
      for(int j = 0; j < L.length; j++) {
        // se o lado tem um y que corta minha linha de varredura
        // se i > ymin e i < ymax e ymin != ymax
        if(i > tabela[j][0] && i < tabela[j][1] && tabela[j][0] != tabela[j][1]) {
          int x = (int) (tabela[j][3] * (i - tabela[j][0]) + tabela[j][2]);
          intersec = append(intersec, x);
        }
      }
      intersec = sort(intersec);
      boolean paint = false;
      int idx = 0;
      for(int j = Xmin - 1; j < Xmax; j++) {
        if(intersec.length == 0)
          continue;
        if(intersec[idx] == j && !(idx < intersec.length - 1 && intersec[idx] == intersec[idx + 1])) {
          paint = !paint;
          if(idx < intersec.length - 1)
            idx++;
        }
        if(paint) {
          point(j, i);
        }
      }
    }
  }
}
