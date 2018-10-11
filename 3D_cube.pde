/**
 * Aluno: Bryan Lincoln
 */

void setup() {
  size(1280, 720);
  World.init(width / 2, height / 2);
}

void draw() {
  background(255);
 
  // pega os keystrokes que não são codificados
  if(keyPressed) {
    if(key == CODED) {
      switch(keyCode) {
        case 112:
          showHelp();
          break;
      }
    }
    else {
      switch(key) {
        // translação
        case 'w':
          World.translateLast(0, 1.05, 0);
          break;
        case 's':
          World.translateLast(0, -1.05, 0);
          break;
        case 'a':
          World.translateLast(-1.05, 0, 0);
          break;
        case 'd':
          World.translateLast(1.05, 0, 0);
          break;
        case 'q':
          World.translateLast(0, 0, -1.05);
          break;
        case 'e':
          World.translateLast(0, 0, 1.05);
          break;
          
        // rotação
        case 'j':
          World.rotateLast(0, 0.05, 0);
          break;
        case 'l':
          World.rotateLast(0, -0.05, 0);
          break;
        case 'i':
          World.rotateLast(0.05, 0, 0);
          break;
        case 'k':
          World.rotateLast(-0.05, 0, 0);
          break;
        case 'o':
          World.rotateLast(0, 0, -0.05);
          break;
        case 'u':
          World.rotateLast(0, 0, 0.05);
          break;
          
        // escala
        case 't':
          World.scaleLast(0, 0.05, 0);
          break;
        case 'g':
          World.scaleLast(0, -0.05, 0);
          break;
        case 'f':
          World.scaleLast(0.05, 0, 0);
          break;
        case 'h':
          World.scaleLast(-0.05, 0, 0);
          break;
        case 'r':
          World.scaleLast(0, 0, 0.05);
          break;
        case 'y':
          World.scaleLast(0, 0, -0.05);
          break;
      }
    }
  }
  
  World.render();
}

// pega só uma vez
void keyPressed() {
  if(key != CODED) {
    switch(key) {
      case 'n':
        World.create(new Object());
        break;
      case ',':
        World.cloneLast(new Object());
        break;
      case '.':
        World.destroyLast();
        break;
    }
  }
}

void showHelp() {
  int offset = 1;
  textSize(16);
  fill(0);
  text("n: Instanciar cubo", 10, 10 + 16 * (offset++));
  text("w: Move último objeto criado pra cima", 10, 10 + 16 * (offset++));
  text("s: Move para baixo", 10, 10 + 16 * (offset++));
  text("a: Move para a direita", 10, 10 + 16 * (offset++));
  text("d: Move para a esquerda", 10, 10 + 16 * (offset++));
  text("e: Move para frente", 10, 10 + 16 * (offset++));
  text("q: Move para trás", 10, 10 + 16 * (offset++));
  text("t: Reescala para mais em y", 10, 10 + 16 * (offset++));
  text("g: Reescala para menos em y", 10, 10 + 16 * (offset++));
  text("f: Reescala para mais em x", 10, 10 + 16 * (offset++));
  text("h: Reescala para menos em x", 10, 10 + 16 * (offset++));
  text("r: Reescala para mais em z", 10, 10 + 16 * (offset++));
  text("y: Reescala para menos em z", 10, 10 + 16 * (offset++));
  text("i: Rotaciona para cima", 10, 10 + 16 * (offset++));
  text("k: Rotaciona para baixo", 10, 10 + 16 * (offset++));
  text("j: Rotaciona para esquerda", 10, 10 + 16 * (offset++));
  text("l: Rotaciona para direita", 10, 10 + 16 * (offset++));
  text("o: Rotaciona horário em z", 10, 10 + 16 * (offset++));
  text("u: Rotaciona anti-horário z", 10, 10 + 16 * (offset++));
  text(",: Clona o último objeto", 10, 10 + 16 * (offset++));
  text(".: Destrói o último objeto", 10, 10 + 16 * (offset++));
}

static class World {
  static int maxX, maxY, maxZ, minX, minY, minZ;
  static int ref_x, ref_y;
  static ArrayList<Object> objects = new ArrayList<Object>();
  
  static void init(int center_x, int center_y) {
    ref_x = center_x;
    ref_y = center_y;
    maxX = center_x * 2;
    maxY = center_y * 2;
    maxZ = 10;
    minX = minY = minZ = 0;
  }
  
  static void create(Object object) {
    float[][] vertices = {
      {-10, -10, -10},
      {-10, -10, 10},
      {-10, 10, -10},
      {-10, 10, 10},
      {10, -10, -10},
      {10, -10, 10},
      {10, 10, -10},
      {10, 10, 10}
    };
    int[][] arestas = {
      {0, 1},
      {0, 2},
      {0, 4},
      {1, 3},
      {1, 5},
      {2, 3},
      {2, 6},
      {3, 7},
      {4, 5},
      {4, 6},
      {5, 7},
      {6, 7}
    };
    object.init(vertices, arestas, new PVector(ref_x, ref_y));
    objects.add(object);
  }
  
