public class GlobalPhysics {

    private class Limit {
        Object object;
        float start, end;

        public Limit(Object object, float start, float end) {
            this.object = object;
            this.start = start;
            this.end = end;
        }
    }

    private class LimitComparator implements Comparator<Limit> {
        // Compara limites de acordo com o start na reta cartesiana
        
        public int compare(Limit l1, Limit l2) {
            if(l1.start > l2.start) {
                return 1;
            }
            return -1;
        }
    }

    public void init() {
    }

    public void run() {
        // calcula a física do mundo

        setCollisions();
    }

    private void setCollisions() {
        // busca intersecções globais entre os objetos em X, Y e Z (nessa ordem, mas pode ser otimizado usando a variância da distribuição)

        // encontra os limites dos objetos na reta cartesiana
        ArrayList<Limit> limitsX = new ArrayList<Limit>();
        ArrayList<Limit> limitsY = new ArrayList<Limit>();
        ArrayList<Limit> limitsZ = new ArrayList<Limit>();
        for(int i = 0; i < world.objects.size(); i++) {
            Object object = world.objects.get(i);
            Collider objectCollider = (Collider) object.getComponent(new Collider(null));
            limitsX.add(new Limit(object, object.position.x - objectCollider.radius, object.position.x + objectCollider.radius));
            limitsY.add(new Limit(object, object.position.y - objectCollider.radius, object.position.y + objectCollider.radius));
            limitsZ.add(new Limit(object, object.position.z - objectCollider.radius, object.position.z + objectCollider.radius));
        }

        // ordena as listas para comparação
        Collections.sort(limitsX, new LimitComparator());
        Collections.sort(limitsY, new LimitComparator());
        Collections.sort(limitsZ, new LimitComparator());

        // armazena as colisões 2 a 2
        ArrayList<Limit[]> collisionsX = new ArrayList<Limit[]>();
        ArrayList<Limit[]> collisionsY = new ArrayList<Limit[]>();
        ArrayList<Limit[]> collisionsZ = new ArrayList<Limit[]>();

        // analiza a lista de colisão em X
        for(int i = 0; i < limitsX.size() - 1; i++) {
            Limit l1 = limitsX.get(i);

            for(int j = i + 1; j < limitsX.size(); j++) {
                Limit l2 = limitsX.get(i + 1);
            
                if(l1.end >= l2.start) { // potencial colisão
                    Limit[] collision = {l1, l2};
                    collisionsX.add(collision);
                }
            }
        }

        // analiza a lista de colisão em Y
        for(int i = 0; i < limitsY.size() - 1; i++) {
            Limit l1 = limitsY.get(i);

            for(int j = i + 1; j < limitsY.size(); j++) {
                Limit l2 = limitsY.get(i + 1);
            
                if(l1.end >= l2.start) { // potencial colisão
                    Limit[] collision = {l1, l2};
                    collisionsY.add(collision);
                }
            }
        }

        // analiza a lista de colisão em Z
        for(int i = 0; i < limitsZ.size() - 1; i++) {
            Limit l1 = limitsZ.get(i);

            for(int j = i + 1; j < limitsZ.size(); j++) {
                Limit l2 = limitsZ.get(i + 1);
            
                if(l1.end >= l2.start) { // potencial colisão
                    Limit[] collision = {l1, l2};
                    collisionsZ.add(collision);
                }
            }
        }

        collisionsX = intersection(collisionsX, collisionsY);
        collisionsX = intersection(collisionsX, collisionsZ);

        for(int i = 0; i < collisionsX.size(); i++) {
            println("Colisao (" + millis() + "): " + collisionsX.get(i)[0].object.name + ", " + collisionsX.get(i)[1].object.name);
        }
    }

    ArrayList<Limit[]> intersection(ArrayList<Limit[]> l1, ArrayList<Limit[]> l2) {
        ArrayList<Limit[]> list = new ArrayList<Limit[]>();

        for (Limit[] limit : l1) {
            for(Limit[] limit2 : l2) {
                if((limit[0].object == limit2[0].object && limit[1].object == limit2[1].object) || 
                   (limit[0].object == limit2[1].object && limit[1].object == limit2[0].object)) {
                    list.add(limit);
                }
            }
        }

        return list;
    }
}