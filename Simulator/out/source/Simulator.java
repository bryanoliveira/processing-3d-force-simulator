import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Simulator extends PApplet {

 

Screen screen;
World world;
PVector[] observer; // observador/câmera
float deltaTime = 0;
float lastTime = 0;

public void setup() {
  //size(1280, 720);
  
  strokeWeight(2);
  
  
  // um observador pra cada projeção
  // TODO isso pode ser tunado melhor
  observer = new PVector[5]; 
  observer[0] = new PVector(700, 700, -1000);
  observer[1] = new PVector(350, 350, -1000);
  observer[2] = new PVector(1000, 1000, -1000);
  observer[3] = new PVector(0, 0, -10000);
  observer[4] = new PVector(0, 0, -10000);
  
  world = new World();
  screen = new Screen();

  lastTime = millis();
  
  load("figure.1.dat");
}


public void draw() {
  deltaTime = (millis() - lastTime) / 1000;
  lastTime = millis();

  background(77);
  
  if(helpPressed) screen.showHelp();
  
  // pega inputs
  keyRepeat();
  
  // calcula e renderiza o mundo
  world.step();
  world.render();
  
  // exibe interface
  screen.showFPS();
  screen.showProjection(world.projection);
  screen.addLine(world.name, 0, 0);
  screen.addLine("\"" + world.selectedName() + "\" selected", 1, 2);
  screen.addLine("Position:  " + world.selectedPosition() + "\nRotation: " + world.selectedRotation() + "\nScale:      " + world.selectedScale(), 2, 2);
}


public void load(String fileName) {
  // Carrega dados do mundo e objetos de um arquivo
  
  String[] fileLines = loadStrings(fileName);
  int cursorPosition = 0;
  
  String figureName = fileLines[cursorPosition++].substring(2);
  
  // lê as dimensões do dispositivo
  String[] worldDimensions = split(fileLines[cursorPosition++], " ");
  
  int numObjects = Integer.parseInt(fileLines[cursorPosition++]);
  
  // lê os objetos
  for(int i = 0; i < numObjects; i++) {
    Object object = new Object(fileLines[cursorPosition++].substring(2));
    
    String[] objectDimensions = split(fileLines[cursorPosition++], " ");
    
    int numPoints = Integer.parseInt(objectDimensions[0]);
    int numLines = Integer.parseInt(objectDimensions[1]);
    int numFaces = Integer.parseInt(objectDimensions[2]);
    
    float[][] vertices = new float[numPoints][3];
    int[][] edges = new int[numLines][2];
    Face[] faces = new Face[numFaces];
    
    // lê os vertices
    for(int j = 0; j < numPoints; j++) {
      String[] point = split(fileLines[cursorPosition++], " ");
      for(int k = 0; k < 3; k++) {
        vertices[j][k] = Float.parseFloat(point[k]);
      }
    }
    
    // lê as linhas
    for(int j = 0; j < numLines; j++) {
      String[] line = split(fileLines[cursorPosition++], " ");
      for(int k = 0; k < 2; k++) {
        edges[j][k] = Integer.parseInt(line[k]) - 1;
      }
    }
    
    // lê as faces
    for(int j = 0; j < numFaces; j++) {
      String[] face = split(fileLines[cursorPosition++], " ");
      
      int[] facePoints = new int[Integer.parseInt(face[0])];
      
      for(int k = 1; k <= facePoints.length; k++) {
        facePoints[k - 1] = Integer.parseInt(face[k]) - 1;
      }
      
      int faceColorR = PApplet.parseInt(Float.parseFloat(face[facePoints.length + 1]) * 255);
      int faceColorG = PApplet.parseInt(Float.parseFloat(face[facePoints.length + 2]) * 255);
      int faceColorB = PApplet.parseInt(Float.parseFloat(face[facePoints.length + 3]) * 255);
      int colour = color(faceColorR, faceColorG, faceColorB);
       
      faces[j] = new Face(facePoints, colour);
    }
    
    // lê a rotação
    String rotationS[] = split(fileLines[cursorPosition++], " ");
    PVector rotation = new PVector(Float.parseFloat(rotationS[0]), Float.parseFloat(rotationS[1]), Float.parseFloat(rotationS[2]));
    
    // lê a escala
    String scaleS[] = split(fileLines[cursorPosition++], " ");
    PVector scale = new PVector(Float.parseFloat(scaleS[0]), Float.parseFloat(scaleS[1]), Float.parseFloat(scaleS[2]));
    
    // lê a translação
    String translationS[] = split(fileLines[cursorPosition++], " ");
    PVector translation = new PVector(Float.parseFloat(translationS[0]), Float.parseFloat(translationS[1]), Float.parseFloat(translationS[2]));
    
    // lê os atributos da física
    Physics physics = (Physics) object.getComponent(new Physics(null));
    if(physics != null) {
      physics.useGravity = (1 == Integer.parseInt(fileLines[cursorPosition++]));
      physics.mass = Float.parseFloat(fileLines[cursorPosition++]);
    }

    // inicializa o objeto
    object.init(vertices, edges, translation, rotation, scale, faces);
    // adiciona o objeto ao mundo
    world.create(object);
  }

  // inicializa o mundo depois que todos os objetos foram configurados para que a física funcione corretamente
  world.init(figureName, new PVector(Integer.parseInt(worldDimensions[0]), Integer.parseInt(worldDimensions[2])), new PVector(Integer.parseInt(worldDimensions[1]), Integer.parseInt(worldDimensions[3])));
}
public class Collider implements ComponentInterface {
    Object object;
    Physics physics;

    float radius; // raio de intersecção em que o mundo considera colisão global

    ArrayList<Object> nextToCollide = new ArrayList<Object>();
    ArrayList<Object> collisions = new ArrayList<Object>();

    public Collider(Object object) {
        this.object = object;
    }

    public void init() {
        this.physics = (Physics) object.getComponent(new Physics(null));

        // calcula o raio de colisão global do objeto pegando o valor mínimo e máximo dos vértices em X, Y e Z
        float min, max;

        min = min(object.vertices[0]);
        max = max(object.vertices[0]);

        for(int i = 1; i < object.vertices.length; i++) {
            float tempMin, tempMax;
            tempMin = min(object.vertices[i]);
            tempMax = max(object.vertices[i]);
            if(tempMin < min) min = tempMin;
            if(tempMax > max) max = tempMax;
        }

        this.radius = max - min;
    }

    public void run() {
        // recebe objetos identificados pelo mundo como colisão global e calcula pontos de colisão local
        // DEVE SER EXECUTADO APÓS A FÍSICA DO MUNDO

        // reseta as colisões a cada timestep
        collisions = new ArrayList<Object>(nextToCollide);
        nextToCollide.clear();

        // atualiza as propriedades físicas dele
    }

    public void setCollision(Object with, PVector origin) {
        // recebe um objeto que entrou em colisão e o ponto de origem da força de repulsão
        nextToCollide.add(with);

        // physics.acceleration.add(object.position.x - origin.x, object.position.y - origin.y, object.position.z - origin.z);
    }
}
public interface ComponentInterface {
    Object object = null;

    public void init(); // deve ser chamado após o init do objeto

    public void run(); // deve ser chamado durante a execução do step() do mundo
}
public class GlobalPhysics {

    private class Limit {
        Object object;
        float start, end;

        public Limit(Object object, float start, float end) {
            this.object = object;
            this.start = start;
            this.end = end;
        }
    }

    private class LimitComparator implements Comparator<Limit> {
        // Compara limites de acordo com o start na reta cartesiana
        
        public int compare(Limit l1, Limit l2) {
            if(l1.start > l2.start) {
                return 1;
            }
            return -1;
        }
    }

    public void init() {
    }

    public void run() {
        // calcula a física do mundo

        localCollisions(globalCollisions());
    }

    private ArrayList<Limit[]> globalCollisions() {
        // busca intersecções globais entre os objetos em X, Y e Z (nessa ordem, mas pode ser otimizado usando a variância da distribuição)
        // TODO esse método pode ser melhorado, o procedimento de intersecção é O(n²)

        // encontra os limites dos objetos na reta cartesiana
        ArrayList<Limit> limitsX = new ArrayList<Limit>();
        ArrayList<Limit> limitsY = new ArrayList<Limit>();
        ArrayList<Limit> limitsZ = new ArrayList<Limit>();
        for(int i = 0; i < world.objects.size(); i++) {
            Object object = world.objects.get(i);
            Collider objectCollider = (Collider) object.getComponent(new Collider(null));
            limitsX.add(new Limit(object, object.position.x - objectCollider.radius, object.position.x + objectCollider.radius));
            limitsY.add(new Limit(object, object.position.y - objectCollider.radius, object.position.y + objectCollider.radius));
            limitsZ.add(new Limit(object, object.position.z - objectCollider.radius, object.position.z + objectCollider.radius));
        }

        // ordena as listas para comparação
        Collections.sort(limitsX, new LimitComparator());
        Collections.sort(limitsY, new LimitComparator());
        Collections.sort(limitsZ, new LimitComparator());

        // armazena as colisões 2 a 2
        ArrayList<Limit[]> collisionsX = new ArrayList<Limit[]>();
        ArrayList<Limit[]> collisionsY = new ArrayList<Limit[]>();
        ArrayList<Limit[]> collisionsZ = new ArrayList<Limit[]>();

        // analiza a lista de colisão em X
        for(int i = 0; i < limitsX.size() - 1; i++) {
            Limit l1 = limitsX.get(i);
 
            for(int j = i + 1; j < limitsX.size(); j++) {
                Limit l2 = limitsX.get(i + 1);
            
                if(l1.end >= l2.start) { // potencial colisão
                    Limit[] collision = {l1, l2};
                    collisionsX.add(collision);
                }
            }
        }

        // analiza a lista de colisão em Y
        for(int i = 0; i < limitsY.size() - 1; i++) {
            Limit l1 = limitsY.get(i);

            for(int j = i + 1; j < limitsY.size(); j++) {
                Limit l2 = limitsY.get(i + 1);
            
                if(l1.end >= l2.start) { // potencial colisão
                    Limit[] collision = {l1, l2};
                    collisionsY.add(collision);
                }
            }
        }

        // analiza a lista de colisão em Z
        for(int i = 0; i < limitsZ.size() - 1; i++) {
            Limit l1 = limitsZ.get(i);

            for(int j = i + 1; j < limitsZ.size(); j++) {
                Limit l2 = limitsZ.get(i + 1);
            
                if(l1.end >= l2.start) { // potencial colisão
                    Limit[] collision = {l1, l2};
                    collisionsZ.add(collision);
                }
            }
        }

        collisionsX = intersection(collisionsX, collisionsY);
        collisionsX = intersection(collisionsX, collisionsZ);
        return collisionsX;
    }

    private void localCollisions(ArrayList<Limit[]> potentialCollisions) {
        // verifica se as potenciais colisões são realmente colisões e informa os envolvidos
        /* Pra cada face do primeiro polígono, verifica se o produto vetorial entre sua normal e 
         * cada vértice do segundo polígono é maior que zero. Se sim, não há colisão.
         * Adicione todos os vértices que geram um produto <= 0 em um vetor auxiliar, removendo os que
         * eventualmente geram um valor > 0 com alguma face. 
         * Os pontos que sobrarem representam a magnitude da colisão.
         */

        // para cada potencial colisão
        for(int i = 0; i < potentialCollisions.size(); i++) {
            Limit[] collision = potentialCollisions.get(i);
            Object obj1 = collision[0].object;
            Object obj2 = collision[1].object;

            // aplica transformações nos vértices
            obj1.computedVertices = obj1.getVertices(); 
            obj2.computedVertices = obj2.getVertices(); 

            // calcula a normal das faces
            obj1.getFaces();
            obj2.getFaces();

            // pega os vertices de intersecção entre os objetos

            ArrayList<float[]> intersectionPoints = new ArrayList<float[]>();

            // começa com os pontos do segundo objeto que estão dentro do primeiro
            // pra cada vértice do segundo objeto
            for(int j = 0; j < obj2.vertices.length; j++) {
                boolean outside = false;
                // pra cada face do primeiro objeto
                for(int k = 0; k < obj1.faces.length; k++) {
                    PVector P2 = new PVector(obj1.computedVertices[obj1.faces[k].vertices[1]][0],
                                             obj1.computedVertices[obj1.faces[k].vertices[1]][1],
                                             obj1.computedVertices[obj1.faces[k].vertices[1]][2]);

                    // produto vetorial entre a normal da face k e a diferença entre o vértice j e um vértice da face
                    float prod = obj1.faces[k].normal.x * (obj2.computedVertices[j][0] - P2.x) +
                                 obj1.faces[k].normal.y * (obj2.computedVertices[j][1] - P2.y) +
                                 obj1.faces[k].normal.z * (obj2.computedVertices[j][2] - P2.z);

                    if(prod > 0) outside = true;
                }

                if(!outside) {
                    intersectionPoints.add(obj2.computedVertices[j]);
                }
            }

            // pega os pontos do primeiro objeto que estão dentro do segundo
            // pra cada vértice do primeiro objeto
            for(int j = 0; j < obj1.vertices.length; j++) {
                boolean outside = false;
                // pra cada face do segundo objeto
                for(int k = 0; k < obj2.faces.length; k++) {
                    PVector P2 = new PVector(obj2.computedVertices[obj2.faces[k].vertices[1]][0], 
                                             obj2.computedVertices[obj2.faces[k].vertices[1]][1], 
                                             obj2.computedVertices[obj2.faces[k].vertices[1]][2]);

                    // produto vetorial entre a normal da face k e a diferença entre o vértice j e um vértice da face
                    float prod = obj2.faces[k].normal.x * (obj1.computedVertices[j][0] - P2.x) +
                                 obj2.faces[k].normal.y * (obj1.computedVertices[j][1] - P2.y) +
                                 obj2.faces[k].normal.z * (obj1.computedVertices[j][2] - P2.z);

                    if(prod > 0) outside = true;
                }

                if(!outside) {
                    intersectionPoints.add(obj1.computedVertices[j]);
                }
            }

            // se houve intersecção, houve colisão
            if(intersectionPoints.size() > 0) {
                // faz a média entre os pontos de intersecção - esse vai ser o ponto de origem das forças de reação
                PVector collisionOrigin = new PVector(0, 0, 0);
                for(int j = 0; j < intersectionPoints.size(); j++) {
                    collisionOrigin.x += intersectionPoints.get(i)[0];
                    collisionOrigin.y += intersectionPoints.get(i)[1];
                    collisionOrigin.z += intersectionPoints.get(i)[2];
                }
                collisionOrigin.div(intersectionPoints.size());

                // avisa os objetos da colisão
                ((Collider) obj1.getComponent(new Collider(null))).setCollision(obj2, collisionOrigin);
                ((Collider) obj2.getComponent(new Collider(null))).setCollision(obj1, collisionOrigin);
            }
        }
    }

    private ArrayList<Limit[]> intersection(ArrayList<Limit[]> l1, ArrayList<Limit[]> l2) {
        ArrayList<Limit[]> list = new ArrayList<Limit[]>();

        for (Limit[] limit : l1) {
            for(Limit[] limit2 : l2) {
                if((limit[0].object == limit2[0].object && limit[1].object == limit2[1].object) || 
                   (limit[0].object == limit2[1].object && limit[1].object == limit2[0].object)) {
                    list.add(limit);
                }
            }
        }

        return list;
    }
}
boolean shift = false;
boolean helpPressed = false;

public void keyRepeat() {
  // Pega teclas pressionadas continuamente
  
  if(keyPressed) {
    if (key != CODED) {
      switch(key) {
        // translação
        case 'w':
          world.translateSelected(0, 0.1f, 0);
          break;
        case 's':
          world.translateSelected(0, -0.1f, 0);
          break;
        case 'a':
          world.translateSelected(-0.1f, 0, 0);
          break;
        case 'd':
          world.translateSelected(0.1f, 0, 0);
          break;
        case 'q':
          world.translateSelected(0, 0, -0.1f);
          break;
        case 'e':
          world.translateSelected(0, 0, 0.1f);
          break;
          
        // rotação
        case 'j':
          world.rotateSelected(0, 0.05f, 0);
          break;
        case 'l':
          world.rotateSelected(0, -0.05f, 0);
          break;
        case 'i':
          world.rotateSelected(-0.05f, 0, 0);
          break;
        case 'k':
          world.rotateSelected(0.05f, 0, 0);
          break;
        case 'o':
          world.rotateSelected(0, 0, 0.05f);
          break;
        case 'u':
          world.rotateSelected(0, 0, -0.05f);
          break;
          
        // escala
        case 't':
          world.scaleSelected(0, 0.05f, 0);
          break;
        case 'g':
          world.scaleSelected(0, -0.05f, 0);
          break;
        case 'f':
          world.scaleSelected(0.05f, 0, 0);
          break;
        case 'h':
          world.scaleSelected(-0.05f, 0, 0);
          break;
        case 'r':
          world.scaleSelected(0, 0, 0.05f);
          break;
        case 'y':
          world.scaleSelected(0, 0, -0.05f);
          break;
      }
    }
  }
}

public void keyPressed() {
  // Funções chamadas apenas uma vez quando tecla é pressionada
  
  if(key != CODED) {
    switch(key) {
      case TAB:
        world.circleSelect(shift? -1 : 1);
        break;
      case ',':
        world.cloneSelected();
        break;
      case '.':
        world.destroySelected();
        break;
      case 'p':
        world.circleProjection(1);
        break;
      case 'P':
        world.circleProjection(-1);
        break;
      case 'b':
        world.useScanLine = !world.useScanLine;
    }
  } else if(keyCode == SHIFT) {
    shift = true;
  } else if(keyCode == 112) {
    helpPressed = !helpPressed;
  }
  
}

public void keyReleased() {
  if(keyCode == SHIFT) {
    shift = false;
  }
}
// Funções matemáticas e geométricas

public int find(int [] vector, int value) {
  // Encontra o índice de um valor no vetor
  
  int index = -1;
  
  for(int i = 0; i < vector.length; i++) {
    if(vector[i] == value) {
      index = i;
      break;
    }
  }
  
  return index;
}

public float[][] multMatrix(float[][] m1, float[][] m2) {
  // Retorna a multiplicação entre m1 e m2
  
  // supoe que as matrizes são multiplicáveis e não vazias
  if(m1.length == 0 || m1[0].length != m2.length) {
    float[][] err = {{-1}, {-1}};
    return err;
  }
    
  float [][] res = new float[m1.length][m2[0].length];
  for(int i = 0; i < m1.length; i++) {
    for(int j = 0; j < m2[0].length; j++) {
      for(int k = 0; k < m2.length; k++) {
        res[i][j] += m1[i][k] * m2[k][j];
      }
    }
  }
  return res;
}

public float[][] copyMatrix(float[][] m, int rows, int cols) {
  // Copia uma matriz m para uma nova matriz com dimensões [rows][cols]
  
  float[][] tempMatrix = new float[rows][cols];
  
  if(m.length > 0) {
    for(int i = 0; i < rows; i++) {
      for(int j = 0; j < cols; j++) {
        if(i < m.length && j < m[0].length) {
          tempMatrix[i][j] = m[i][j];
        }
        // else tempMatrix[i][j] = 0
      }
    }
  }
  
  return tempMatrix;
}

public int[][] copyMatrix(int[][] m, int rows, int cols) {
  // Copia uma matriz m para uma nova matriz com dimensões [rows][cols]
  
  int[][] tempMatrix = new int[rows][cols];
  
  if(m.length > 0) {
    for(int i = 0; i < rows; i++) {
      for(int j = 0; j < cols; j++) {
        if(i < m.length && j < m[0].length) {
          tempMatrix[i][j] = m[i][j];
        }
      }
    }
  }
  
  return tempMatrix;
}

public float[][] rotateMatrix(float[][] vertices, PVector rotation) {
  // Recebe um float[][4] e um PVector de rotação em (x, y, z) e retorna a lista de pontos rotacionada
  
  for(int i = 0; i < vertices.length; i++){
    float x, y, z;
    // em x
    y = vertices[i][1] * cos(rotation.x) - vertices[i][2] * (sin(rotation.x)); // y
    z = vertices[i][1] * sin(rotation.x) + vertices[i][2] * (cos(rotation.x)); // z
    vertices[i][1] = y;
    vertices[i][2] = z;
    
    // em y
    x = vertices[i][0] * cos(rotation.y) + vertices[i][2] * (sin(rotation.y)); // x
    z = -vertices[i][0] * sin(rotation.y) + vertices[i][2] * (cos(rotation.y)); // z
    vertices[i][0] = x;
    vertices[i][2] = z;
    
    // em z
    x = vertices[i][0] * cos(rotation.z) - vertices[i][1] * (sin(rotation.z)); // x
    y = vertices[i][0] * sin(rotation.z) + vertices[i][1] * (cos(rotation.z)); // y
    vertices[i][0] = x;
    vertices[i][1] = y;
  }
  
  return vertices;
}

public float[][] scaleMatrix(float[][] vertices, PVector scale) {
  // Recebe um float[][4] e um PVector de escala em (x, y, z) e retorna a lista de pontos reescalada
  
  for(int i = 0; i < vertices.length; i++) {
    for(int j = 0; j < 3; j++) {
      vertices[i][j] *= scale.array()[j];
    }
  }
  
  return vertices;
}

public float[][] translateMatrix(float[][] vertices, PVector translation) {
  // Recebe um float[][4] e um PVector de translação em (x, y, z) e retorna a lista de pontos transladada
  
  for(int i = 0; i < vertices.length; i++) {
    for(int j = 0; j < 3; j++) {
      vertices[i][j] += translation.array()[j];
    }
  }
  
  return vertices;
}

public float[][] homogeneousToCartesian2D(float[][] vertices) {
  // Recebe um float[][4] e retorna um float[][2]
  
  float[][] tempVertices = new float[vertices.length][2];
  
  for(int i = 0; i < tempVertices.length; i++) {
    for(int j = 0; j < 2; j++) {
      if(vertices[i][3] == 0) {
        continue;
      }
      tempVertices[i][j] = vertices[i][j]/(float)vertices[i][3];
    }
  }
  
  return tempVertices;
}
// Representação de um objeto n-dimensional

public class Object {
  // definições imutáveis do objeto
  String name;
  float[][] vertices;
  int[][] edges;
  int[] axisColors;
  Face[] faces;
  
  // mundo
  int index = 1; // índice desse objeto
  float[][] computedVertices; // vértices computadas prontas para ser exibidas
  
  // vetores mutáveis de estado
  PVector position;
  PVector rotation;
  PVector scale;
  PVector massCenter;

  // componentes
  ArrayList<ComponentInterface> components = new ArrayList<ComponentInterface>();
  
  
  public Object(String name) {
    this.name = name;

    // adiciona componentes
    components.add(new Collider(this));
    components.add(new Physics(this));
  }
  
  
  // inicializadores do objeto, flexíveis para 1-D, 2-D, 3-D até N-D
  public void init(float[][] vertices, int[][] arestas) {
    this.position = new PVector(0, 0, 0);
    this.rotation = new PVector(0, 0, 0);
    this.scale = new PVector(1, 1, 1);
    
    this.vertices = copyMatrix(vertices, vertices.length+12, vertices[0].length);
    this.edges = copyMatrix(arestas, arestas.length+9, arestas[0].length);
   
    
    // TODO Pegar tamanho das linhas dos eixos depois do objeto ser inicializado

    // X-Axis
    this.vertices[vertices.length][0] = 3;
    this.vertices[vertices.length][1] = 0;
    this.vertices[vertices.length][2] = 0;
    
    this.vertices[vertices.length+1][0] = -3;
    this.vertices[vertices.length+1][1] = 0;
    this.vertices[vertices.length+1][2] = 0;

    this.vertices[vertices.length+6][0] = 2.8f;
    this.vertices[vertices.length+6][1] = 0.2f;
    this.vertices[vertices.length+6][2] = 0;

    this.vertices[vertices.length+9][0] = 2.8f;
    this.vertices[vertices.length+9][1] = -0.2f;
    this.vertices[vertices.length+9][2] = 0;

    this.edges[arestas.length][0] = vertices.length;
    this.edges[arestas.length][1] = vertices.length+1;

    this.edges[arestas.length+3][0] = vertices.length;
    this.edges[arestas.length+3][1] = vertices.length+6;

    this.edges[arestas.length+6][0] = vertices.length;
    this.edges[arestas.length+6][1] = vertices.length+9;
    
    // Y-Axis
    this.vertices[vertices.length+2][0] = 0;
    this.vertices[vertices.length+2][1] = 3;
    this.vertices[vertices.length+2][2] = 0;
    
    this.vertices[vertices.length+3][0] = 0;
    this.vertices[vertices.length+3][1] = -3;
    this.vertices[vertices.length+3][2] = 0;

    this.vertices[vertices.length+7][0] = 0.2f;
    this.vertices[vertices.length+7][1] = 2.8f;
    this.vertices[vertices.length+7][2] = 0;

    this.vertices[vertices.length+10][0] = -0.2f;
    this.vertices[vertices.length+10][1] = 2.8f;
    this.vertices[vertices.length+10][2] = 0;

    this.edges[arestas.length+1][0] = vertices.length+2;
    this.edges[arestas.length+1][1] = vertices.length+3;

    this.edges[arestas.length+4][0] = vertices.length+2;
    this.edges[arestas.length+4][1] = vertices.length+7;

    this.edges[arestas.length+7][0] = vertices.length+2;
    this.edges[arestas.length+7][1] = vertices.length+10;
    
    // Z-Axis
    this.vertices[vertices.length+4][0] = 0;
    this.vertices[vertices.length+4][1] = 0;
    this.vertices[vertices.length+4][2] = 3;
    
    this.vertices[vertices.length+5][0] = 0;
    this.vertices[vertices.length+5][1] = 0;
    this.vertices[vertices.length+5][2] = -3;

    this.vertices[vertices.length+8][0] = 0.2f;
    this.vertices[vertices.length+8][1] = 0;
    this.vertices[vertices.length+8][2] = 2.8f;

    this.vertices[vertices.length+11][0] = -0.2f;
    this.vertices[vertices.length+11][1] = 0;
    this.vertices[vertices.length+11][2] = 2.8f;

    this.edges[arestas.length+2][0] = vertices.length+4;
    this.edges[arestas.length+2][1] = vertices.length+5;

    this.edges[arestas.length+5][0] = vertices.length+4;
    this.edges[arestas.length+5][1] = vertices.length+8;

    this.edges[arestas.length+8][0] = vertices.length+4;
    this.edges[arestas.length+8][1] = vertices.length+11;
    
    
    // Axis colors
    this.axisColors = new int[3];
    this.axisColors[0] = color(255, 0, 0);
    this.axisColors[1] = color(0, 255, 0);
    this.axisColors[2] = color(0, 0, 255);


    // inicializa os componentes
    for(int i = 0; i < components.size(); i++) {
      components.get(i).init();
    }
  }
  public void init(float[][] vertices, int[][] arestas, PVector position) {
    init(vertices, arestas);
    this.position = position;
  }
  public void init(float[][] vertices, int[][] arestas, PVector position, PVector rotation, PVector scale) {
    init(vertices, arestas, position);
    this.rotation = rotation;
    this.scale = scale;
  }
  public void init(float[][] vertices, int[][] arestas, PVector position, PVector rotation, PVector scale, Face[] faces) {
    init(vertices, arestas, position, rotation, scale);
    this.faces = faces;
  }
  
  
  /**** INTERFACE FÍSICA ****/
  
  public void translate(PVector delta) {
    position.add(delta);
  }
  public void rotate(PVector delta) {
    // TODO calcular módulo pode ser interessante caso os valores estourarem
    rotation.add(delta);
  }
  public void rescale(PVector delta) {
    scale.add(delta);
  }

  public PVector calcMassCenter() {
    // Calcula o centro de massa de acordo com as posições das faces (a matriz computedVertices já deve ter sido preenchida)
    
    massCenter = new PVector(0, 0, 0);
    
    if(computedVertices != null && computedVertices.length == vertices.length) {
      for(int i = 0; i < faces.length; i++) {
        PVector avgPosition = new PVector(0, 0, 0);
        for(int j = 0; j < faces[i].vertices.length; j++) {
          avgPosition.add(new PVector(computedVertices[faces[i].vertices[j]][0], computedVertices[faces[i].vertices[j]][1], computedVertices[faces[i].vertices[j]][2]));
        }
        avgPosition.div(3);
        massCenter.add(avgPosition);
      }
    
      massCenter.div(faces.length);
    }
    
    return massCenter;
  }
  
  
  /**** INTERFACE PARA DESENHO ****/
  
  public float[][] getVertices() {
    // Calcula as transformações nos vértices do objeto e os retorna
    
    float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
    
    // escala
    tempVertices = scaleMatrix(tempVertices, scale);

    // rotaciona
    tempVertices = rotateMatrix(tempVertices, rotation);
    
    // translada
    tempVertices = translateMatrix(tempVertices, position);
    
    return tempVertices;
  }
  
  public int[][] getEdges() {
    // Retorna as arestas do polígono
    // Pode fazer algum cálculo adicional aqui
    
    return edges;
  }

  public int[] getAxisColors() {
    // Retorna as cores das linhas que representam os eixos XYZ

    return axisColors;
  }
  
  public Face[] getFaces() {
    // Retorna as faces visíveis do objeto
    
    ArrayList<Face> facesToDraw = new ArrayList<Face>();
    
    // calcula a distância das faces e a normal
    for(int i = 0; i < faces.length; i++) {
      // calcula a normal
      PVector P1 = new PVector(computedVertices[faces[i].vertices[0]][0], computedVertices[faces[i].vertices[0]][1], computedVertices[faces[i].vertices[0]][2]);
      PVector P2 = new PVector(computedVertices[faces[i].vertices[1]][0], computedVertices[faces[i].vertices[1]][1], computedVertices[faces[i].vertices[1]][2]);
      PVector P3 = new PVector(computedVertices[faces[i].vertices[2]][0], computedVertices[faces[i].vertices[2]][1], computedVertices[faces[i].vertices[2]][2]);
      faces[i].normal = new PVector((P3.y - P2.y) * (P1.z - P2.z) - (P1.y - P2.y) * (P3.z - P2.z), 
                                   (P3.z - P2.z) * (P1.x - P2.x) - (P1.z - P2.z) * (P3.x - P2.x), 
                                   (P3.x - P2.x) * (P1.y - P2.y) - (P1.x - P2.x) * (P3.y - P2.y));
      float prod = faces[i].normal.x * (observer[world.projection].x - P2.x) + faces[i].normal.y * (observer[world.projection].y - P2.y) + faces[i].normal.z * (observer[world.projection].z - P2.z);
      
      if(prod < 0) {
        continue;
      }
      
      // calcula a posição média da face
      PVector avgPosition = new PVector(0, 0, 0);
      for(int j = 0; j < faces[i].vertices.length; j++) {
        avgPosition.add(new PVector(computedVertices[faces[i].vertices[j]][0], computedVertices[faces[i].vertices[j]][1], computedVertices[faces[i].vertices[j]][2]));
      }
      avgPosition.div(3);
      // calcula a distância para a origem
      faces[i].distance = sqrt(pow(avgPosition.x - observer[world.projection].x, 2) + pow(avgPosition.y - observer[world.projection].y, 2) + pow(avgPosition.z - observer[world.projection].z, 2));
      
      // descarta faces que estão atrás do observador
      if(avgPosition.z <= observer[world.projection].z) {
        continue;
      } else {        
        facesToDraw.add(faces[i]);
      }
    }
    
    return facesToDraw.toArray(new Face[0]);
  }
  
  
  /**** INTERFACE DE ACESSO ****/

  public ComponentInterface getComponent(ComponentInterface type) {
    for(ComponentInterface component : components) {
      if(type.getClass().getName() == component.getClass().getName()) {
        return component;
      }
    }
    return null;
  }

  public void addComponent(ComponentInterface component) {
    if(getComponent(component) != null) {
      return;
    }

    components.add(component);
  }
  
}


public class ObjectComparator implements Comparator<Object> {
  // Classe para comparação da distância entre objetos em relação ao observador
  
  public int compare(Object p1, Object p2) {
    // o mesmo resultado pode ser obtido ordenando apenas o Z, mas o cálculo da distância ficou insignificante e garante maior robustez futura
    if(sqrt(pow(p1.massCenter.x - observer[world.projection].x, 2) + pow(p1.massCenter.y - observer[world.projection].y, 2) + pow(p1.massCenter.z - observer[world.projection].z, 2)) < 
       sqrt(pow(p2.massCenter.x - observer[world.projection].x, 2) + pow(p2.massCenter.y - observer[world.projection].y, 2) + pow(p2.massCenter.z - observer[world.projection].z, 2))) {
      return 1;
    } else {
      return -1;
    }
  }
}


public class Face implements Comparable<Face> {
  int[] vertices;
  int colour;
  float distance = 0;
  PVector normal = new PVector(0, 0, 0);
  
  
  public Face(int[] vertices, int colour) {
    this.vertices = vertices;
    this.colour = colour;
  }
  
  
  public int compareTo(Face compareFace) {
    // Compara duas faces em relação a sua distância para o observador
    
    if(this.distance < compareFace.distance) {
      return 1;
    }
    return -1;
  }
}
public class Physics implements ComponentInterface {
    Object object;

    PVector velocity;
    PVector acceleration;
    float mass = 10;



    boolean useGravity = true;

    public Physics(Object object) {
        this.object = object;

        this.velocity = new PVector(0, 0, 0);
        this.acceleration = new PVector(0, 0, 0);
    }

    public void init() {}

    public void run() {
        // calcula o deslocamento do objeto dadas as interações (aplicação das forças)
        // DEVE SER EXECUTADO APÓS TODOS OS COMPONENTES DE FÍSICA

        applyAcceleration();
        applyVelocity();

        acceleration.mult(0); // zera a aceleração
    }

    private void applyAcceleration() {
        // aplica as acelerações

        PVector tempAcc = acceleration.copy();

        if(useGravity) {
            tempAcc.add(new PVector(0, -9.80665f, 0));
        }

        velocity.add(tempAcc.mult(deltaTime));
    }

    private void applyVelocity() {
        // aplica as velocidades
        PVector tempVel = velocity.copy();
        object.translate(tempVel.mult(deltaTime));
    }
}
// Polígonos e desenho

public void DDALine(int xi, int yi, int xf, int yf, int colour) {  
  // Desenha na tela uma linha de Pi a Pf
  
  int dx = xf - xi, dy = yf - yi, steps = abs(dx);
  
  if(abs(dx) < abs(dy)) 
    steps = abs(dy);  
    
  float incX = dx / (float) steps, incY = dy / (float) steps, x = xi, y = yi;
  
  for(int k = 0; k < steps; k++) {
    
    x += incX;
    y += incY;point((int)x, (int)y);
  }

  stroke(colour);
  point((int)x, (int)y);
}

public void fillPolygon(float[][] vertices, int[][] edges, int colour) {
  // Preenche um polígono dado com uma cor dada (lento)

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
      Ymin = (int) tabela[i][0] - 2;
    }
    if(tabela[i][1] > Ymax) {
      Ymax = (int) tabela[i][1] + 2;
    }
    if(vertices[i][0] < Xmin) {
      Xmin = vertices[i][0] - 2;
    }
    if(vertices[i][0] > Xmax) {
      Xmax = vertices[i][0] + 2;
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

    stroke(colour);
    for(int j = 0; j < intersec.length-1; j += 2) {
      line(intersec[j], i, intersec[j + 1], i);
    }
  }
}

