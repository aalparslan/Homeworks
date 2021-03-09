public abstract class State {
    // TODO

    // min max bound is put to restrict agents movement.
    private double maxSpeed = 2.0;
    private double minSpeed = 1.0;
    private String name;//other attributes
    protected Position position;

    public abstract Position Move();

    public State( String name,Position position) {
        this.name = name;
        this.position = position;

    }

    //getters
    public String getName() {
        return name;
    }

    protected double getSpeedRandomly() {
        // getSpeedRandomly returns a speed between min an max
        return minSpeed + Common.getRandomGenerator().nextDouble() * (maxSpeed-minSpeed);

    }

    //Agent will not know which state it is in. BuildState randomly selects a state and returns.
    public static State buildState(Position position){
        int maxStateNumber = 5;
        int minStateNumber  = 1;
        int key  = (int)( minStateNumber + Common.getRandomGenerator().nextDouble() *
                                                    (maxStateNumber - minStateNumber));

        if(key == 1){
            return new Rest(position);
        }else if(key == 2){
            return new GotoXY(position);
        }else if(key == 3){
            return new Shake(position);
        }else if(key == 4){
            return new ChaseClosest(position);
        }else{
            System.out.println("Error: creation of states");
            return  null;
        }

    }

    //these static methods used throughout the application
    static double getLength(Position position1, Position position2){
        return Math.sqrt(Math.pow(position1.getX() - position2.getY(),2) +
                Math.pow(position1.getY() - position2.getY(),2));
    }

    static Position normalizeVector(Position position1){
        Position origin = new Position(0,0);
        double length = getLength(position1, origin);
        if(length > 0.1){
            double newXCoord = position1.getX()/ length;
            double newYCoord = position1.getY()/ length;
            position1.setX(newXCoord);
            position1.setY(newYCoord);
            return  position1;
        }
        return position1;
    }

    // these two method used by GotoXY. They restricts agents movements in a certain range
    static double getRandomX(){
        return Common.getRandomGenerator().nextDouble() * 1000;
    }

    static double getRandomY(){
        // in the GotoXY state agents should move below the upperLine,
        // therefore random y coordinates is given more than a upperLine level
        return Common.getUpperLineY() + Common.getRandomGenerator().nextDouble() * (700 - Common.getUpperLineY());
    }


}