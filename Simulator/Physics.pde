class Physics implements Component {
  Object object;
  
  Physics(Object object) {
    this.object = object;
  }
  
  public void run() {
    println("oi");
  }
}
