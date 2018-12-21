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

        localCollisions(globalCollisions());
    }

    private ArrayList<Limit[]> globalCollisions() {
        // busca intersecções globais entre os objetos em X, Y e Z (nessa ordem, mas pode ser otimizado usando a variância da distribuição)
        // TODO esse método pode ser melhorado, o procedimento de intersecção é O(n²)

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
        return collisionsX;
    }

    private void localCollisions(ArrayList<Limit[]> potentialCollisions) {
        // verifica se as potenciais colisões são realmente colisões e informa os envolvidos
        /* Pra cada face do primeiro polígono, verifica se o produto vetorial entre sua normal e 
         * cada vértice do segundo polígono é maior que zero. Se sim, não há colisão.
         * Adicione todos os vértices que geram um produto <= 0 em um vetor auxiliar, removendo os que
         * eventualmente geram um valor > 0 com alguma face. 
         * Os pontos que sobrarem representam a magnitude da colisão.
         */

        // para cada potencial colisão
        for(int i = 0; i < potentialCollisions.size(); i++) {
            Limit[] collision = potentialCollisions.get(i);
            Object obj1 = collision[0].object;
            Object obj2 = collision[1].object;

            // aplica transformações nos vértices
            obj1.computedVertices = obj1.getVertices(); 
            obj2.computedVertices = obj2.getVertices(); 

            // calcula a normal das faces
            obj1.getFaces();
            obj2.getFaces();

            // pega os vertices de intersecção entre os objetos

            ArrayList<float[]> intersectionPoints = new ArrayList<float[]>();

            // começa com os pontos do segundo objeto que estão dentro do primeiro
            // pra cada vértice do segundo objeto
            for(int j = 0; j < obj2.computedVertices.length - axisVertices; j++) {
                boolean outside = false;
                // pra cada face do primeiro objeto
                for(int k = 0; k < obj1.faces.length; k++) {
                    PVector P2 = new PVector(obj1.computedVertices[obj1.faces[k].vertices[1]][0],
                                             obj1.computedVertices[obj1.faces[k].vertices[1]][1],
                                             obj1.computedVertices[obj1.faces[k].vertices[1]][2]);

                    // produto vetorial entre a normal da face k e a diferença entre o vértice j e um vértice da face
                    float prod = obj1.faces[k].normal.x * (obj2.computedVertices[j][0] - P2.x) +
                                 obj1.faces[k].normal.y * (obj2.computedVertices[j][1] - P2.y) +
                                 obj1.faces[k].normal.z * (obj2.computedVertices[j][2] - P2.z);

                    if(prod > 1) outside = true;
                }

                if(!outside) {
                    intersectionPoints.add(obj2.computedVertices[j]);
                }
            }

            // pega os pontos do primeiro objeto que estão dentro do segundo
            // pra cada vértice do primeiro objeto
            for(int j = 0; j < obj1.computedVertices.length - axisVertices; j++) {
                boolean outside = false;
                // pra cada face do segundo objeto
                for(int k = 0; k < obj2.faces.length; k++) {
                    PVector P2 = new PVector(obj2.computedVertices[obj2.faces[k].vertices[1]][0], 
                                             obj2.computedVertices[obj2.faces[k].vertices[1]][1], 
                                             obj2.computedVertices[obj2.faces[k].vertices[1]][2]);

                    // produto vetorial entre a normal da face k e a diferença entre o vértice j e um vértice da face
                    float prod = obj2.faces[k].normal.x * (obj1.computedVertices[j][0] - P2.x) +
                                 obj2.faces[k].normal.y * (obj1.computedVertices[j][1] - P2.y) +
                                 obj2.faces[k].normal.z * (obj1.computedVertices[j][2] - P2.z);

                    if(prod > 1) outside = true;
                }

                if(!outside) {
                    intersectionPoints.add(obj1.computedVertices[j]);
                }
            }

            // se houve intersecção, houve colisão
            if(intersectionPoints.size() > 0) {
                // faz a média entre os pontos de intersecção - esse vai ser o ponto de origem das forças de reação
                PVector collisionOrigin = new PVector(0, 0, 0);
                for(int j = 0; j < intersectionPoints.size(); j++) {
                    collisionOrigin.x += intersectionPoints.get(j)[0];
                    collisionOrigin.y += intersectionPoints.get(j)[1];
                    collisionOrigin.z += intersectionPoints.get(j)[2];
                }
                collisionOrigin.div(intersectionPoints.size());

                // avisa os objetos da colisão
                ((Collider) obj1.getComponent(new Collider(null))).setCollision(obj2, collisionOrigin);
                ((Collider) obj2.getComponent(new Collider(null))).setCollision(obj1, collisionOrigin);
            }
        }
    }

    private ArrayList<Limit[]> intersection(ArrayList<Limit[]> l1, ArrayList<Limit[]> l2) {
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