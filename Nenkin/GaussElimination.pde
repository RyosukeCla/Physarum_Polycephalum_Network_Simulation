public class GaussElimination {

  float a[][]; 
  int N;
  float x[];
  
  public void setting (float a[][]) {
    this.a = a;
    N = a.length;
    x = new float [N];
  }

  public void pivot(int N, int k, float a[][]) {
    int ip;
    float max;
    max=Math.abs(a[k][k]);
    ip=k;
    if (k != N-1) {
      for (int i=k+1; i<N; i++) {
        if (Math.abs(a[i][k]) > max) {
          max=Math.abs(a[i][k]);
          ip=i;
        }
      }
    }
    if (ip != k) {
      for (int j=k; j<=N; j++) {
        float copy=a[k][j];
        a[k][j]=a[ip][j];
        a[ip][j]=copy;
      }
    }
  }

  public void forward(int N, int k, float a[][]) {
    float p, q;
    p=a[k][k];
    for (int j=k; j<=N; j++)
      a[k][j]/=p;
    if ( k != N-1) {
      for (int i=k+1; i<N; i++) {
        q=a[i][k];
        for (int l=k+1; l<=N; l++)
          a[i][l]-=q*a[k][l];
      }
    }
  }

  public void backward(int N, float a[][], float x[]) {
    x[N-1]=a[N-1][N]/a[N-1][N-1];
    for (int k=N-2; k>=0; k--) {
      float sum=0.0;
      for (int j=k+1; j<N; j++)
        sum += a[k][j]*x[j];
      x[k]=a[k][N]-sum;
    }
  }
  
  public void solve () {
    for (int k = 0; k < this.N; k++) {
      this.pivot (this.N, k, this.a);
      this.forward (this.N, k, this.a);
    }
    this.backward (this.N, this.a, this.x);
  }
  
  public float[] getResult () {
    return this.x;
  }
}