/**
 * Author: Bryan Lincoln
 * Created at: August, 2018
 */
 
int posX, posY, square_size;
boolean up, down, right, left;

void setup() {
  size(640, 360);
  square_size = 8;
  posX = width / 2 - square_size / 2;
  posY = height / 2 - square_size / 2;
  background(255);
}

void draw() {  
  fill(0);
  create_rect(posX, posY, square_size, square_size);
   
  leaveTrail();
  
  if(up) {
    posY--;
    if(posY < 0)
      posY = height;
  }
  if(down) {
    posY++;
    if(posY >= height)
      posY = 0;
  }
  if(right) {
    posX++;
    if(posX >= width)
      posX = 0;
  }
  if(left) {
    posX--;
    if(posX < 0)
      posX = width;
  }
}

void create_rect(int x, int y, int w, int h) {
  for(int l = 0; l < w; l++) {
    for(int c = 0; c < h; c++) {
      point(x + c, y + l);
    }
  }
}

void leaveTrail() {
  fill(0);
  create_rect(posX, posY, 8, 8);
}

void keyPressed() {
  switch(key) {
    case '8':
    case 'w':
    case 'W':
    up = true;
    break;
    
    case '2':
    case 'x':
    case 'X':
    down = true;
    break;
    
    case '4':
    case 'a':
    case 'A':
    left = true;
    break;
    
    case '6':
    case 'd':
    case 'D':
    right = true;
    break;
    
    case '5':
    case 's':
    case 'S':
    background(255);
    break;
    
    case 27:
    return;
  }
}

void keyReleased() {
  switch(key) {
    case '8':
    case 'w':
    case 'W':
    up = false;
    break;
    
    case '2':
    case 'x':
    case 'X':
    down = false;
    break;
    
    case '4':
    case 'a':
    case 'A':
    left = false;
    break;
    
    case '6':
    case 'd':
    case 'D':
    right = false;
    break;
    
    case '5':
    case 's':
    case 'S':
    background(255);
    break;
    
    case 27:
    return;
  }
}
