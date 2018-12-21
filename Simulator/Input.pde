boolean shift = false;
boolean helpPressed = false;

void keyRepeat() {
  // Pega teclas pressionadas continuamente
  
  if(keyPressed) {
    if (key != CODED) {
      switch(key) {
        // translação
        case 'w':
          world.translateSelected(0, 0.1, 0);
          break;
        case 's':
          world.translateSelected(0, -0.1, 0);
          break;
        case 'a':
          world.translateSelected(-0.1, 0, 0);
          break;
        case 'd':
          world.translateSelected(0.1, 0, 0);
          break;
        case 'q':
          world.translateSelected(0, 0, -0.1);
          break;
        case 'e':
          world.translateSelected(0, 0, 0.1);
          break;
          
        // rotação
        case 'j':
          world.rotateSelected(0, 0.05, 0);
          break;
        case 'l':
          world.rotateSelected(0, -0.05, 0);
          break;
        case 'i':
          world.rotateSelected(-0.05, 0, 0);
          break;
        case 'k':
          world.rotateSelected(0.05, 0, 0);
          break;
        case 'o':
          world.rotateSelected(0, 0, 0.05);
          break;
        case 'u':
          world.rotateSelected(0, 0, -0.05);
          break;
          
        // escala
        case 't':
          world.scaleSelected(0, 0.05, 0);
          break;
        case 'g':
          world.scaleSelected(0, -0.05, 0);
          break;
        case 'f':
          world.scaleSelected(0.05, 0, 0);
          break;
        case 'h':
          world.scaleSelected(-0.05, 0, 0);
          break;
        case 'r':
          world.scaleSelected(0, 0, 0.05);
          break;
        case 'y':
          world.scaleSelected(0, 0, -0.05);
          break;
      }
    }
  }
}

void keyPressed() {
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
      case 'b':
        world.useScanLine = !world.useScanLine;
    }
  } else if(keyCode == SHIFT) {
    shift = true;
  } else if(keyCode == 112) {
    helpPressed = !helpPressed;
  }
  
}

void keyReleased() {
  if(keyCode == SHIFT) {
    shift = false;
  }
}