public void scanShape(float[][] vertices, int colour) {
  // Recebe vértices e preenche o polígono associado com vértices ligados sequencialmente (usa scanline e é lento)
  
  int[][] edges = new int[vertices.length][2];  
  
  for(int i = 0; i < vertices.length; i++) {
    edges[i][0] = i;
    edges[i][1] = (i + 1) % vertices.length;
  }
  
  fillPolygon(vertices, edges, colour);
}
// Projeções cavaleira, cabinet, isométrica e perspectiva com ponto de fuga em Z e com ponto de fuga em X e Z

public float [][] adjustDevice(float [][] vertices, PVector limitMin, PVector limitMax) {
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

public float[][] cavalier(float[][] vertices) {
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
      {cos(angle * PI/180.0f) * tempVertices[i][2], sin(angle * PI/180.0f) * tempVertices[i][2], 0, 1},
    };
    tempVertices[i] = multMatrix(hPoint, mCav)[0];
  }
   
  // retorna a lista de pontos transformados
  return homogeneousToCartesian2D(tempVertices);
}

public float[][] cabinet(float[][] vertices) {
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
      {cos(angle * PI/180.0f) * tempVertices[i][2] / 2, sin(angle * PI/180) * tempVertices[i][2] / 2, 0, 1},
    };
    tempVertices[i] = multMatrix(hPoint, mCav)[0];
  }
  
  return homogeneousToCartesian2D(tempVertices);
}

