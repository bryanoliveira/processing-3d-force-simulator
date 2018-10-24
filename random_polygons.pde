/**
 * Aluno: Bryan Lincoln
 */

import java.util.Map;

int maxSize = 300;
int maxVertices = 12;

void setup() {
  size(640, 360);
  background(255);
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
  
  desenhaPoligono(pontos, linhas, contorno, true, preenchimento); // ((int)random(2)) == 0
}

void draw() {  
  
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
    varredura(P, L);
  }
}

void mouseClicked() {
  color preenchimento = color((int)random(255), (int)random(255), (int)random(255));
  // semente(preenchimento, color(255), new PVector(pmouseX, pmouseY));
}

// não funciona - muita recursão
void semente(color preenchimento, color fundo, PVector seed) {
  color cursor = get(int(seed.x), int(seed.y));
  if(cursor == fundo) {
    stroke(preenchimento);
    point(seed.x, seed.y);
    semente(preenchimento, fundo, new PVector(seed.x + 1, seed.y));
    semente(preenchimento, fundo, new PVector(seed.x - 1, seed.y));
    semente(preenchimento, fundo, new PVector(seed.x, seed.y + 1));
    semente(preenchimento, fundo, new PVector(seed.x, seed.y - 1));
  }
}

void varredura(int[][] P, int[][] L) {
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
  
  // pra cada linha de varredura
  // verifica os X que intersectam
  for(int i = Ymin; i < Ymax; i++) {
    println();
    int [] intersec = {}; // x que intersecta
    int [][] yIntersec = new int[L.length][2]; // max/min
    int yIntersecIndex = 0;
    
    // pra cada vértice
    for(int j = 0; j < L.length; j++) {
      // se i > ymin e i < ymax (lado corta linha de varredura)
      // e ymin != ymax (se não é um lado horizontal)
      if(i >= tabela[j][0] && i <= tabela[j][1] && tabela[j][0] != tabela[j][1]) {
        int x = (int) (tabela[j][3] * (i - tabela[j][0]) + tabela[j][2]);

        // se é o vértice de conexão entre dois lados que cortam a linha de varredura, adiciona só um
        // se os dois pontos sao os maximos ou os minimos, adiciona os dois
        int indexIntersec = find(intersec, x);
        // se tem uma interseccao E o y dela eh o max e o i eh o min OU o y dela eh o min e o i eh o max, nao adiciona
        if(indexIntersec >= 0 && ((yIntersec[indexIntersec][0] == i && i == tabela[j][0]) || (yIntersec[indexIntersec][1] == i && i == tabela[j][1]))) {
          print("pulei ");
          continue;
        }
        
        
        print("ponto ");
        intersec = append(intersec, x);
        yIntersec[yIntersecIndex][0] = (int) tabela[j][1];
        yIntersec[yIntersecIndex++][1] = (int) tabela[j][0];
      }
    }
    
    // prepara para varrer essa linha
    intersec = sort(intersec);
    for(int h = 0; h < intersec.length; h++) {
      print(intersec[h] + ", ");
    }
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

int find(int [] vector, int value) {
  int index = -1;
  
  for(int i = 0; i < vector.length; i++) {
    if(vector[i] == value) {
      index = i;
      break;
    }
  }
  
  return index;
}