  static void cloneLast(Object newObject) {
    if(objects.size() == 0) 
      return;

    Object last = objects.get(objects.size() - 1);
    float[][] vertices = new float[last.vertices.length][last.vertices[0].length];
    int[][] arestas = new int[last.arestas.length][last.arestas[0].length];
    arrayCopy(last.vertices, vertices);
    arrayCopy(last.arestas, arestas);
    
    newObject.init(vertices, arestas, last.position.copy(), last.rotation.copy(), last.scale.copy());
    objects.add(newObject);
  }
  
  static void destroyLast() {
    if(objects.size() == 0) 
      return;
      
    objects.remove(objects.size() - 1);
  }
  
  static void render() {
    // desenha os objetos na tela
    for(int i = 0; i < objects.size(); i++) {
      Object object = objects.get(i);
      object.show();
    }
  }
  
  static void translateLast(float x, float y, float z) {
    if(objects.size() == 0) 
      return;
      
    Object last = objects.get(objects.size() - 1);
    last.translate(new PVector(x, y, z));
  }
  static void rotateLast(float x, float y, float z) {
    if(objects.size() == 0) 
      return;
      
    Object last = objects.get(objects.size() - 1);
    last.rotate(new PVector(x, y, z));
  }
  static void scaleLast(float x, float y, float z) {
    if(objects.size() == 0) 
      return;
      
    Object last = objects.get(objects.size() - 1);
    last.rescale(new PVector(x, y, z));
  }
}

class Object {
  // definições imutáveis do objeto
  float[][] vertices;
  int[][] arestas;
  
  // vetores mutáveis de estado
  PVector position;
  PVector rotation;
  PVector scale;
  
  void init(float[][] vertices, int[][] arestas) {
    this.position = new PVector(0, 0, 0);
    this.rotation = new PVector(0, 0, 0);
    this.scale = new PVector(1, 1, 1);
    
    this.vertices = vertices;
    this.arestas = arestas;
  }
  void init(float[][] vertices, int[][] arestas, PVector position) {
    init(vertices, arestas);
    this.position = position;
  }
  void init(float[][] vertices, int[][] arestas, PVector position, PVector rotation, PVector scale) {
    init(vertices, arestas, position);
    this.rotation = rotation;
    this.scale = scale;
  }
  
  void translate(PVector delta) {
    position.add(delta);
  }
  void rotate(PVector delta) {
    rotation.add(delta);
  }
  
  void rescale(PVector delta) {
    scale.add(delta);
  }
  
  void show() {    
    float[][] tempVertices = new float[vertices.length][3];
    
    // rotaciona
    for(int i = 0; i < tempVertices.length; i++){
      // em x
      tempVertices[i][1] = vertices[i][1] * cos(rotation.x) - vertices[i][2] * (sin(rotation.x)); // y
      tempVertices[i][2] = vertices[i][1] * sin(rotation.x) + vertices[i][2] * (cos(rotation.x)); // z
      float y = tempVertices[i][1];
      float z = tempVertices[i][2];
      
      // em y
      tempVertices[i][0] = vertices[i][0] * cos(rotation.y) + z * (sin(rotation.y)); // x
      tempVertices[i][2] = -vertices[i][0] * sin(rotation.y) + z * (cos(rotation.y)); // z
      float x = tempVertices[i][0];
      
      // em z
      tempVertices[i][0] = x * cos(rotation.z) - y * (sin(rotation.z)); // x
      tempVertices[i][1] = x * sin(rotation.z) + y * (cos(rotation.z)); // y
    }
    
    // escala
    for(int i = 0; i < tempVertices.length; i++) {
      for(int j = 0; j < tempVertices[i].length; j++) {
        tempVertices[i][j] *= scale.array()[j];
      }
    }
    
    // translada
    for(int i = 0; i < tempVertices.length; i++) {
      for(int j = 0; j < tempVertices[i].length; j++) {
        tempVertices[i][j] += position.array()[j];
      }
    }
    
    // perspectiva cavalheira 45
    
    int w = World.maxX - World.minX, h = World.maxY - World.minY;
    float m = min(width/w, height/h);
    float dxdz = (width - w*m) / 2.0, dydz = (height - h*m) / 2.0;
    float r2d2 = cos((3 * PI) / 4);
    
    for(int i = 0; i < tempVertices.length; i++) {
      float x = tempVertices[i][0], y = tempVertices[i][1], z = tempVertices[i][2];
      
      float x1 = x - World.minX, y1 = World.maxY - y, z1 = World.maxZ - z;
      
      float x2 = x1 * m + dxdz, y2 = y1 * m + dydz, z2 = z1 * m;
      
      float x3 = x2 + z2 * r2d2;
      float y3 = y2 - z2 * r2d2;
      
      tempVertices[i][0] = x3;
      tempVertices[i][1] = y3;
    }
    
    stroke(0);
  
    // desenha as linhas do polígono
    for(int i = 0; i < arestas.length; i++) {
      int p1 = arestas[i][0], 
          p2 = arestas[i][1],
          xi = int(tempVertices[p1][0]), 
          yi = int(tempVertices[p1][1]), 
          xf = int(tempVertices[p2][0]),
          yf = int(tempVertices[p2][1]);
          
      linhaDDA(xi, yi, xf, yf);
    }
  }
  
  void linhaDDA(int xi, int yi, int xf, int yf) {
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
}
