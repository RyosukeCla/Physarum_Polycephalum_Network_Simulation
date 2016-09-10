SlimeMoldModel smm;
View view;
void setup () {
  size (600, 600);
  frameRate (10);
  smm = new SlimeMoldModel(15, 15, 0.4, 0.4);
  println ("1-0-0");
  view = new View (smm.eg.getEdges(), 20, 20);
  println ("1-0-1");
  smm.setI (0, 0, 15.0);
  smm.setI (9, 9, 15.0);
  println ("1-0-2");
}

void draw () {
  background (255);
  translate (10, 10);
  smm.update ();
  //println ("1-1-0");
  view.display ();
  //println ("1-1-1");
}

class Node {
  private PVector coord;
  private float pressure;

  Node (PVector coord) {
    this.coord = coord;
    this.pressure = 0.0;
  }

  void setPressure (float p) {
    this.pressure = p;
  }

  float getPressure () {
    return this.pressure;
  }

  PVector getCoordination () {
    return this.coord;
  }
}

class Edge {
  private float leng;
  private float diameter;
  private PVector a, b;
  Edge () {
    this.leng = 0.0;
    this.diameter = 0.1;
  }
  public void setLength (PVector a, PVector b) {
    this.leng = PVector.dist (a, b);
    this.a = a;
    this.b = b;
  }
  public float getLength () {
    return this.leng;
  }
  public void updateDiameter (float p, float r, float t) {
    this.diameter += t * (this.function (abs (p)) - r * this.diameter);
  }
  public float getDiameter () {
    return this.diameter;
  }
  public float getQuantity (float pi, float pj) {
    return this.diameter / this.leng * (pi - pj);
  }
  public float function (float q) {
    float i = pow (q, 3.0);
    return i / (i + 1.0);
  }
  
  public PVector getA () {
    return this.a;
  }
  public PVector getB () {
    return this.b;
  }
}

class EdgeGetter {
  Edge[] edges;
  int i, j;
  EdgeGetter (int i, int j) {
    this.i = i;
    this.j = j;
    int num = (i - 1) * j + (j - 1) * i;
    edges = new Edge [num];
    //println ("edge getter construct");
  }

  void initialize (Node[] nodes) {
    int index = 0;
    
    for (int y = 0; y < this.j; y++) {
      for (int x = 0; x < this.i - 1; x++) {
        edges[index] = new Edge ();
        println (edges[index]);
        edges[index].setLength (nodes[x + this.i * y].getCoordination (), nodes[x+1 + this.i * y].getCoordination ());
        index++;
      }
    }
    //println ("edge - 1");
    for (int x = 0; x < this.i; x++) {
      for (int y = 0; y < this.j - 1; y++) {
        edges[index] = new Edge ();
        edges[index].setLength (nodes[x + this.i * y].getCoordination (), nodes[x + this.i * (y + 1)].getCoordination ());
        index++;
      }
    }
    //println ("edge - 2");
  }

  Edge getEdge (int i, int j) {
    int I = i;
    int J = j;
    if (i > j) {
      I = j;
      J = i;
    }
    if (J - I == 1) {
      return edges[I];
    }
    int amari = I % this.i;
    return edges[(this.i - 1) * this.j + (this.j - 1) * amari + (I - amari) / this.i];
  }
  
  Edge[] getEdges () {
    return this.edges;
  }
}

class SlimeMoldModel {
  EdgeGetter eg;
  Node[] nodes;
  GaussElimination ge;
  float[] I;
  int i, j;
  float r;
  float t;
  SlimeMoldModel (int i, int j, float r, float t) {
    this.nodes = new Node [i * j];
    this.I = new float[i * j];
    //println ("1-0-1");
    this.eg = new EdgeGetter (i, j);
    println ("1-0-2");
    this.ge = new GaussElimination ();
    //println ("1-0-3");
    this.i = i;
    this.j = j;
    this.r = r;
    this.t = t;
    initialize ();
    //println ("1-0-4");
  }
  
  void initialize () {
    for (int n = 0; n < I.length; n++) {
      I[n] = 0.0;
    }
    for (int x = 0; x < i; x++) {
      for (int y = 0; y < j; y++) {
        this.nodes[x + y * this.i] = new Node (new PVector (x * 2.0, y * 2.0));
      }
    } 
    //println ("1-0-3-1");
    this.eg.initialize (this.nodes);
  }
  