public float[][] isometric(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção isométrica
    float[][] iso = {
      {-cos(45 * PI/180), -sin(35.26f * PI/180)*sin(45 * PI/180), 0, 0},
      {0, cos(35.26f * PI/180), 0, 0},
      {-sin(45 * PI/180), sin(35.26f * PI/180)*cos(45 * PI/180), 0, 0},
      {0, 0, 0, 1},
    };
    
    tempVertices[i] = multMatrix(hPoint, iso)[0];

  }
  
  return homogeneousToCartesian2D(tempVertices);
}

public float[][] perspectiveZ(float[][] vertices) {
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
      {0, 0, 0, 1.0f/width},
      {0, 0, 0, 1},
    };
    
    tempVertices[i] = multMatrix(hPoint, pers)[0];
  }
  
  return homogeneousToCartesian2D(tempVertices);
}

public float[][] perspectiveXZ(float[][] vertices) {
  // Recebe um float[][3] e retorna um float[][2] com pontos recalculados de acordo com a perspectiva
  
  float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
  
  for(int i = 0; i < tempVertices.length; i++) {
    float[][] hPoint = {
      {tempVertices[i][0], tempVertices[i][1], tempVertices[i][2], 1}
    };
    
    // matriz de projeção perspectiva em x e z
    float[][] pers = {
      {1, 0, 0, 1.0f/width},
      {0, 1, 0, 0},
      {0, 0, 0, 1.0f/width},
      {0, 0, 0, 1},
    };
    
    tempVertices[i] = multMatrix(hPoint, pers)[0];
  }
  
  return homogeneousToCartesian2D(tempVertices);
}
// Interface do programa

