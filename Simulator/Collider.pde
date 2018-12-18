public class Collider implements ComponentInterface {
    Object object;

    float radius; // raio de intersecção em que o mundo considera colisão global

    ArrayList<Object> nextToCollide = new ArrayList<Object>();
    ArrayList<Object> collisions = new ArrayList<Object>();

    public Collider(Object object) {
        this.object = object;
    }

    public void init() {
        // calcula o raio de colisão global do objeto pegando o valor mínimo e máximo dos vértices em X, Y e Z
        float min, max;

        min = min(object.vertices[0]);
        max = max(object.vertices[0]);

        for(int i = 1; i < object.vertices.length; i++) {
            float tempMin, tempMax;
            tempMin = min(object.vertices[i]);
            tempMax = max(object.vertices[i]);
            if(tempMin < min) min = tempMin;
            if(tempMax > max) max = tempMax;
        }

        this.radius = max - min;
    }

    public void run() {
        // recebe objetos identificados pelo mundo como colisão global e calcula pontos de colisão local
        // DEVE SER EXECUTADO APÓS A FÍSICA DO MUNDO

        // reseta as colisões a cada timestep
        collisions = new ArrayList<Object>(nextToCollide);
        nextToCollide.clear();
    }

    public void setCollision(Object with) {
        // recebe um objeto identificado como colisão global
        nextToCollide.add(with);
    }
}