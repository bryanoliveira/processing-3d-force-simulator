public interface ComponentInterface {
    Object object = null;

    public void init(); // deve ser chamado após o init do objeto

    public void run(); // deve ser chamado durante a execução do step() do mundo
}