class Screen {
  float defaultTextSize = 16;
  PVector defaultPosition = new PVector(10, 30);
  float defaultPadding = 7;
  
  public void addText(String text, PVector position, float textSize, int colour) {    
    textSize(textSize);
    fill(colour);
    text(text, position.x, position.y);
  }
  
  public void addLine(String text, int offset, int heading) {
    PVector position = new PVector(defaultPosition.x, defaultPosition.y + (2 * defaultPadding + defaultTextSize) * offset); 
    
    switch(heading) {
      case 0:
        addText(text, position, 22, color(255));
        break;
      case 1:
        addText(text, position, defaultTextSize, color(255));
        break;
      case 2:
        addText(text, position, defaultTextSize, color(200));
        break;
    }
  }
  
  public void showHelp() {
    int offset = 6;
    addLine("Help", offset++, 1);
    addLine("(Shift+)TAB: Seleciona objetos", offset++, 2);
    addLine("ad: Translação em X", offset++, 2);
    addLine("ws: Translação em Y", offset++, 2);
    addLine("qe: Translação em Z", offset++, 2);
    addLine("fh: Escala em X", offset++, 2);
    addLine("tg: Escala em Y", offset++, 2);
    addLine("ry: Escala em Z", offset++, 2);
    addLine("jl: Rotação em X", offset++, 2);
    addLine("ik: Rotação em Y", offset++, 2);
    addLine("uo: Rotação em Z", offset++, 2);
    addLine(",: Clona o objeto selecionado", offset++, 2);
    addLine(".: Destrói o objeto selecionado", offset++, 2);
    addLine("b: Preenchimento (" + (world.useScanLine?"ScanLine)":"Processing)"), offset++, 2);
  }
  
