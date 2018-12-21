public class Physics implements ComponentInterface {
    Object object;

    PVector velocity;
    PVector acceleration;
    float mass = 10;

    boolean isRigidbody = true;

    public Physics(Object object) {
        this.object = object;

        this.velocity = new PVector(0, 0, 0);
        this.acceleration = new PVector(0, 0, 0);
    }

    public void init() {}

    public void run() {
        // calcula o deslocamento do objeto dadas as interações (aplicação das forças)
        // DEVE SER EXECUTADO APÓS TODOS OS COMPONENTES DE FÍSICA

        if(!isRigidbody) return;

        applyAcceleration();
        applyVelocity();

        acceleration.mult(0); // zera a aceleração
    }

    private void applyAcceleration() {
        // aplica as acelerações

        PVector tempAcc = acceleration.copy();

        tempAcc.add(new PVector(0, -9.80665, 0)); // gravidade

        velocity.add(tempAcc.mult(deltaTime));
    }

    private void applyVelocity() {
        // aplica as velocidades
        PVector tempVel = velocity.copy();
        object.translate(tempVel.mult(deltaTime));
    }
}