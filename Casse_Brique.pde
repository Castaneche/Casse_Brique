/* Code Casse_Brique (janvier 2018 ISN) */

class Brique {
  float _x, _y;
  float _w, _h;
  float _a, _v; //couleur et vitesse de changement de couleur
  Brique() {
  }
  Brique(float x, float y, float w, float h) {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
    //Random color
    _a = random(0, 255);
    _v = random(0.3, 0.8);
  }
  void update() {
    if (_a > 255) _a = 0;
    _a +=_v;
  }
  void draw() {
    colorMode(HSB);
    fill(_a, 255, 255);
    noStroke();
    rect(_x, _y, _w, _h);
    colorMode(RGB);
  }
}
class Pad {
  float _x, _y;
  float _w, _h;
  Pad() {
    //defaut
  }
  Pad(float x, float y, float w, float h) {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
  }
  void collisions(Ball b) { //Collisions pad - ball
    if (b._x + b._s/2. >= _x
      && b._x - b._s/2.<= _x + _w
      && b._y + b._s/2. >= _y 
      && b._y - b._s/2. <= _y + _h) //Limites du pad en tenant compte de la taille de la balle
    { 
      b._vy *= -1; // Inverse la vitesse en y pour faire rebondir
      if (_w > 30) _w -= 3; // Taille du pad diminue a chaque collisions.
    }
  }
  void update() {
    //Suit la souris
    _x = mouseX-_w/2;
  }
  void draw() {
    stroke(0);
    fill(200);
    rect(_x, _y, _w, _h);
  }
}
class Ball {
  float _x, _y;
  float _s;
  float _vx, _vy;
  Ball() {
    //defaut
  }
  Ball(float x, float y, float s) {
    _x = x;
    _y = y;
    _s = s;
  }
  void collisions() { //Collisions ball - murs
    if (_x - (_s/2) < 0 || _x + (_s/2) > width) {
      _vx *= -1;
    }
    if (_y - (_s/2) < 0) {
      _vy *= -1;
    }
    if (_y + (_s/2) > height) {
      launch = false;
      vies--;
    }
  }
  boolean collisionsBrique(Brique b) {
    float H = b._y; //haut
    float G = b._x; //gauche
    float D = b._x + b._w; //droite
    float B = b._y + b._h; //bas
    
    if (_x - (_s/2) > G && _x + (_s/2) < D) {
      if(_y + (_s/2) > H && _y + (_s/2) < H + 10) { //Coté heut
        _vy *= -1;  
        return true;
      }
      else if(_y - (_s/2) < B && _y - (_s/2) > B - 10) { //Coté bas
        _vy *= -1;
        return true;
      }
    }
    if (_y + (_s/2) > H && _y - (_s/2) < B) {
      if(_x + (_s/2) > G && _x + (_s/2) < G + 10) { //Coté Gauche
        _vx *= -1;  
        return true;
      }
      else if(_x - (_s/2) < D && _x - (_s/2) > D - 10) { //Coté Droit
        _vx *= -1;
        return true;
      }
    }
    //pas de collisions
    return false;
  }
  void update() {
    _x += _vx;
    _y += _vy;
  }
  void draw() {
    fill(200);
    noStroke();
    ellipse(_x, _y, _s, _s);
  }
}

ArrayList<Brique> briques = new ArrayList<Brique>(); //Tableau dynamique contenant les briques
Pad pad; 
Ball ball;
boolean launch = false; //Determine si la balle a été lancée
int score, vies;
boolean GAMEOVER = false;

//nx : nombre de briques en x
//ny : nombre de briques en y
//yL : limite en y du placement des briques
//offset : espace entre les briques
void init(int nx, int ny, float yL, float offset) {  
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      briques.add(new Brique(i * float(width/nx) + offset, j * (yL/ny) + offset, width/nx - offset*2, (yL/ny) - offset*2));
    }
  }
}

void setup() {
  size(800, 600);  
  frameRate(60);

  colorMode(RGB);
  
  //Initialisation des objets
  pad = new Pad(width/2-25, height - 40, 100, 10);
  ball = new Ball(width/2, height - 50, 10);
  
  //Placement des briques
  init(10, 7, 250, 3);

  score=0;
  vies=1;
}
void draw() {
  background(25);
  
  for (int i =0; i < briques.size(); i++) {
    briques.get(i).update();
    briques.get(i).draw();
    //Collision balle - brique
    if (ball.collisionsBrique(briques.get(i))) {
      briques.remove(i);
      score++;
    }
  }
  if (GAMEOVER) {
    //Affichage de l'ecran GAMEOVER
    textAlign(CENTER);
    textSize(60);
    fill(255);
    text("Game over - score: " + score, width/2, height/2);
  } else if (briques.size()==0) {
    //Affichage de l'ecran WIN
    textAlign(CENTER);
    textSize(60);
    fill(255);
    text("WIN ! - score: " + score, width/2, height/2);
  } else {
    //Affichage du jeu
    textSize(100);
    fill(255);
    textAlign(CENTER);
    text(score, width/2, height/2);
    textSize(50);
    text(vies, width/2, height/2+200);
    
    pad.collisions(ball);
    ball.collisions();
    pad.update();
    ball.update();
  }
  
  pad.draw();
  ball.draw();

  //Ball en attente d'etre lancée : placée au dessus du pad
  if (!launch) {
    ball._x = pad._x + pad._w/2;
    ball._y = pad._y - 20;
  }
  //Test nombre de vies
  if (vies<=0) {
    vies=0;
    GAMEOVER=true;
  }
}
//Lance la balle si le joueur appuie sur espace
void keyPressed() {
  if (key == ' ' && !launch) {
    launch = true;  
    ball._vx = random(1, 1.5)*3;
    ball._vy = -random(1, 1.5)*3;
  }
}