// Representação de um objeto n-dimensional

public class Object {
  // definições imutáveis do objeto
  String name;
  float[][] vertices;
  float[][] axisVertices;
  int[][] edges;
  int[][] axisEdges;
  color[] axisColors;
  Face[] faces;
  
  // mundo
  int index = 1; // índice desse objeto
  float[][] computedVertices; // vértices computadas prontas para ser exibidas
  float[][] computedAxisVertices;

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
    
    this.vertices = copyMatrix(vertices, 0, 0, vertices.length, vertices[0].length);
    this.edges = copyMatrix(arestas, 0, 0, arestas.length, arestas[0].length);    

    // Axis vertices
    float[][] axisVertices = {
      {3, 0, 0, 1},
      {-3, 0, 0, 1},
      {0, 3, 0, 1},
      {0, -3, 0, 1},
      {0, 0, 3, 1},
      {0, 0, -3, 1},
      {2.8, 0.2, 0, 1},
      {0.2, 2.8, 0, 1},
      {0.2, 0, 2.8, 1},
      {2.8, -0.2, 0, 1},
      {-0.2, 2.8, 0, 1},
      {-0.2, 0, 2.8, 1}
    };
    this.axisVertices = axisVertices;

    // Axis edges
    int[][] axisEdges = {
      {0, 1},
      {2, 3},
      {4, 5},
      {0, 6},
      {2, 7},
      {4, 8},
      {0, 9},
      {2, 10},
      {4, 11}
    };
    this.axisEdges = axisEdges;
    
    // Axis colors
    this.axisColors = new color[3];
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

  PVector calcMassCenter() {
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
    
    float[][] tempVertices = copyMatrix(vertices, 0, 0, vertices.length, 4);
    
    // escala
    tempVertices = scaleMatrix(tempVertices, scale);

    // rotaciona
    tempVertices = rotateMatrix(tempVertices, rotation);
    
    // translada
    tempVertices = translateMatrix(tempVertices, position);
    
    return tempVertices;
  }

  public float[][] getAxisVertices() { 
    // Calcula as transformações nos vértices dos eixos XYZ do objeto e os retorna
    float[][] tempVertices = copyMatrix(axisVertices, 0, 0, axisVertices.length, 4);

    // rotaciona
    tempVertices = rotateMatrix(tempVertices, rotation);
    
    // translada
    tempVertices = translateMatrix(tempVertices, position);
    
    return tempVertices;
  }
  
  public int[][] getEdges() {
    // Retorna as arestas do polígono    
    return edges;
  }

  public int[][] getAxisEdges() {
    // Retorna as arestas dos eixos XYZ do objeto
    return axisEdges;
  }

  public color[] getAxisColors() {
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
      float prod = faces[i].normal.x * (world.observer.x - P2.x) + faces[i].normal.y * (world.observer.y - P2.y) + faces[i].normal.z * (world.observer.z - P2.z);
      
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
      faces[i].distance = sqrt(pow(avgPosition.x - world.observer.x, 2) + pow(avgPosition.y - world.observer.y, 2) + pow(avgPosition.z - world.observer.z, 2));
      
      // descarta faces que estão atrás do observador
      if(avgPosition.z <= world.observer.z) {
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
    if(sqrt(pow(p1.massCenter.x - world.observer.x, 2) + pow(p1.massCenter.y - world.observer.y, 2) + pow(p1.massCenter.z - world.observer.z, 2)) < 
       sqrt(pow(p2.massCenter.x - world.observer.x, 2) + pow(p2.massCenter.y - world.observer.y, 2) + pow(p2.massCenter.z - world.observer.z, 2))) {
      return 1;
    } else {
      return -1;
    }
  }
}


public class Face implements Comparable<Face> {
  int[] vertices;
  color colour;
  float distance = 0;
  PVector normal = new PVector(0, 0, 0);
  
  
  public Face(int[] vertices, color colour) {
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
