public class Collider implements ComponentInterface {
    Object object;
    Physics physics;

    float radius; // raio de intersecção em que o mundo considera colisão global

    boolean applyForces = false;
    PVector forces = new PVector(0, 0, 0);
    PVector velocity = new PVector(0, 0, 0);
    

    public Collider(Object object) {
        this.object = object;
    }

    public void init() {
        this.physics = (Physics) object.getComponent(new Physics(null));

        // calcula o raio de colisão global do objeto pegando o valor mínimo e máximo dos vértices em X, Y e Z
        float min, max;

        object.computedVertices = object.getVertices();

        min = min(object.computedVertices[0]);
        max = max(object.computedVertices[0]);

        for(int i = 1; i < object.computedVertices.length; i++) {
            float tempMin, tempMax;
            tempMin = min(object.computedVertices[i]);
            tempMax = max(object.computedVertices[i]);
            if(tempMin < min) min = tempMin;
            if(tempMax > max) max = tempMax;
        }

        this.radius = max - min;
    }

    public void run() {
        // recebe objetos identificados pelo mundo como colisão global e calcula pontos de colisão local
        // DEVE SER EXECUTADO APÓS A FÍSICA DO MUNDO

        if(!applyForces) return;
        else applyForces = false;

        // atualiza as propriedades físicas dele
        physics.acceleration.add(forces);
        physics.velocity = velocity.copy();

        // reseta as colisões a cada timestep
        forces.x = forces.y = forces.z = velocity.x = velocity.y = velocity.z = 0;
    }

    public void setCollision(Object with, PVector origin) {
        // recebe um objeto que entrou em colisão e o ponto de origem da força de repulsão
        // https://en.wikibooks.org/wiki/Fundamentals_of_Physics/Linear_Momentum_and_Collisions

        screen.addLine("Collision checked!", 5, 2);

        Physics other = (Physics) with.getComponent(new Physics(null));
        PVector thisVelocity = physics.velocity.copy();
        PVector otherVelocity = other.velocity.copy();

        thisVelocity.mult((physics.mass - other.mass) / (physics.mass + other.mass));
        otherVelocity.mult((2 * other.mass) / (physics.mass + other.mass));

        velocity = thisVelocity;
        velocity.add(otherVelocity);

        applyForces = true;
    }
}
