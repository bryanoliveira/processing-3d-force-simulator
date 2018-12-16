// Representação de um objeto n-dimensional

public class Object {
  // definições imutáveis do objeto
  String name;
  float[][] vertices;
  int[][] edges;
  Face[] faces;
  
  // mundo
  int index = 1; // índice desse objeto
  float[][] computedVertices; // vértices computadas prontas para ser exibidas
  
  // vetores mutáveis de estado
  PVector position;
  PVector rotation;
  PVector scale;
  PVector massCenter;
  
  
  public Object(String name) {
    this.name = name;
  }
  
  
  // inicializadores do objeto, flexíveis para 1-D, 2-D, 3-D até N-D
  public void init(float[][] vertices, int[][] arestas) {
    this.position = new PVector(0, 0, 0);
    this.rotation = new PVector(0, 0, 0);
    this.scale = new PVector(1, 1, 1);
    
    this.vertices = vertices;
    this.edges = arestas;
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
  
  
  /**** INTERFACE PARA DESENHO ****/
  
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
  
  public float[][] getVertices() {
    // Calcula as transformações nos vértices do objeto e os retorna
    
    float[][] tempVertices = copyMatrix(vertices, vertices.length, 4);
    
    // rotaciona
    tempVertices = rotateMatrix(tempVertices, rotation);
    
    // escala
    tempVertices = scaleMatrix(tempVertices, scale);
    
    // translada
    tempVertices = translateMatrix(tempVertices, position);
    
    return tempVertices;
  }
  
  public int[][] getEdges() {
    // Retorna as arestas do polígono
    // Pode fazer algum cálculo adicional aqui
    
    return edges;
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
      PVector normal = new PVector((P3.y - P2.y) * (P1.z - P2.z) - (P1.y - P2.y) * (P3.z - P2.z), 
                                   (P3.z - P2.z) * (P1.x - P2.x) - (P1.z - P2.z) * (P3.x - P2.x), 
                                   (P3.x - P2.x) * (P1.y - P2.y) - (P1.x - P2.x) * (P3.y - P2.y));
      float prod = normal.x * (observer[world.projection].x - P2.x) + normal.y * (observer[world.projection].y - P2.y) + normal.z * (observer[world.projection].z - P2.z);
      
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