  public void showProjection(int projection) {
    String projectionName = "(P)rojeção Oblíqua Cavaleira";
    
    switch(projection) {
      case 1:
        projectionName = "(P)rojeção Oblíqua Cabinet";
        break;
      case 2:
        projectionName = "(P)rojeção Ortográfica Isométrica";
        break;
      case 3:
        projectionName = "(P)rojeção Perspectiva Z";
        break;
      case 4:
        projectionName = "(P)rojeção Perspectiva X+Z";
        break;
    }
    
    textAlign(RIGHT);
    addText(projectionName, new PVector(width - 2 * defaultPadding, height - (defaultPadding + defaultTextSize)), defaultTextSize, color(130));
    textAlign(LEFT);
  }
  
  public void showFPS() {
    addText("FPS: " + String.format("%.1f", frameRate), new PVector(2 * defaultPadding, height - (defaultPadding + defaultTextSize)), defaultTextSize, color(130));
  }
}
// Gerencia objetos e seu desenho, física e projeções 

class World {
  String name = "World";
  
  PVector position;
  PVector rotation;
  PVector scale;
  
  PVector limitMin, limitMax; // limites da tela para centralizar objetos no (0, 0)

  ArrayList<Object> objects = new ArrayList<Object>();
  int selectedObject = 0; // 0: Camera
  
