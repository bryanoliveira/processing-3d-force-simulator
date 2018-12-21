// Interface do programa

class Screen {
  float defaultTextSize = 16;
  PVector defaultPosition = new PVector(10, 30);
  float defaultPadding = 7;
  
  void addText(String text, PVector position, float textSize, color colour) {    
    textSize(textSize);
    fill(colour);
    text(text, position.x, position.y);
  }
  
  void addLine(String text, int offset, int heading) {
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
  
  void showHelp() {
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
  
  void showProjection(int projection) {
    textAlign(RIGHT);
    addText("Projeção Perspectiva Z", new PVector(width - 2 * defaultPadding, height - (defaultPadding + defaultTextSize)), defaultTextSize, color(130));
    textAlign(LEFT);
  }
  
  void showFPS() {
    addText("FPS: " + String.format("%.1f", frameRate), new PVector(2 * defaultPadding, height - (defaultPadding + defaultTextSize)), defaultTextSize, color(130));
  }
}
