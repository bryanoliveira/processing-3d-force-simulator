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
    addLine("[Shift+]TAB: Select objects", offset++, 2);
    addLine(".: Destroy selected object", offset++, 2);
    addLine("a d: Translate X", offset++, 2);
    addLine("w s: Translate Y", offset++, 2);
    addLine("q e: Translate Z", offset++, 2);
    addLine("f h: Scale X", offset++, 2);
    addLine("t g: Scale Y", offset++, 2);
    addLine("r y: Scale Z", offset++, 2);
    addLine("i k: Rotate X", offset++, 2);
    addLine("j l: Rotate Y", offset++, 2);
    addLine("u o: Rotate", offset++, 2); 
    addLine("b: Face rendering (" + (world.useScanLine?"ScanLine)":"Processing)"), offset++, 2);
  }
  
  void showInfo() {
    textAlign(RIGHT);
    addText("Change scene: X", new PVector(width - 2 * defaultPadding, (defaultPadding + defaultTextSize)), defaultTextSize, color(200));
    addText("Projection: Perspective Z", new PVector(width - 2 * defaultPadding, height - (defaultPadding + defaultTextSize)), defaultTextSize, color(130));
    textAlign(LEFT);
  }
  
  void showFPS() {
    addText("FPS: " + String.format("%.1f", frameRate), new PVector(2 * defaultPadding, height - (defaultPadding + defaultTextSize)), defaultTextSize, color(130));
  }
}