  boolean useScanLine = true; // usar algoritmo de preenchimento scanline ou o do processing?
  
  // 0: Cavaleira, 1: Cabinet, 2: Isométrica, 3: Perspectiva em Z, 4: Perspectiva em X e em Z
  int projection = 3;

  GlobalPhysics physics;
 
  
  World() {
    position = new PVector(0, 10, 0);
    rotation = new PVector(-0.2f, 0, 0);
    scale = new PVector(1, 1, 1);
    physics = new GlobalPhysics();
  }
  
  public void init(String name, PVector limitMin, PVector limitMax) {
    // Inicializa as dimensões do mundo
    
    this.name = name;
    this.limitMin = limitMin;
    this.limitMax = limitMax;

    physics.init();
  }
  
  public void step() {
    // Roda um passo da simulação do mundo aplicando transformações e física
    
    // roda a física global
    physics.run();

    for(int i = 0; i < objects.size(); i++) {
      Object object = objects.get(i);
      
      // roda a física do mundo
      object.calcMassCenter();
      
      // roda a física do objeto
      for(int j = 0; j < object.components.size(); j++) {
        object.components.get(j).run();
      }
    }
  }
  
  public void render() {
    // Renderiza o mundo e todos os objetos
    
    // destaca que o mundo está selecionado
    if(selectedObject == 0) {
      stroke(255);
      line(0, 0, width - 1, 0);
      line(0, 0, 0, height - 1);
      line(width - 1, 0, width - 1, height - 1);
      line(0, height - 1, width - 1, height - 1);
    }
    
    ArrayList<Object> objectsToDraw = new ArrayList<Object>();
    // faz uma cópia do array de objetos para ordenar mais tarde
    for(int i = 0; i < objects.size(); i++) {
      objects.get(i).index = i + 1;
      objectsToDraw.add(objects.get(i));
    }
    
    // transformações do mundo (antes de ordenar pois a rotação do mundo pode alterar o z)
    for(int i = 0; i < objectsToDraw.size(); i++) {
      Object object = objectsToDraw.get(i);
      
      object.computedVertices = object.getVertices();

      // escala no mundo
      object.computedVertices = scaleMatrix(object.computedVertices, scale);

      // rotaciona no mundo
      object.computedVertices = rotateMatrix(object.computedVertices, rotation);
    
      // translada no mundo
      object.computedVertices = translateMatrix(object.computedVertices, position);
    }
    
    // ordena os objetos de acordo com o z
    Collections.sort(objectsToDraw, new ObjectComparator());
    
    // faz os cálculos de projeção e tela e desenha
    for(int i = 0; i < objectsToDraw.size(); i++) {
      Object object = objectsToDraw.get(i);
      
      float[][] computedVertices = object.computedVertices;
      Face[] faces = object.getFaces();
      
      // projeta
      switch(projection) {
        case 1:
          computedVertices = cabinet(computedVertices);
          break;
        case 2:
          computedVertices = isometric(computedVertices);
          break;
        case 3:
          computedVertices = perspectiveZ(computedVertices);
          break;
        case 4:
          computedVertices = perspectiveXZ(computedVertices);
          break;
        default:
          computedVertices = cavalier(computedVertices);
      }
      
      computedVertices = adjustDevice(computedVertices, limitMin, limitMax);
      boolean select = (selectedObject == object.index)?true:false;  
      drawObject(select, computedVertices, object.getEdges(), object.getAxisColors(), faces);
    }
  }
  
