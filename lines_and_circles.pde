/**
 * Author: Bryan Lincoln
 * Created at: September, 2018
 */

void setup() {
  size(640, 360);
  background(0);
}

void draw() {  
  // escolhe aleatoriamente uma cor RGB para o objeto a ser desenhado
  color cor = color((int)random(256), (int)random(256), (int)random(256));
  fill(cor);
  stroke(cor);
  
  // decide se vai fazer um círculo ou uma reta
  if((int)random(2) == 0) { // desenha linha
    linhaDDA((int)random(width), (int)random(height), (int)random(width), (int)random(height));
  } else { // desenha reta
    circBrasenham((int)random(width), (int)random(height), (int)random(40, 100));
  }
}

void linhaDDA (int xi, int yi, int xf, int yf) {
  int dx = xf - xi, dy = yf - yi, steps = abs(dx);
  
  if(abs(dx) < abs(dy)) 
    steps = abs(dy);  
    
  float incX = dx / (float) steps, incY = dy / (float) steps, x = xi, y = yi;
  
  point(x, y);
  for(int k = 0; k < steps; k++) {
    x += incX;
    y += incY;
    point((int)x, (int)y);
  }
}

void circBrasenham (int xc, int yc, int r) {
  float x = 0, y = r;
  
  do {
    point(xc - (int)x, yc - (int)y);
    point(xc - (int)x, yc - (int)-y);
    point(xc - (int)-x, yc - (int)y);
    point(xc - (int)-x, yc - (int)-y);
    
    float di = pow(x + 1, 2) + pow(y + 1, 2) - pow(r, 2);
    if(di == 0) {
      x += 1;
      y -= 1;
    } else {
      float md = abs(pow(x + 1, 2) + pow(y + 1, 2) - pow(r, 2));
      if(di < 0) {
        float mh = abs(pow(x + 1, 2) + pow(y, 2) - pow(r, 2));
        x++;
        if(mh - md < 0) {
          y--;
        }
      } else {
        float mv = abs(pow(x, 2) + pow(y + 1, 2) - pow(r, 2));
        y--;
        if(mv - md >= 0) {
          x++;  
        }
      }
    }
  } while(x <= r && y >= 0);
}