  void setI (int x, int y, float I0) {
    this.I[x + this.i * y] = -I0;
  }
  
  void solvePressures () {
    float[][] matrix = new float[i*j][i*j+1];
    int indexOfI = 0;
    for (int x = 0; x < i*j; x++) {
      for (int y = 0; y < i*j + 1; y++) {
        if (y == i * j) {
          matrix[x][y] = I[indexOfI];
          indexOfI++;
        } else {
          matrix[x][y] = 0.0;
        }
      }
    }
    //println ("sp - 0");
    float DperLi, DperLj;
    int indexJ, indexI;
    Edge edge;
    for (int x = 0; x < this.i; x++) {
      for (int y = 0; y < this.j; y++) {
        indexJ = getIndex (x, y);
        indexI = getIndex (x, y - 1);
        if (indexI >= 0) {
          edge = this.eg.getEdge (indexI, indexJ);
          DperLi = edge.getDiameter () / edge.getLength ();
          DperLj = - DperLi;
          matrix [indexJ][indexI] += DperLi;
          matrix [indexJ][indexJ] += DperLj;
        }
        
        indexI = getIndex (x-1, y);
        if (indexI >= 0) {
          edge = this.eg.getEdge (indexI, indexJ);
          DperLi = edge.getDiameter () / edge.getLength ();
          DperLj = - DperLi;
          matrix [indexJ][indexI] += DperLi;
          matrix [indexJ][indexJ] += DperLj;
        }
        
        indexI = getIndex (x+1, y);
        if (indexI < i*j) {
          edge = this.eg.getEdge (indexI, indexJ);
          DperLi = edge.getDiameter () / edge.getLength ();
          DperLj = - DperLi;
          matrix [indexJ][indexI] += DperLi;
          matrix [indexJ][indexJ] += DperLj;
        }
        
        indexI = getIndex (x, y+1);
        if (indexI < i*j) {
          edge = this.eg.getEdge (indexI, indexJ);
          DperLi = edge.getDiameter () / edge.getLength ();
          DperLj = - DperLi;
          matrix [indexJ][indexI] += DperLi;
          matrix [indexJ][indexJ] += DperLj;
        } 
      }
    }
    this.ge.setting (matrix);
    this.ge.solve ();
    float[] result = this.ge.getResult ();
    
    for (int n = 0; n < i*j; n++) {
      this.nodes[n].setPressure (result[n]);
    }
    
  }
  
  void update () {
    solvePressures ();
    //println ("smm - 0");
    Node ni, nj;
    int indexI, indexJ;
    float quantity = 0.0;
    for (int x = 0; x < this.i; x++) {
      for (int y = 0; y < this.j; y++) {
        
        indexJ = getIndex (x, y);
        if (x < this.i - 1) {
          indexI = getIndex (x + 1, y);
          ni = this.nodes[indexI];
          nj = this.nodes[indexJ];
          quantity = this.eg.getEdge (indexI, indexJ).getQuantity (ni.getPressure (), nj.getPressure ());
          this.eg.getEdge (indexI, indexJ).updateDiameter (quantity, r, t);
        }
        if (y < this.j - 1) {
          indexI = getIndex (x, y + 1);
          ni = this.nodes[indexI];
          nj = this.nodes[indexJ];
          quantity = this.eg.getEdge (indexI, indexJ).getQuantity (ni.getPressure (), nj.getPressure ());
          this.eg.getEdge (indexI, indexJ).updateDiameter (quantity, r, t);
        }
      }
    }
  }
  
  int getIndex (int x, int y) {
    return x + y * this.i;
  }
}

class View {
  Edge[] edges;
  float scaleX, scaleY;
  View (Edge[] edges, float sx, float sy) {
    this.edges = edges;
    this.scaleX = sx;
    this.scaleY = sy;
  }
  
  void display () {
    float sw = 0.0;
    PVector c1, c2;
    for (int n = 0; n < this.edges.length; n++) {
      sw = 0.5 + this.edges[n].getDiameter ();
      strokeWeight (sw);
      c1 = this.edges[n].getA ();
      c2 = this.edges[n].getB ();
      line (c1.x * scaleX, c1.y * scaleY, c2.x * scaleX, c2.y * scaleY);
    }
    
    //printArray (edge);

  }
  
}