  public void drawObject(boolean select, float[][] vertices, int[][] edges, int[] axisColors, Face[] faces) {
    // Desenha um objeto e suas faces, se tiver
    
    // Se tiver faces, pinta as faces visiveis 
    if(faces != null) {
      for(int i = 0; i < faces.length; i++) {
        if(useScanLine) {
          float[][] faceVertices = new float[faces[i].vertices.length][2];
          for(int j = 0; j < faces[i].vertices.length; j++) {
            faceVertices[j][0] = vertices[faces[i].vertices[j]][0];
            faceVertices[j][1] = vertices[faces[i].vertices[j]][1];
          }
          scanShape(faceVertices, faces[i].colour);
        } else {
          fill(faces[i].colour);
          beginShape();
          for(int j = 0; j < faces[i].vertices.length; j++) {
            vertex(vertices[faces[i].vertices[j]][0], vertices[faces[i].vertices[j]][1]);
          }
          endShape(CLOSE);
        }
      }


      // Desenha as linhas das faces visiveis
      stroke(255);
      strokeWeight(select?4:2);    

      for(int i = 0; i < faces.length; i++) {
        float[][] faceVertices = new float[faces[i].vertices.length][2];
        for(int j = 0; j < faces[i].vertices.length; j++) {
          faceVertices[j][0] = vertices[faces[i].vertices[j]][0];
          faceVertices[j][1] = vertices[faces[i].vertices[j]][1];
        }

        for(int j = 0; j < faceVertices.length; j++) {
          if (j == faceVertices.length-1) {
            line(faceVertices[j][0], faceVertices[j][1], faceVertices[0][0], faceVertices[0][1]);  
          } else {
            line(faceVertices[j][0], faceVertices[j][1], faceVertices[j+1][0], faceVertices[j+1][1]);
          }
        }
      }      
    } 

    // Desenha as linhas dos eixos XYZ
    strokeWeight(2);
    for(int i = edges.length-9; i < edges.length; i++) {
      int p1 = edges[i][0],
          p2 = edges[i][1],
          xi = PApplet.parseInt(vertices[p1][0]),
          yi = PApplet.parseInt(vertices[p1][1]),
          xf = PApplet.parseInt(vertices[p2][0]),
          yf = PApplet.parseInt(vertices[p2][1]);
        
      stroke(axisColors[abs(edges.length-9 - i)%3]);
      line(xi, yi, xf, yf);
    }
    noStroke();

  }
  
