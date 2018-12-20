// Representação de um objeto n-dimensional

public class Object {
  // definições imutáveis do objeto
  String name;
  float[][] vertices;
  int[][] edges;
  color[] axisColors;
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
    
    this.vertices = copyMatrix(vertices, vertices.length + axisVertices, vertices[0].length);
    this.edges = copyMatrix(arestas, arestas.length + axisEdges, arestas[0].length);
   
    
    // TODO Pegar tamanho das linhas dos eixos depois do objeto ser inicializado

    // X-Axis
    this.vertices[vertices.length][0] = 3;
    this.vertices[vertices.length][1] = 0;
    this.vertices[vertices.length][2] = 0;
    
    this.vertices[vertices.length+1][0] = -3;
    this.vertices[vertices.length+1][1] = 0;
    this.vertices[vertices.length+1][2] = 0;

    this.vertices[vertices.length+6][0] = 2.8;
    this.vertices[vertices.length+6][1] = 0.2;
    this.vertices[vertices.length+6][2] = 0;

    this.vertices[vertices.length+9][0] = 2.8;
    this.vertices[vertices.length+9][1] = -0.2;
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

    this.vertices[vertices.length+7][0] = 0.2;
    this.vertices[vertices.length+7][1] = 2.8;
    this.vertices[vertices.length+7][2] = 0;

    this.vertices[vertices.length+10][0] = -0.2;
    this.vertices[vertices.length+10][1] = 2.8;
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

    this.vertices[vertices.length+8][0] = 0.2;
    this.vertices[vertices.length+8][1] = 0;
    this.vertices[vertices.length+8][2] = 2.8;

    this.vertices[vertices.length+11][0] = -0.2;
    this.vertices[vertices.length+11][1] = 0;
    this.vertices[vertices.length+11][2] = 2.8;

    this.edges[arestas.length+2][0] = vertices.length+4;
    this.edges[arestas.length+2][1] = vertices.length+5;

    this.edges[arestas.length+5][0] = vertices.length+4;
    this.edges[arestas.length+5][1] = vertices.length+8;

    this.edges[arestas.length+8][0] = vertices.length+4;
    this.edges[arestas.length+8][1] = vertices.length+11;
    
    
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
