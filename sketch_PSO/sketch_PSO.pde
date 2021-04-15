// PSO de acuerdo a Talbi (p.247 ss)

PImage surf;

// ===============================================================
int puntos = 100;
Particle[] fl; 
float d = 15; // radio del círculo, solo para despliegue
float gbestx = 99999, gbesty = 99999, gbest = 99999; 
float w = 0.4091; 
float C1 = 2.1304, C2 = 1.0575; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 4; // max velocidad (modulo)
float max_rastrigin = -5.12; 
float min_rastrigin = 5.12;
float PI = 3.14159265359;
int C=460;

class Particle{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float px, py, pfit; // position (p-vector) and fitness (p-fitness) of best solution found by particle so far
  float vx, vy; //vector de avance (v-vector)
  
  Particle(){
    x = initializePos(); //2.56 es una buena inicialización para la posición en X  
    y = initializePos(); //5.12 es una buena inicialización para la posición en Y
    vx = random(-1,1); vy = random(-1);
    pfit = 999; fit = 999; 
  }
  
  float initializePos() {
    return min_rastrigin + random(0,1) * (max_rastrigin - min_rastrigin);
  }
  
  float rastrigin(float x, float y) {
    return 20 + ((x * x) - 10 * cos(2 * PI * x)) + ((y * y) - 10 * cos(2 * PI * y));
  }
  
  // ---------------------------- Evalúa partícula
  float Eval(PImage surf){ //recibe imagen que define función de fitness
    evals++;
    fit = rastrigin(x, y);
    if(fit < pfit){ // actualiza local best si es mejor
      pfit = fit;
      px = x;
      py = y;
    }
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println(str(gbest));
    };
    return fit; 
  }
  
  // ------------------------------ mueve la partícula
  void move(){
    /*actualiza velocidad (fórmula con factores de aprendizaje C1 y C2)
    vx = vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    vy = vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    actualiza velocidad (fórmula con inercia, p.250)
    vx = w * vx + random(0,1)*(px - x) + random(0,1)*(gbestx - x);
    vy = w * vy + random(0,1)*(py - y) + random(0,1)*(gbesty - y);*/
    
    //actualiza velocidad (fórmula mezclada) => MEJORES RESULTADOS por esta formula
    vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    // trunca velocidad a maxv
    float modu = sqrt(vx*vx + vy*vy);
    if (modu > maxv){
      vx = vx/modu*maxv;
      vy = vy/modu*maxv;
    }
    
    x = x + vx;
    y = y + vy;
    
    // rebota en murallas

  }
  
  // ------------------------------ despliega partícula
  void display(){
    color c=surf.get(int(x),int(y)); 
    ellipse (x+C,y+C,d,d);
    // dibuja vector
    stroke(#ff0000);
    line(x+ C,y+ C,(x+ C)-10*vx,(y+ C)-10*vy);

  }
} 

// dibuja punto azul en la mejor posición y despliega números
void despliegaBest(){
  fill(#0000ff);
  ellipse(gbestx+ C,gbesty+ C,d,d);
  PFont f = createFont("Arial",30,true);
  textFont(f,15);
  fill(#0022ff);
  text("Best fitness: "+str(gbest)+"\nEvals to best: "+str(evals_to_best)+"\nEvals: "+str(evals),10,20);
}


void setup(){  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //size(1440,720); //setea width y height
  //surf = loadImage("marscyl2.jpg");
  
  size(913,913); //setea width y height (de acuerdo al tamaño de la imagen)
  surf = loadImage("Rastrigin.png");
  
  smooth();
  fl = new Particle[puntos];
  for(int i =0;i<puntos;i++)
    fl[i] = new Particle();
}

void draw(){
  //background(200);
  //despliega mapa, posiciones  y otros
  image(surf,0,0);
  for(int i = 0;i<puntos;i++){
    fl[i].display();
  }
  
  despliegaBest();
  for(int i = 0;i<puntos;i++){
    fl[i].move();
    fl[i].Eval(surf);
  }
  
}