  public void circleProjection(int step) {
    // Recebe 1 ou -1 e cicla sobre as projeções disponíveis

    projection = (projection + step) % 5; // 5: número de projeções disponível
    if(projection == -1) {
      projection = 4;
    }
  }
  
  /**** GERENCIAMENTO DOS OBJETOS DA CENA ****/
  
  public void create(Object object) {
    // Adiciona um objeto na lista
    
    objects.add(object);
  }
  
  public void cloneSelected() {
    // Clona o objeto selecionado
    
    if(selectedObject == 0 || objects.size() == 0) 
      return;

    Object last = objects.get(selectedObject - 1);
    Object newObject = new Object(last.name + " (copy)");
    float[][] vertices = new float[last.vertices.length][last.vertices[0].length];
    int[][] arestas = new int[last.edges.length][last.edges[0].length];
    arrayCopy(last.vertices, vertices);
    arrayCopy(last.edges, arestas);
    
    newObject.init(vertices, arestas, last.position.copy(), last.rotation.copy(), last.scale.copy());
    objects.add(newObject);
    selectedObject = objects.size();
  }
  
  public void destroySelected() {
    // Destrói o objeto selecionado
    
    if(selectedObject == 0 || objects.size() == 0) 
      return;
      
    objects.remove(selectedObject - 1);
    selectedObject = 0;
  }
  
  public void circleSelect(int step) {
    // Cicla sobre a seleção de objetos
    
    selectedObject = (selectedObject + step) % (objects.size() + 1);
    if(selectedObject == -1) {
      selectedObject = objects.size();
    }
  }
  
  public void translateSelected(float x, float y, float z) {
    // Translada o objeto selecionado
    
    if(selectedObject == 0) {
      position.sub(new PVector(x, y, z));
    } else {
      Object last = objects.get(selectedObject - 1);
      last.translate(new PVector(x, y, z));
    }
  }
  public void rotateSelected(float x, float y, float z) {
    // Rotaciona o objeto selecionado
    
    if(selectedObject == 0) {
      rotation.sub(new PVector(x, y, z));
    } else {
      Object last = objects.get(selectedObject - 1);
      last.rotate(new PVector(x, y, z));
    }
  }
  public void scaleSelected(float x, float y, float z) {
    // Escala o objeto selecionado
    
    if(selectedObject == 0) {
      scale.sub(new PVector(x, y, z));
    } else {
      Object last = objects.get(selectedObject - 1);
      last.rescale(new PVector(x, y, z));
    }
  }
  
  public String selectedName() {
    // Retorna o nome do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return "Camera";
    }
    return objects.get(selectedObject - 1).name;
  }
  
  public PVector selectedPosition() {
    // retorna a posição do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return this.position;
    }
    return objects.get(selectedObject - 1).position;
  }
  
  public PVector selectedRotation() {
    // retorna a rotação do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return this.rotation;
    }
    return objects.get(selectedObject - 1).rotation;
  }
  
  public PVector selectedScale() {
    // retorna a escala do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return this.scale;
    }
    return objects.get(selectedObject - 1).scale;
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Simulator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
