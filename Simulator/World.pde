// Gerencia objetos e seu desenho, física e projeções 

class World {
  String name = "World";
  
  PVector position;
  PVector rotation;
  PVector scale;
  
  PVector limitMin, limitMax; // limites da tela para centralizar objetos no (0, 0)

  ArrayList<Object> objects = new ArrayList<Object>();
  int selectedObject = 0; // 0: Camera
  
  boolean useScanLine = false; // usar algoritmo de preenchimento scanline ou o do processing?
  
  // 0: Cavaleira, 1: Cabinet, 2: Isométrica, 3: Perspectiva em Z, 4: Perspectiva em X e em Z
  int projection = 3;

  GlobalPhysics physics;
 
  
  World() {
    position = new PVector(0, 10, 0);
    rotation = new PVector(-0.2, 0, 0);
    scale = new PVector(1, 1, 1);
    physics = new GlobalPhysics();
  }
  
  void init(String name, PVector limitMin, PVector limitMax) {
    // Inicializa as dimensões do mundo
    
    this.name = name;
    this.limitMin = limitMin;
    this.limitMax = limitMax;

    physics.init();
  }
  
  void step() {
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
  
  void render() {
    // Renderiza o mundo e todos os objetos
    
    // destaca que o mundo está selecionado
    if(selectedObject == 0) {
      stroke(255);
      DDALine(0, 0, width - 1, 0);
      DDALine(0, 0, 0, height - 1);
      DDALine(width - 1, 0, width - 1, height - 1);
      DDALine(0, height - 1, width - 1, height - 1);
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
      
      if(selectedObject == object.index) {
        stroke(255);
      } else {
        stroke(140);
      }
      
      drawObject(computedVertices, object.getEdges(), faces);
    }
  }
  
  void drawObject(float[][] vertices, int[][] edges, Face[] faces) {
    // Desenha um objeto e suas faces, se tiver
    
    // desenha as linhas do polígono
    for(int i = 0; i < edges.length; i++) {
      int p1 = edges[i][0],
          p2 = edges[i][1],
          xi = int(vertices[p1][0]),
          yi = int(vertices[p1][1]),
          xf = int(vertices[p2][0]),
          yf = int(vertices[p2][1]);
          
      DDALine(xi, yi, xf, yf);
    }
    
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
    }
  }
  
  void circleProjection(int step) {
    // Recebe 1 ou -1 e cicla sobre as projeções disponíveis

    projection = (projection + step) % 5; // 5: número de projeções disponível
    if(projection == -1) {
      projection = 4;
    }
  }
  
  /**** GERENCIAMENTO DOS OBJETOS DA CENA ****/
  
  void create(Object object) {
    // Adiciona um objeto na lista
    
    objects.add(object);
  }
  
  void cloneSelected() {
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
  
  void destroySelected() {
    // Destrói o objeto selecionado
    
    if(selectedObject == 0 || objects.size() == 0) 
      return;
      
    objects.remove(selectedObject - 1);
    selectedObject = 0;
  }
  
  void circleSelect(int step) {
    // Cicla sobre a seleção de objetos
    
    selectedObject = (selectedObject + step) % (objects.size() + 1);
    if(selectedObject == -1) {
      selectedObject = objects.size();
    }
  }
  
  void translateSelected(float x, float y, float z) {
    // Translada o objeto selecionado
    
    if(selectedObject == 0) {
      position.sub(new PVector(x, y, z));
    } else {
      Object last = objects.get(selectedObject - 1);
      last.translate(new PVector(x, y, z));
    }
  }
  void rotateSelected(float x, float y, float z) {
    // Rotaciona o objeto selecionado
    
    if(selectedObject == 0) {
      rotation.sub(new PVector(x, y, z));
    } else {
      Object last = objects.get(selectedObject - 1);
      last.rotate(new PVector(x, y, z));
    }
  }
  void scaleSelected(float x, float y, float z) {
    // Escala o objeto selecionado
    
    if(selectedObject == 0) {
      scale.sub(new PVector(x, y, z));
    } else {
      Object last = objects.get(selectedObject - 1);
      last.rescale(new PVector(x, y, z));
    }
  }
  
  String selectedName() {
    // Retorna o nome do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return "Camera";
    }
    return objects.get(selectedObject - 1).name;
  }
  
  PVector selectedPosition() {
    // retorna a posição do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return this.position;
    }
    return objects.get(selectedObject - 1).position;
  }
  
  PVector selectedRotation() {
    // retorna a rotação do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return this.rotation;
    }
    return objects.get(selectedObject - 1).rotation;
  }
  
  PVector selectedScale() {
    // retorna a escala do objeto selecionado
    
    if(objects.size() == 0 || selectedObject == 0) {
      return this.scale;
    }
    return objects.get(selectedObject - 1).scale;
  }
}
