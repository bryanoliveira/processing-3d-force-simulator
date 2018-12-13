import java.util.*; 

Screen screen;
World world;
PVector observer; // observador/câmera


void setup() {
  size(1280, 720);
  
  observer = new PVector(0, 0, -10000);
  world = new World();
  screen = new Screen();
  
  load("figure.dat");
}


void draw() {
  background(77);
  
  // pega inputs
  keyRepeat();
  
  // calcula e renderiza o mundo
  world.step();
  world.render();
  
  // exibe interface
  screen.showProjection(world.projection);
  screen.showFPS();
  screen.addLine(world.name, 0, 0);
  screen.addLine("\"" + world.selectedName() + "\" selected", 1, 2);
}


void load(String fileName) {
  // Carrega dados do mundo e objetos de um arquivo
  
  String[] fileLines = loadStrings(fileName);
  int cursorPosition = 0;
  
  String figureName = fileLines[cursorPosition++].substring(2);
  
  // lê as dimensões do dispositivo
  String[] worldDimensions = split(fileLines[cursorPosition++], " ");
  world.init(figureName, new PVector(Integer.parseInt(worldDimensions[0]), Integer.parseInt(worldDimensions[2])), new PVector(Integer.parseInt(worldDimensions[1]), Integer.parseInt(worldDimensions[3])));
  
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
      
      int faceColorR = int(Float.parseFloat(face[facePoints.length + 1]) * 255);
      int faceColorG = int(Float.parseFloat(face[facePoints.length + 2]) * 255);
      int faceColorB = int(Float.parseFloat(face[facePoints.length + 3]) * 255);
      color colour = color(faceColorR, faceColorG, faceColorB);
       
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
    
    // inicializa o objeto
    object.init(vertices, edges, translation, rotation, scale, faces);
    // adiciona o objeto ao mundo
    world.create(object);
  }
}
