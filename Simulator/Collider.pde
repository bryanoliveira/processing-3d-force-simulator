public class Collider implements ComponentInterface {
    Object object;
    Physics physics;

    float radius; // raio de intersecção em que o mundo considera colisão global

    ArrayList<Object> nextToCollide = new ArrayList<Object>();
    ArrayList<Object> collisions = new ArrayList<Object>();

    public Collider(Object object) {
        this.object = object;
    }

    public void init() {
        this.physics = (Physics) object.getComponent(new Physics(null));

        // calcula o raio de colisão global do objeto pegando o valor mínimo e máximo dos vértices em X, Y e Z
        float min, max;

        min = min(object.vertices[0]);
        max = max(object.vertices[0]);

        for(int i = 1; i < object.vertices.length - axisVertices; i++) {
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

        // atualiza as propriedades físicas dele
    }

    public void setCollision(Object with, PVector origin) {
        // recebe um objeto que entrou em colisão e o ponto de origem da força de repulsão
        nextToCollide.add(with);
        screen.addLine("Collision checked!", 5, 2);
        // physics.acceleration.add(object.position.x - origin.x, object.position.y - origin.y, object.position.z - origin.z);
    }
}